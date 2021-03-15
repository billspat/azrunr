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

#' access an existing login to azure or create a new one
#' if a new login is to be created, there will be a link pasted in the console
#' that must be visited, instructions are displayed in the console as well
#'
#' The getOption "login" will be set to this object, used in other functions
#' @return the azure login
set_azure_login <- function() {
  login <- tryCatch(test<-AzureRMR::get_azure_login(),
           error=function(cond){
             return(AzureRMR::create_azure_login())}, finally=function(cond){return(test)})
  options("login" = login)
}

#' read azure defaults from the environment to set package options.
#'
#'
#' call this function prior to using any of the functions in this library
#' this perhaps should be called when the package loads and/or at beginning of most of the functions
#' usage
#'   stopifnot(set_azure_options())
#'  ... your code to work with azure
#'
#' The parameters can be explicitly set using this function
#' otherwise the values set in the .Renviron file
#' will be used.
#'
#' If the values in Renviron, or sent as params are not valid, the options are not set
#' @param azuresub the azure subscription ID of the user
#' @param azurerg the name of the resource group to be used
#' @param azureuser the azure username of the user
#' @param azurestor the name of the storage account to be used
#' @param azurecontainer the name of the storage container to be used
#' @param storageaccesskey the storage access key for the storage account to be used, found in the portal under "Access keys" in the storage account menu
#' @param verbose TRUE/FALSE run in verbose mode.
#' @return T/F depending on if az is setup and works.
set_azure_options <- function(azuresub=NULL,azurerg=NULL,azureuser=NULL, azurestor=NULL, azurecontainer=NULL, storageaccesskey=NULL, verbose=FALSE){

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
    warning("Invalid subscription ID")
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
    warning("Invalid resource group ")
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


  ##### STORAGE ACCOUNT
  if(is.null(azurestor)){
    azurestor = Sys.getenv("AZURESTOR")
  }
  if(azurestor != ""){
    azurestor = trimws(azurestor)
    # check if this is a valid azurestor in this azuresub.
    stor <- get_stor(azurestor)
    if(is.null(stor)){
      warning("Invalid storage account name")
      return(FALSE)}
    else {
      # if valid, set option
      options('azurestor' = azurestor)
    }
  }

  ##### CONTAINER NAME
  if(is.null(azurecontainer)){
    azurecontainer = Sys.getenv("AZURECONTAINER")
  }

  if(azurecontainer != ""){
    azurecontainer = trimws(azurecontainer)
    # check if this is a valid azurecontainer in this azurestor
    cont <- get_container(azurecontainer)
    if(is.null(cont)){
      warning("Invalid container name")
      return(FALSE) }
    else {
      options('azurecontainer'=azurecontainer)
    }
  }

  ##### STORAGE ACCESS KEY
  # check somehow if possible, may not be
  if(is.null(storageaccesskey)){
    storageaccesskey = Sys.getenv("STORAGEACCESSKEY")
  }
  storageaccesskey = trimws(storageaccesskey)
  options('storageaccesskey'=storageaccesskey)


  if(verbose){
    message(paste0("set options azuresub=",getOption('azuresub'),"azurerg=",getOption('azurerg'), "and azureuser=",getOption('azureuser')))
    message(paste0("set options azurestor=",getOption('azurestor'),"azurecontainer=",getOption('azurecontainer'), "and storageaccesskey=",getOption('storageaccesskey')))
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
  sub <- tryCatch(test<-getOption("login")$get_subscription(azuresub),
                  error=function(cond){
                    print(cond)
                    return(NULL)}, finally=function(cond){return(test)})
  return(sub)

}

#' use global options or optional string parameter to get an AzureRMR resource_group object
#'
#' the goal of this function is to allow the other functions to be flexible and make sending
#' a resource group name optional by looking for global options
#' @param rgname the name of the resource group, defaults to the getoption
#' @param azuresub the azure subscription ID of the user, defaults to the getoption
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


#' get the storage account object
#'
#' @param azurestor the name of the storage account, defaults to the getoption
#' @param rgname the name of the resource group, defaults to the getoption
#' @return the storage account object, null if it doesn't exist
get_stor <- function(azurestor = getOption('azurestor'), rgname = getOption('azurerg'))
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

#' get the container object
#'
#' @param azurecontainer the name of the container, defaults to the getoption
#' @param azurestor the name of the storage account, defaults to the getoption
#' @param rgname the name of the resource group, defaults to the getoption
#' @param storageaccesskey the storage access key for the given storage account, defaults to the getoption
#' @return the container object, null if it doesn't exist
get_container <- function(azurecontainer=getOption('azurecontainer'), azurestor=getOption('azurestor'), rgname=getOption('azurerg'), storageaccesskey=getOption('storageaccesskey'))
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

