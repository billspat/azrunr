library(azrunr)


test_clone <- function(image_to_clone, new_vm_name = paste0("test_", format(Sys.time(), "%Y%m%d_%H%M%S")),
                       admin_user_name = Sys.info()['user'],
                       rgName = getOption('azurerg')) {
    ###set the image to clone from
    ### get a resource group object.  requires that the 'azuresub' option is set with 'options()'
    rg <- get_rg(rgName)
    # provision a new vm with the nanme supplied
    # newVMName, resourceGroup, imageID, vmUsername, vmPassword)
    admin_user_pw <- paste0(admin_user_name, "2020!")
    print(paste("creating vm with user ", admin_user_name, " pw ", admin_user_pw))
    new_vm<- vmFromImage(new_vm_name, rg, image_to_clone, vmUsername=admin_user_name, vmPassword=admin_user_pw)
    # return it for inspection
    return(new_vm)

}


test_that("can find a disk image in current rg", {
    # TODO MAKE A FIXTURE OF THIS, as no guarantee this is still present?
    # TODO function to create an image azure 'uri'  from image name
    image_to_clone = "/subscriptions/aa32e19c-49b5-478c-af56-fc710b1a8a1c/resourceGroups/zipkinlab/providers/Microsoft.Compute/images/will3298OSImage"
    # is_it_an_image <- azure code to see if this is an image in the current rg
    # expect_true(is_it_an_image)
    testthat::expect_true(TRUE)

})

test_that("NOT IMPLEMENTED can make vm of zipkin lab image", {
    # TODO MAKE A FIXTURE OF THIS
    image_to_clone = "/subscriptions/aa32e19c-49b5-478c-af56-fc710b1a8a1c/resourceGroups/zipkinlab/providers/Microsoft.Compute/images/will3298OSImage"

    # vm <- test_clone(image_to_clone)
    testthat::expect_true(TRUE)

    }
)
