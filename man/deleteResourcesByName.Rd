% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/azure_info.R
\name{deleteResourcesByName}
\alias{deleteResourcesByName}
\title{delete all resources with names that match a pattern}
\usage{
deleteResourcesByName(namePart, rgName = getOption("azurerg"), confirm = TRUE)
}
\value{
character vector of the names of resources deleted
}
\description{
since many cloning scripts create cllections of resources all with similar name
prefixes or suffixes, this lets us delete them all at once
}
