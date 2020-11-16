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

vmFromTemplate <- function(resourceGroup, templatefile, paramsfile){

}
