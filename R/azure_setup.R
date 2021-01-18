#' azure_setup.R
#' DRAFT
#' functions to simplify set up Azure options for the azuresub and subscription
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
set_azure_options <- function(azuresub=NULL,azurerg=NULL,azureuser=NULL, verbose=FALSE){

  ### SUBCRIPTION
  if(is.null(azuresub)){
    # not sent as a parameter, look to the environment (e.g. .Renviron)
    azuresub <- Sys.getenv("AZURESUB")
  }

  # if it's not passed as an argument, and not in the environment, fail

  azuresub <- trimws(azuresub)

  # check that this is a value azuresub
  # get sub could use an existing log-in if it's not set in environment or here.
  # passing a new sub-id to this will re-login
  sub = get_sub(azuresub)

  # if not valid, or not setup, fail
  if(is.null(sub)) {
    warning("no valid subscription found")
    return(FALSE)}

  # if valid, set option
  else {
    options('azuresub' = azuresub)
  }


  #### RESOURCE GROUP
  if(is.null(azurerg)){
    # not sent as a parameter, look to the environment (e.g. .Renviron)
    azurerg = Sys.getenv("AZURERG")
  }

  azurerg = trimws(azurerg)
  # check if this is a value rgname in this azuresub..
  rg <- get_rg(azurerg)

  # if it's not passed as an argument, and not in the environment, fail
  if(is.null(rg)){
    warning("no valid resource group ")
    return(FALSE)}
  else {
  # if valid, set option
  options('azurerg' = azurerg)

  }


  ##### USER ACCOUNT
  # this is a required setting and must at least be in the environment
  # it's used when creating VMS.

  if(is.null(azureuser)){
    # not sent as a parameter, look to the environment (e.g. .Renviron)
    azureuser <- Sys.getenv("AZUREUSER")  # AZUREUSER
  }
  # if it's not passed as an argument, and not in the environment, fail
  if(is.null(azureuser)){
    warning("no user name was sent, and none in Environment (AZUREUSER)")
    return(FALSE)
  }

  azureuser = trimws(azureuser)

  #TODO check that this is a valid azure user for this subscription
  # for now, assume it is.  It's used for creating log-ins for VMs
  # so for now, with no check, the VM user may not match the Azure portal user id
  options('azureuser' = azureuser)


  ##### optional ssh key
  if(!is.null(Sys.getenv("AZURESSHKEY"))) {
    options('azuresshkey'= Sys.getenv("AZURESSHKEY"))
  }


  if(verbose){
    message(paste0("set options azuresub=",getOption('azuresub'),"azurerg=",getOption('azurerg'), "and azureuser=",getOption('azureuser')))
    if(!is.null(getOption('azuresshkey'))){
      message("set VM ssh key")
    }
  }


  return(TRUE)
}

#' get the azure subscription object for the given sub id value
#' can also be used to test if a the azuresub is valid (will return NULL)
#' requires Azure login and this function will initiate that
#' @param azuresub optional string of subscriptoin id e.g xxxxxxxx-xxx-xxx-xxxx-xxxxxxxxxxxx
#' @return AzureRMR subscription object, or NULL if invalid sub id
get_sub <- function(azuresub=getOption('azuresub')){
  azure_login<- AzureRMR::get_azure_login()
  sub <- tryCatch(test<-azure_login$get_subscription(azuresub),
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
get_rg <- function(rgname = getOption('azurerg'), azuresub=getOption('azuresub')) {
    # this will only ask for login if necessary
    # but it does recreate the object every time... perhaps cache these objects


  if(is.null(rgname)) {
    # if rgname is not sent as a param, and if the option is not set => set_azure_options has not been run yet.
    # try to run azure setup now (which may ask for a log-in)

    # TODO this returns "NULL" if can't get a rg, should it return FALSE instead?

    if (set_azure_options() == FALSE){
      # couldn't run setup, so no RG can be gotten
      # TODO raise exception?
      return(NULL)}
  }

  sub<- get_sub(azuresub)
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

#' set options for the azure storage account to use for this session
#' @returns T/F if valid values were sent
set_storage_options <- function(azurestorage=NULL, azurecontainer=NULL, storageaccesskey=NULL){
  if(is.null(azurestorage)){
    azurestorage = Sys.getenv("AZURESTOR")
  }

  azurestorage = trimws(azurestorage)
  # check if this is a valid azurestorage in this azuresub.
  stor <- get_stor(azurestorage)
  if(is.null(stor)){ return(FALSE)}
  else {
    # if valid, set option
    options('azurestorage' = azurestorage)
  }
  # Unsure what is going to be in the Renv for now, so having container be one
  if(is.null(azurecontainer)){
    azurecontainer = Sys.getenv("AZURECONTAINER")
  }

  azurecontainer = trimws(azurecontainer)
  # check if this is a valid azurecontainer in this azurestorage
  cont <- get_container(azurecontainer)
  if(is.null(cont)){ return(FALSE) }
  else {
    options('azurecontainer'=azurecontainer)
  }
  if(is.null(storageaccesskey)){
      storageaccesskey = Sys.getenv("STORAGEACCESSKEY")
  }
  storageaccesskey = trimws(storageaccesskey)
  options('storageaccesskey'=storageaccesskey)
  return(TRUE)

}

get_stor <- function(azurestor = getOption('azurestorage'), rgname = getOption('azurerg'))
{
  if (is.null(azurestor))
  {
    # The storage account has not been set by anything
  }
  # this is assuming that the sub has been set already
  rg <- get_rg(rgname)
  if(! is.null(rg)){
    stor <- tryCatch(test<-rg$get_resource(type="Microsoft.Storage/storageAccounts", name=azurestor),
                     error=function(cond){
                       print(cond)
                       return(NULL)}, finally=function(cond){return(test)})
  } else {
    stor <- NULL
    }
  return(stor)
}

get_container <- function(azurecontainer=getOption('azurecontainer'), azurestor=getOption('azurestorage'), rgname=getOption('azurerg'), storageaccesskey=getOption('storageaccesskey'))
{
  if (is.null(azurecontainer))
  {
    # The container has not been set by anything
  }
  rg<-get_rg(rgname)
  if(! is.null(rg)){
    stor <- get_stor(azurestor)
    if(! is.null(stor)){
      se <- AzureStor::storage_endpoint(stor$properties$primaryEndpoints$blob, key=storageaccesskey) # This cannot be the token, must be the storage account access key
      cont <- tryCatch(test<-AzureStor::storage_container(se, azurecontainer),
                       error=function(cond){
                         print(cond)
                         return(NULL)}, finally=function(cond){return(test)})
    } else {
      cont <- NULL
    }
  }
  return(cont)
}

