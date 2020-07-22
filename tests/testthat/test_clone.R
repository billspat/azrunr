image_to_clone = "/subscriptions/aa32e19c-49b5-478c-af56-fc710b1a8a1c/resourceGroups/zipkinlab/providers/Microsoft.Compute/images/will3298OSImage"


test_clone <- function(new_vm_name = "mynewvm", admin_user_name = Sys.info()['user'], rgName = getOption('azurerg')) {
    ###set the image to clone from
    ### get a resource group object.  requires that the 'azuresub' option is set with 'options()'
    rg <- getResourceGroup(rgName)
    # provision a new vm with the nanme supplied
    # newVMName, resourceGroup, imageID, vmUsername, vmPassword)
    admin_user_pw <- paste0(admin_user_name, "2020!")
    print(paste("creating vm with user ", admin_user_name, " pw ", admin_user_pw))
    new_vm<- vmFromImage(new_vm_name, rg, image_to_clone, vmUsername=admin_user_name, vmPassword=admin_user_pw)
    # return it for inspection
    return(new_vm)

}
