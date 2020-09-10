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

    newVMConfig <- AzureVM::vm_config(image=imageConfig, keylogin=FALSE, os_disk_type ="Standard_LRS", ip=ipConfig) #VM CONFIG
    newVM <- resourceGroup$create_vm(newVMName, login_user = userConfig, size="Standard_D2s_v3", config=newVMConfig, location=resourceGroup$location)
    # set tags
    print(newVM)

    # try(newVM$set_tags(comment=comment, created_by=Sys.info()['user'], created_on =  format(Sys.time(), "%Y-%m-%d %X")))

    return(newVM)

}



deleteVM <- function(vmname, rgName = getOption('azurerg')){
    # this script assumes the related resources have the same name

}
