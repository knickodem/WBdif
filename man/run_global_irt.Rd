% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/IRT-Functions.R
\name{run_global_irt}
\alias{run_global_irt}
\title{IRT Model Comparisons for DIF}
\usage{
run_global_irt(item.data, dif.group.id)
}
\arguments{
\item{item.data}{data frame of item responses with subjects in rows
and items in columns}

\item{dif.group.id}{factor vector of group membership for which DIF is evaluated.}
}
\value{
A list containing model comparison results table, the type of DIF, and the model objects
}
\description{
Conduct an omnibus test for DIF by comparing no DIF, uniform DIF, and non-uniform DIF IRT models
}
