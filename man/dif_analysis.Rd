% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/DIF-Analysis.R
\name{dif_analysis}
\alias{dif_analysis}
\title{Differential item functioning}
\usage{
dif_analysis(
  dif.data,
  dif.methods = c("loess", "MH", "logistic", "IRT"),
  match.type = "Total",
  match.bins = NULL
)
}
\arguments{
\item{dif.data}{The output of \code{\link[WBdif]{dif_data_prep}}.}

\item{dif.methods}{A character \code{vector} with one or more of \code{c("loess", "MH", "logistic", "IRT")}. The default is all four methods.}

\item{match.type}{Οne of \code{c("Total", "Rest")}. Determines whether the total score or rest score should be used as the stratifying variable for loess, MH, and logistic regression methods.}

\item{match.bins}{(optional) vector of bin sizes for stratifying the matching variable in
the MH method. This is passed to the \code{probs} argument of \code{stas::quantile}.}
}
\value{
A \code{list} containing \code{dif.data} and the results from each selected method. The list is not formatted in a very readable way; it is intended to be passed to \code{\link[WBdif]{dif_models}} for further processing or to \code{\link[WBdif]{dif_report}} for user-friendly formatting.
}
\description{
Evaluates differential item functioning (DIF) using loess, Mantel-Haenszel (MH),
logistic regression, and item response theory (IRT) approaches.
}
\details{
This is a wrapper for the functions \code{\link[WBdif]{dif_loess}}, \code{\link[WBdif]{dif_mh}}, \code{\link[WBdif]{dif_logistic}}, and \code{\link[WBdif]{dif_irt}}. Runs the requested DIF analyses on \code{dif.data$item.data} using \code{dif.data$dif.group.id} as the conditioning variable.

Usage notes:
\itemize{
\item Dichotomous items must be coded 0 = incorrect, 1 = correct.
\item The Mantel-Haenszel and logistic methods can only accommodate dichotomous items.
\item Polytomous item responses are expected to be sequential integers (e.g., 1, 2, 3) but the lowest code does not have to be 0. Polytomous items are unit scaled when calculating the total or rest score.
\item Items with no variance are removed from \code{dif.data$item.data} when running the "MH", "logistic", and "IRT" methods.
\item Items with different number of response categories across levels of \code{dif.data$dif.group.id} are removed from \code{dif.data$item.data} for the "IRT" method.
}
}
\examples{
data("mdat")

# prep data
dif.data <- dif_data_prep(item.data = mdat`[`5:ncol(mdat)],
                             dif.group.id = mdat$gender,
                             na.to.0 = TRUE)

# DIF analysis by dif.group.id
# using rest scores and binning match scores by deciles to avoid empty cells in MH analysis
dif.analysis <- dif_analysis(dif.data = dif.data,
                           dif.methods =  c("MH", "IRT"),
                           match.type = "Rest",
                           match.bins = seq(0, 1, by = .1))
}
