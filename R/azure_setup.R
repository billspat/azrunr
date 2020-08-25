#' azure_setup.R
#' DRAFT
#' functions to simplify set up Azure options for the subid and subscription
#' and other Azure values that should not go into this library


#' Tests that azure libraries are installed and working.
#' @return T/F depending on if az is setup and works
azure_check <- function() {
  #TODO write text to make sure that 1) azure libs are available and 2) user can log in
  # equivalant in the CLI is az login
  print("not implemented")
  return(FALSE)
}

#' read azure defaults from the environment to set package options.
#'
#' call this function prior to using any of the functions in this library
#' this perhaps should be called when the package loads and/or at beginning of most of the functions
#' usage
#'   stopifnot(set_azure_options())
#'  ... your code to work with azure
#' @return T/F depending on if az is setup and works.
#' If the values in Renviron, or sent as params are not valid, the options are not set
set_azure_options <- function(subid=NULL,azurerg=NULL){
  if(is.null(subid)){
    axuresub = Sys.getenv("AZURESUB")
  }

  subid = trimws(subid)

  # check that this is a value subid
  sub = get_sub(subid)
  # if not valid return false
  if(is.null(sub)) {return(FALSE)}
  # if valid, set option
  else {
    options('subid' = subid)
  }

  if(is.null(azurerg)){
    azurerg = Sys.getenv("AZURERG")
  }

  azurerg = trimws(azurerg)
  # check if this is a value rgname in this subid..
  rg <- get_rg(azurerg)
  if(is.null(rg)){ return(FALSE)}
  else {
  # if valid, set option
  options('azurerg' = azurerg)

  }

  return(TRUE)
}

#' get the azure subscription object for the given sub id value
#' can also be used to test if a the subid is valid (will return NULL)
#' requires Azure login and this function will initiate that
#' @param subid optional string of subscriptoin id e.g xxxxxxxx-xxx-xxx-xxxx-xxxxxxxxxxxx
#' @return AzureRMR subscription object, or NULL if invalid sub id
get_sub <- function(subid=getOption('subid')){
  azure_login<- AzureRMR::get_azure_login()
  sub <- tryCatch(test<-azure_login$get_subscription(subid),
                  error=function(cond){
                    print(cond)
                    return(NULL)}, finally=function(cond){return(test)})
  return(sub)

}

#' use global options or optional string parameter to get an AzureRMR resource_group object
#'
#' the goal of this function is to allow the other functions to be flexible and make sending
#' a resource group name optional by looking for global options
#' @return AzureRMR ResourceGroup object
get_rg <- function(rgname = getOption('azurerg'), subid=getOption('subid')) {
    # this will only ask for login if necessary
    # but it does recreate the object every time... perhaps cache these objects
  sub<- get_sub(subid)
    # one option for a cache is to compare the cached rg object's name with the string sent here
    # if they are different then load the new rg but otherwise return the cached rg
  if(! is.null(sub)){
    rg <- tryCatch(test<-sub$get_resource_group(rgname),
                   error=function(cond){
                     print(cond)
                     return(NULL)}, finally=function(cond){return(test)})
  } else {
    rg <- NULL
  }
  return(rg)
}

#' set options for the azure storage account to use for this session
#' @returns T/F if valid values were sent
set_storage_account <- function(){
  print("not implemented")
  return(FALSE)

}

