context('azure setup')
library(azrunr)


#### NOTE ABOUT THESE OPTIONS

### for these tests to work at all, we need to have a valid Azure subscription and existing resource group
## TODO given a valid subscription for testing, create a new resource group just for running these tests
## then perhaps use the withr package to set options for testing https://withr.r-lib.org/reference/with_options.html
## we should have a way to let users set the subscription id without editing code
## one possibliity is setting TEST_SUB_ID in .Renviron, or set in the environment prior to running tests
## this will be a problem if this package is ever submitted to CRAN which does automated testing
## but that is not our goal so we won't worry about it
## but for now, these tests  assume that the .Renviron file (or environment itself ) has valid values for
# AZUREUSER, AZURESUB, and  AZURERG
# and we will use those for all tests.   To run the tests you must have these values set in .Renviron or as options.


test_that("can set options and get rg and sub id ( requires  working azure subscription)", {
    ### for these tests to work at all, we need to have a valid Azure subscription and existing resource group
    ## TODO given a valid subscription for testing, create a new resource group just for running these tests
    ## use the withr package to set options for testing https://withr.r-lib.org/reference/with_options.html
    ## but for now, we have to assume that the .Renviron file (or environment itself ) has valid values for
    # AZUREUSER, AZURESUB, and  AZURERG

    # set_azure_options() returns true if the options are set

    op <- options()
    on.exit(options(op), add = TRUE, after = FALSE)

    expect_true(
        set_azure_options() # this fn currenlty returns true/false
    )

    sub <- get_sub()
    expect_equal(class(sub)[1], "az_subscription")
    expect_equal(nchar(sub$id),36)  #sub ids are this long currently
    rg <- get_rg()
    expect_equal(class(rg)[1], "az_resource_group")

})
