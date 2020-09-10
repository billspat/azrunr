azRunr
===

Azure Runner R package : *scientist-friendly functions for creating Azure resources for running R code*


*July 2020**

This is package provides convenience methods around standard cloud practices for running R code (specifically Bayesian models) on the Azure Cloud.   It's a  simple package designed for scientists to easily provision and do work on cloud computers using R functions within R studio with some pre-configured conventions. 

Status
---

This is in very early stages of development and some R scripts/functions are not complete and just ideas or stubs.   It remains to be seen if this package will be easier to use than simply running the Aure functions from the AzureR library collection directly


Developing/Using this package
---



*Currently this package is in early stages and does not have much functionality.   This section is for development only and will need to be re-written as the package is developed*

**Requirements**

  * Valid Azure user id and active subscription (the tests and other functions create Azure resources that are not free of cost)
  * Azure Resource group for development or for work
  * *optional but may be required in future: ssh key pair* 
 
**Getting Started**

  * Clone the repository into a new directory
  * in that directory create a new file `.Renviron` in the root folder (note the starting character is
    a dot/period).  
    - You could copy the file  `example-Renviron` to `.Renviron` to start
  * The .Renviron should have the following entries 

```
    AZUREUSER=<your azure id>
    AZURESUB=<azure subscription id>
    AZURERG=<resource group this will primarily be used with>
```
  

Note: The `.Renviron` file is read when you start R and creates environment variables you can access from your R session.  See https://rstats.wtf/r-startup.html for a good description.    

  * Restart your R session to re-read the .Renviron when you change it, which you can do in Rstudio in the "Session" menu, select 'Restart R' after editing and saving the file. 
  * Note : If you are familiar with Environment variables, you can also set these for your session, which shoudl override .Renviron to test with different Azure subscriptions/groups
  * install the devtools package
  * *optional but recommend:* install the `renv` package with ` install.packages(renv)` and then use
    renv to install all the packages necessary for this project with `renv::init()`


Testing your setup
---

After setting the Azure subscription (AZURESUB) and resource group (AZURERG) either in .Renviron or in your OS environment, try the following in the R console

```
devtools::build()    # build the package
library(azrunr)      # load the package
set_azure_options()  # set R options for Azure subscription. Triggers an Azure log-in if necessary
allResourceNames()   # should list all the items in  resource group defined above
names(storageAccounts())    # should list storage accounts if any
```

additionally, developers or users of this package with access to multiple resource groups can select a different resource group to work within, overriding what's in .Renviron:

```
azuresub <- get_sub()   # gets a subscription 'object' (see )
rgroups <- azuresub$list_resource_groups()   # pull all resource groups in the subscription
names(rgroups)  # list the all the resource group names

first_group <- names(rgroups)[1]       # get the first group in the list
first_group                            # and show it
set_azure_options(azurerg=first_group) # change default resource group
current_rg <- get_rg()                 # get a resource group object
current_rg$name                           # should be the same
```






