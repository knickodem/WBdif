% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Hedges2007.R
\name{hedges2007}
\alias{hedges2007}
\title{Estimate standardized treatment effects}
\usage{
hedges2007(
  outcome,
  tx.group.id,
  std.group = NULL,
  cluster.id = NULL,
  subset = NULL
)
}
\arguments{
\item{outcome}{A numeric \code{vector} containing the outcome variable.}

\item{tx.group.id}{A \code{vector} of \code{length(outcome)} indicating the treatment groups.}

\item{std.group}{An optional value of \code{tx.group.id} that identifies the group whose standard deviation will be used to standardize the treatment effect. If \code{NULL} (default), the pooled standard deviation is used.}

\item{cluster.id}{An optional \code{vector} of \code{length(outcome)} indicating the primary sampling unit in a multi-stage / clustered sampling design.}

\item{subset}{An optional logical \code{vector} of \code{length(outcome)} indicating a subset of the data to use in the calculations.}
}
\value{
A \code{vector} containing the standardized treatment effect and its standard error.
}
\description{
Computes treatment effects standardized by the "total variance", and their standard errors, using the method described by Hedges (2007).
}
\details{
Standardized treatment effects and their standard errors are computed using Equations 15 and 16 of Hedges (2007); unequal cluster sizes are replaced with their average as computed in Equation 19.
}
\references{
Hedges, L. V. (2007). Effect sizes in cluster-randomized designs. \emph{Journal of Educational and Behavioral Statistics, 32}(4), 341–370. \url{https://doi.org/10.3102/1076998606298043}.
}
