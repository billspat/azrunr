## azRunr 

Azure Runner R package : *scientist-friendly functions for creating Azure resources and running your code on it*


July 2020

This is packge to provide convenience methods around standard cloud practices for running R code (specifically Bayesian models) on the Azure Cloud.   It's a  simple package designed for scientists to easily provision and do work on cloud computers using R functions within R studio

Status
---

This is in very early stages of development and some R scripts/functions are not complete and just ideas or stubs.   It remains to be seen if this package will be easier to use than simply running the Aure functions from the AzureR library collection directly


Using this package
---

*Currently using as a package has not been tested, only as a Rstudio project.  This section is for development only and will need to be re-written as the package is developed*

After cloning the repository, first create a new file `.Renviron` in the root folder by copying the file example-Renviron.  This file needs to ahve the following entries

AZUREUSER=<your netid>
AZURESUB=<azure subscritpion id>
AZURERG=<resource group this will primarily be used with>

The `.Renviron` file is read when you start R and creates environment variables you can access from your R session.  See https://rstats.wtf/r-startup.html.    You will have to restart your R session to re-read the .Renviron when you change it. 


Testing your setup
---

There is a function `set_azure_options()` that you can run next which will read the values from the environment and set those as options for use by the other functions, so you don't have to add the resource group, user and sub id as parameters everytime.    Run this function to see if your `.Renviron` works with this package. 

`allResourceNames()` should list all the items in this resource group, and the functions in azure_info.R  provide information that feeds into the other functions (e.g. to list storage accounts, disks to clone, etc). 




