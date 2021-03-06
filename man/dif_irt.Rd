% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/IRT-Functions.R
\name{dif_irt}
\alias{dif_irt}
\title{Item response theory DIF method}
\usage{
dif_irt(item.data, dif.group.id)
}
\arguments{
\item{item.data}{data frame of item responses with subjects in rows and items in columns}

\item{dif.group.id}{factor vector of group membership for which DIF is evaluated.}
}
\value{
A list containing
\itemize{
\item DIF model comparisons
\item item-level DIF tests
\item integer vector of the items showing DIF (i.e., biased items)
\item type of DIF
\item IRT models needed for treatment effect robustness check
}
}
\description{
Conducts DIF analysis using an item response theory approach
}
\details{
First conducts an omnibus test of DIF by comparing the fit of no DIF, uniform DIF, and non-uniform DIF 2PL IRT models.
The models are run \code{\link[mirt]{multipleGroup}} by constraining slopes
and intercepts, slopes only, and nothing, respectively, to be equal
between the levels of \code{dif.group.id}. Model fit is compared with a
likelihood ratio test. If DIF is detected through the model comparisons, the
specific item(s) with DIF are identified in a two-stage process (initial and refinement) using \code{\link[mirt]{DIF}}.
}
