% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Summary-Report.R
\name{summary_report}
\alias{summary_report}
\title{Summarize DIF analysis and treatment effect robustness checks}
\usage{
summary_report(
  dif.data,
  file.name,
  report.type = "dif.effects",
  report.format = "html_document",
  report.title = file.name,
  measure.name = "measure",
  dataset.name = "dataset",
  dif.methods = c("loess", "MH", "logistic", "IRT"),
  biased.items = "IRT",
  match.type = "Total",
  match.bins = NULL,
  irt.scoring = "WLE"
)
}
\arguments{
\item{dif.data}{The output of \code{\link[WBdif]{dif_data_prep}}.}

\item{file.name}{File name to create on disk. The file path can also be specified here. If the path is omitted, the file is saved to the working directory.}

\item{report.type}{A character indicating which type of report to produce: including both the DIF analysis results and treatment effect robustness checks ("dif.effects"; default), only DIF analysis ("dif.only"), or only treatment effect robustness checks ("effects.only").}

\item{report.format}{File format of the report. Default is HTML ("html_document"). See \code{\link[rmarkdown]{render}} for other options.}

\item{report.title}{An optional character string indicating the report title, which is printed in the report.}

\item{measure.name}{An optional character string naming the measure being evaluated, which is printed in the report.}

\item{dataset.name}{An optional character string naming the dataset used, which is printed in the report.}

\item{dif.methods}{A character \code{vector} with one or more of \code{c("loess", "MH", "logistic", "IRT")}. The default is all four methods.}

\item{biased.items}{Οne of \code{c("MH", "logistic", "IRT")}. Determines which DIF method should be used to identify biased items. Default is "IRT".}

\item{match.type}{Οne of \code{c("Total", "Rest")}. Determines whether the total score or rest score should be used as the stratifying variable for loess, MH, and logistic regression methods. Default is "Total".}

\item{match.bins}{An optional vector of bin sizes for stratifying the matching variable in the MH method. This is passed to the \code{probs} argument of \code{\link[stats]{quantile}}.}

\item{irt.scoring}{Factor score estimation method, which is passed to \code{\link[mirt]{fscores}}. Default is "WLE". See \code{\link[mirt]{fscores}} documentation for other options.}
}
\value{
a summary report of the DIF analysis, treatment effect robustness checks, or both
}
\description{
Conduct a DIF analysis, estimate treatment effect robustness, and produce report summarizing results
}
\details{
This function is a wrapper around \code{\link[WBdif]{dif_analysis}}, \code{\link[WBdif]{dif_models}}, \code{\link[WBdif]{effect_robustness}}, and \code{\link[WBdif]{dif_report}} in order to simplify report production when desired.
}
\examples{
data("mdat")

# prep data
dif.data <- dif_data_prep(item.data = mdat`[`5:ncol(mdat)],
                          dif.group.id = mdat$gender,
                          tx.group.id = mdat$treated,
                          cluster.id = mdat$clusterid,
                          na.to.0 = TRUE)

summary_report(dif.data = dif.data,
               file.name = "DIF-Effects-Gender-MDAT-Language",
               report.type = "dif.effects",
               report.title = "MDAT Language: Gender DIF and Tx Effects",
               measure.name = "MDAT Language")
}
