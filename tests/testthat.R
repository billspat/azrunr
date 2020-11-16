library(testthat)
library(azrunr)

if(set_azure_options() !=TRUE) {
    print('invalid option for azure (subscription, etc')
} else {
    test_check("azrunr")
}
