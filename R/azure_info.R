# azureInfo.R
# get information and status about specific Azure resources (relevant to running batch VMs)


# previous standalone code had this
# library(AzureVM)
# library(AzureRMR)
# library(AzureStor)
# library(stringr)


allResourceNames <- function(rgName = getOption('azurerg')){
    rg<-get_rg(rgName)
    # get a vector of the names of resources, each vector item named for the type of resource
    resourcenames <- unlist(lapply(rg$list_resources(), function(x){x$name}))
    return(resourcenames)

}

storageAccounts <- function(rgName = getOption('azurerg')){
    # return a list of all storage accounts.  From one you can get a list of containers
    rg<-get_rg(rgName)
    return(rg$list_resources(filter="resourceType eq 'Microsoft.Storage/storageAccounts'"))
}

listContainers <- function(storageAccount, rgName = getOption('azurerg')){
    rg<-get_rg(rgName)
    storageObject <- rg$get_storage(storageAccount)
    be <- storageObject$get_blob_endpoint()
    se <- storage_endpoint(be$url, be$key)
    return(list_storage_containers(se))

}

listAllContainers <- function( rgName =getOption('azurerg') ) {
    rg <- get_rg(rgName)
    sa <- storageAccounts(rg)
    containerlist <- lapply(sa, rg=rg, listContainers)
}

getResourcesByName <- function(namePart, rgName = getOption('azurerg') ){
    rg<-get_rg(rgName)
    resources <- rg$list_resources(filter=paste0("substringof('", namePart, "', name)"))
    return(resources)
    # all_names <- rg$list_resources()
    # get a vector of the names of resources, each vector item named for the type of resource
    # all_names <- unlist(lapply(all_resources, function(x){x$name}))
    # these names <- all_resources[grep(namePattern, all_names)])
}

resourceNameList <- function(resources){
    all_names <- unlist(lapply(resources, function(x){x$name}))
    return(all_names)
}



### move to another script
#' delete all resources with names that match a pattern
#'
#' since many cloning scripts create cllections of resources all with similar name
#' prefixes or suffixes, this lets us delete them all at once
#' @return character vector of the names of resources deleted
deleteResourcesByName <- function(namePart, rgName = getOption('azurerg'), confirm=TRUE ) {
    # $filter=substringof('demo', name)
    rg<-get_rg(rgName)

    resources <- getResourcesByName(namePart)
    deleted_resources <- c('')

    if(confirm) {
        print(paste0(resourceNameList(resources)))
        answer <-  readline(prompt="confirm delete these resources? type 'Yes' ")
    } else { answer <- 'Yes'}

    if(answer == 'Yes' || answer == 'yes'){
        for(r in resources){
            print(paste('deleting resource...', r$name))
            #TODO trycatch()
            r$delete(confirm=FALSE)
            append(deleted_resources, r$name)
            #TODO check tag for Sys.info()['user']
        }

    } else {
        message("deletion cancelled")
    }
    # vector of names
    return(deleted_resources)
}

