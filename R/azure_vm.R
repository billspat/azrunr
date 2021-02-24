# az_vm.R

deleteVMByName <- function(vmname, rgName = getOption('azurerg')){
    rg<-get_rg(rgName)
    resources <- rg$list_resources(filter=paste0("substringof('", vmname, "', name)"))

}

#' Delete all the resources created by a deployment of a vm
#' This will use a tag created by a deployment to delete all resources
#' Deletion may take a minute or two for all resources to be cleaned up
#' @param vmName the name of the vm created by the deployment to be deleted
#' @param rgName the resource group of the resources, default to the get option azurerg
delete_deployment_resources <- function(vmName, rgName = getOption('azurerg'))
{
    vm <- get_vm(vmName, rgName, verbose=TRUE)
    deployTag <- vm$get_tags()$deployment_tag # This will only work if the tag we are going to include on all resources is titled "deployment_tag"
    rg <- get_rg(rgName)
    deployResources <- rg$list_resources(filter=paste("tagName eq 'deployment_tag' and tagValue eq '", deployTag, "'", sep="")) # again this will work only with tag titled "deployment_tag"
    vm$delete(wait=TRUE) # delete vm first so other resources are not being used
    gotDisk <- FALSE # Need to know if the disk was picked up, as it does not appear in the resource list until some time after the deployment
    diskName <- vm$properties$storageProfile$osDisk$name
    for (d in deployResources)
    {
        if (d$type != "Microsoft.Compute/virtualMachines/extensions")
        {
            d$delete(confirm=FALSE, wait=TRUE)
        }
        if (d$type == "Microsoft.Compute/disks")
        {
            gotDisk <- TRUE
        }
    }
    if (gotDisk == FALSE)
    {
        disk <- getResourcesByName(diskName)[[1]]
        disk$delete(confirm=FALSE, wait=TRUE)
    }
}

#' get the desired vm, if it exists
#' @param vmName the name of the desired vm
#' @param rgName the resource group of the vm, default to the get option azurerg
#' @param rg the resource group object, used to make the function call less demanding if already known, default to NULL
#' @return the vm if it exists, else null
get_vm <- function(vmName, rgName=getOption('azurerg'), rg=NULL, verbose=FALSE)
{
    if (is.null(rg))
    {
        rg <- get_rg(rgName)
    }
    vm <- tryCatch(test <- rg$get_resource(type="Microsoft.Compute/virtualMachines", name=vmName),
                   error=function(cond){
                    if (verbose==TRUE)
                    {print(cond)}
                    return(NULL)}, finally=function(cond){return(test)})
    return(vm)
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

#' Launch a vm from a template file and a extension file provided
#' Remember to set your working directory prior to use.
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
#' @param scriptContainer the name of the container where the extension script is hosted, default to azurecontainer option
#' @param storageKey the access key to the storage account linked to the vm, default to storageaccesskey option
#' @param resourceGroup the name of the resource group that will contain all resources created, default to azurerg option
#' @param storageContainer the name of the container to be mounted to the vm
#' @param wait if true, wait until the vm deployment is complete to return, default true
vm_from_template <- function(vmName, templateFile, shellScript, adminPasswordOrKey, userPassword,
                           cpuSize=c("CPU-4GB", "CPU-7GB", "CPU-8GB", "CPU-14GB", "CPU-16GB", "GPU-56GB"),
                           ubuntuOSVersion=c("18.04-LTS", "20_04-lts", "20_04-daily-lts-gen2"),
                           adminUsername=getOption("azureuser"),
                           webUsername=getOption("azureuser"), dnsNameForPublicIP=getOption("azureuser"),
                           storageAccount=getOption("azurestor"),
                           scriptContainer=getOption("azurecontainer"), storageKey=getOption("storageaccesskey"),
                           resourceGroup=getOption("azurerg"), storageContainer=getOption("azurecontainer"),
                           wait = TRUE)
{
    # Parameter Evaluation
    ubuntuOSVersion <- match.arg(ubuntuOSVersion)
    cpuSize <- match.arg(cpuSize)

    # complete file path
    templateFile <- paste(getwd(), templateFile, sep="")
    shellScript <- paste(getwd(), shellScript, sep="")

    # Upload provided file to Azure file storage within the storageAccount and storageContainer provided
    stor <- get_stor(storageAccount)
    cont <- get_container(scriptContainer)
    AzureStor::storage_upload(cont, shellScript)

    # shellScript should now just be the file name
    shellScript = basename(shellScript)

    # Launch a VM
    rg <- get_rg(resourceGroup)

    deploy <- rg$deploy_template(vmName, template=templateFile,
                                 parameters=list('adminUsername'=adminUsername, 'webUsername'=webUsername,
                                                 'dnsNameForPublicIP'=dnsNameForPublicIP, 'ubuntuOSVersion'=ubuntuOSVersion,
                                                 'adminPasswordOrKey'=adminPasswordOrKey, '_artifactsLocation'=stor$properties$primaryEndpoints$blob,
                                                 '_customScriptFile'=shellScript, 'userPassword'=userPassword,
                                                 'storageAccount'=storageAccount, 'storageContainer'=storageContainer, 'storageKey'=storageKey,
                                                 'namePrefix'=vmName, 'cpuSize'=cpuSize, '_scriptContainer'=scriptContainer), wait=wait)

    for (d in deploy$list_resources())
    {
        if (d$type == "Microsoft.Network/publicIPAddresses")
        {
            ip <- d$properties$ipAddress # Ip address used to connect to vm
        }
        if (d$type == "Microsoft.Compute/virtualMachines")
        {
            vm <- d$properties$osProfile$computerName
        }
    }
    print(paste("The VM, and other resources, can be found in the Azure portal under the resource group:", resourceGroup,  "with the provisioned VM Name:", vm))
    print(paste("To connect to rstudio, paste address: ", ip, ":8787 into a browser, login to rstudio server with username: ", deploy$properties$parameters$webUsername$value, " and password: " , userPassword, sep=""))
    print(paste("To connect via ssh, use command: ssh ", deploy$properties$parameters$adminUsername$value, "@", ip, sep=""))
    return(deploy)
}

