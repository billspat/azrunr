# az_vm.R

deleteVMByName <- function(vmname, rgName = getOption('azurerg')){
    rg<-get_rg(rgName)
    resources <- rg$list_resources(filter=paste0("substringof('", vmname, "', name)"))

}



# this will create a new VirtualMachine based on an image
# it will aslo create the following by products
# osDisk/newImage
# network interface
#
# It is recommended you have fewer large VNets than multiple small VNets. This will prevent management overhead.
# create single vnet for most of
vmFromImage <- function(newVMName, resourceGroup, imageID, vmUsername, vmPassword, comment="created by R script!")
{
    #TODO test that resource group is valid
    #TODO test that the newVMName param is valid and matches re ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.
    userConfig <- AzureVM::user_config(vmUsername, password=vmPassword) #User
    ipConfig <- AzureVM::ip_config(dynamic=TRUE)
    imageConfig <- AzureVM::image_config(id = imageID)

    #TODO  vnet_config to use network security group
    nsg = AzureVM::nsg_config()

    #TODO use vnet config to connect to network security group
    vnet = AzureVM::vnet_config()

    newVMConfig <- AzureVM::vm_config(image=imageConfig,
                                      keylogin=FALSE,
                                      os_disk_type ="Standard_LRS",
                                      ip=ipConfig) #VM CONFIG

    newVM <- resourceGroup$create_vm(newVMName,
                                     login_user = userConfig,
                                     size="Standard_D2s_v3",
                                     config=newVMConfig,
                                     location=resourceGroup$location)
    # set tags
    print(newVM)

    # try(newVM$set_tags(comment=comment, created_by=Sys.info()['user'], created_on =  format(Sys.time(), "%Y-%m-%d %X")))

    return(newVM)

}

# create a data science vm using current azure options for username and ssh key
# this is a stub function, and features for data disks etc will be added

dsvm <- function(name, resourceGroup=NULL, vm_password=NULL) {
    # first create a 'user' for the VM

    # TODO check the name to match  ^[a-z][a-z0-9-]{1,61}[a-z0-9]$.

    # password vs key
    #  1) if password is sent, use that
    #  2) if no password sent, check options for ssh key
    #  3) if no ssh key, then fail
    if( is.null(resourceGroup)){
        resourceGroup = get_rg()
    }

    if(! is.null(vm_password)){
        userconfig <- AzureVM::user_config(username=getOption('azureuser'),
                                           password = vm_password)

    } else {
        if( ! is.null(getOption('azuresshkey'))) {
            userconfig <- AzureVM::user_config(username=getOption('azureuser'),
                                       sshkey = getOption('azuresshkey'))
        } else {
            warning("requires you send password parameter ,or set up sshkey option")
            return(NULL)
        }
    }

    # removed this param : sshkey = getOption('azuresshkey'),
    # create the VM
    message("creating VM")
    newvm <- resourceGroup$create_vm(name=name,
                            login_user=userconfig,
                            managed_identity = FALSE,
                            config = "ubuntu_dsvm_gen2",
                            wait=TRUE)
    return(newvm)

}


findcomputer <- function(res) {
    if(stringr::str_detect(res$name,"Compute")){
        return( TRUE)
    } else {
    return( FALSE)
        }
}


vm_git_pull <- function(vm, gitrepository){
    git_cmd = paste("git pull ", gitrepository)
    vm$do_operation("runCommand",
                    body=list(
                        commandId="RunShellScript",
                        script=as.list(git_cmd)
                    ),
                    encode="json",
                    http_verb="POST")
}

#'Launch a vm from a template file and a extension file provided
#' @param vmName the name of the VM, also used as a prefix on all related resources created during the deployment
#' @param templateFile the file path to the template json used to deploy the VM and other resources
#' @param shellScript the file path to the extension script file
#' @param adminPasswordOrKey ssh public key used to access the vm through ssh
#' @param userPassword Rstudio password
#' @param cpuSize the size of the cpu, one of the following list ("CPU-4GB", "CPU-7GB", "CPU-8GB", "CPU-14GB", "CPU-16GB", "GPU-56GB")
#' @param ubuntuOSVersion the Ubuntu version of the VM, one of the following list ("18.04-LTS", "20_04-lts", "20_04-daily-lts-gen2")
#' @param adminUsername the Username used to login to the VM, default to the azureuser option
#' @param webUsername the Username used to login to RStudio, default to the azureuser option
#' @param dnsNameForPublicIP unique naming for the PublicIP resource, default to the azureuser option
#' @param storageAccount the name of the storage account linked to the vm, default to azurestor option
#' @param storageContainer the name of the container where the extension script is hosted, default to azurecontainer option
#' @param storageKey the access key to the storage account linked to the vm, default to storageaccesskey option
#' @param resourceGroup the name of the resource group that will contain all resources created, default to azurerg option
vm_from_template <- function(vmName, templateFile, shellScript, adminPasswordOrKey, userPassword,
                           cpuSize=c("CPU-4GB", "CPU-7GB", "CPU-8GB", "CPU-14GB", "CPU-16GB", "GPU-56GB"),
                           ubuntuOSVersion=c("18.04-LTS", "20_04-lts", "20_04-daily-lts-gen2"),
                           adminUsername=getOption("azureuser"),
                           webUsername=getOption("azureuser"), dnsNameForPublicIP=getOption("azureuser"),
                           storageAccount=getOption("azurestor"),
                           storageContainer=getOption("azurecontainer"), storageKey=getOption("storageaccesskey"),
                           resourceGroup=getOption("azurerg")
                           )
{
    # Parameter Evaluation
    ubuntuOSVersion <- match.arg(ubuntuOSVersion)
    cpuSize <- match.arg(cpuSize)

    #Upload provided file to Azure file storage within the storageAccount and storageContainer provided
    stor <- get_stor(storageAccount)
    cont <- get_container(storageContainer)
    AzureStor::storage_upload(cont, shellScript)

    # Launch a VM
    rg <- get_rg(resourceGroup)
    deploy <- rg$deploy_template(vmName, template=templateFile,
                                 parameters=list('adminUsername'=adminUsername, 'webUsername'=webUsername,
                                                 'dnsNameForPublicIP'=dnsNameForPublicIP, 'ubuntuOSVersion'=ubuntuOSVersion,
                                                 'adminPasswordOrKey'=adminPasswordOrKey, '_artifactsLocation'=stor$properties$primaryEndpoints$blob,
                                                 '_customScriptFile'=shellScript, 'userPassword'=userPassword,
                                                 'storageAccount'=storageAccount, 'storageContainer'=storageContainer, 'storageKey'=storageKey,
                                                 'namePrefix'=vmName, 'cpuSize'=cpuSize))

}

