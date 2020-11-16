context("vm creation")
library(azrunr)
library(AzureVM)

# test vm cloning - requires valid Azure account and sub id and resource group set in options or
# in  environment (e.g. .Renviron)
test_that("can make vm of zipkin lab image", {
    # TODO MAKE A FIXTURE OF THIS
    image_to_clone = "/subscriptions/aa32e19c-49b5-478c-af56-fc710b1a8a1c/resourceGroups/zipkinlab/providers/Microsoft.Compute/images/will3298OSImage"
    #TODO test that this is a valid disk image, or a new fn that, given an image name, checks if it's valid
    # get the current rresource group
    resourceGroup <- get_rg() # logs in and sets up options if not logged in

    # set some default values for test
    new_vm_name = paste0("test-", format(Sys.time(), "%Y%m%d-%H%M%S"))
    admin_user_name = Sys.info()['user']
    admin_user_pw <- paste0(admin_user_name, "2020!")

    # create vm from disk image
    # this takes a while as the test waits for imge to be deployed
    test_vm<- azrunr::vmFromImage(newVMName=new_vm_name,
                                  resourceGroup=resourceGroup,
                                  imageID=image_to_clone,
                                  vmUsername=admin_user_name,
                                  vmPassword=admin_user_pw,
                                  comment="created by azrunr test"
                                  )

    testthat::expect_equal(class(test_vm)[1], "az_vm_template")
    testthat::expect_equal(test_vm$name, new_vm_name)

    test_vm_resource_name <- paste0("Microsoft.Compute/virtualMachines/",new_vm_name)
    testthat::expect_true(test_vm_resource_name %in% names(rg$list_resources()))

    }
)
