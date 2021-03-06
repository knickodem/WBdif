% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MH-Functions.R
\name{run_mh}
\alias{run_mh}
\title{MH test of DIF for single item}
\usage{
run_mh(item.data, dif.group.id, item, match.scores, match.bins = NULL)
}
\arguments{
\item{item.data}{data frame of dichotomous item responses with subjects in rows
and items in columns}

\item{dif.group.id}{factor vector of group membership for which DIF is evaluated.}

\item{item}{location of item in \code{item.data} to investigate for DIF}

\item{match.scores}{A numeric vector of match scores used as the stratifying variable in the MH procedure.}

\item{match.bins}{optional vector of bin sizes for stratifying \code{match.scores}.
This is passed to the \code{probs} argument of \code{\link[stats]{quantile}}.}
}
\value{
a \code{data.frame} of Mantel-Haenszel test results
}
\description{
Internal function for dif_mh
}
