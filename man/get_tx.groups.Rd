% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Helper-Functions.R
\name{get_tx.groups}
\alias{get_tx.groups}
\title{Tries to guess the control group and checks for input errors}
\usage{
get_tx.groups(tx.group.id, std.group)
}
\arguments{
\item{tx.group.id}{A \code{vector} indicating the treatment groups.}

\item{std.group}{An optional value of \code{tx.group.id} that identifies the group whose standard deviation will be used to standardize the treatment effect.}
}
\value{
A vector containing the two unique values of \code{tx.group.id}, with the name of the control group in the first position, and the name of the treatment group in the second position.
}
\description{
Helper function for \code{hedges2007}.
}
