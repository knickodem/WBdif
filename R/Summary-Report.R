#' Summarize DIF analysis and treatment effect robustness checks
#'
#' Conduct a DIF analysis, estimate treatment effect robustness, and produce report summarizing results
#'
#' @param dif.data The output of \code{\link[WBdif]{dif_data_prep}}.
#' @param file.name File name to create on disk. The file path can also be specified here. If the path is omitted, the file is saved to the working directory.
#' @param report.type A character indicating which type of report to produce: including both the DIF analysis results and treatment effect robustness checks ("dif.effects"; default), only DIF analysis ("dif.only"), or only treatment effect robustness checks ("effects.only").
#' @param report.format File format of the report. Default is HTML ("html_document"). See \code{\link[rmarkdown]{render}} for other options.
#' @param report.title An optional character string indicating the report title, which is printed in the report.
#' @param measure.name An optional character string naming the measure being evaluated, which is printed in the report.
#' @param dataset.name An optional character string naming the dataset used, which is printed in the report.
#' @param dif.methods A character \code{vector} with one or more of \code{c("loess", "MH", "logistic", "IRT")}. The default is all four methods.
#' @param biased.items Οne of \code{c("MH", "logistic", "IRT")}. Determines which DIF method should be used to identify biased items. Default is "IRT".
#' @param match.type Οne of \code{c("Total", "Rest")}. Determines whether the total score or rest score should be used as the stratifying variable for loess, MH, and logistic regression methods. Default is "Total".
#' @param match.bins An optional vector of bin sizes for stratifying the matching variable in the MH method. This is passed to the \code{probs} argument of \code{\link[stats]{quantile}}.
#' @param irt.scoring Factor score estimation method, which is passed to \code{\link[mirt]{fscores}}. Default is "WLE". See \code{\link[mirt]{fscores}} documentation for other options.
#'
#' @details
#' This function is a wrapper around \code{\link[WBdif]{dif_analysis}}, \code{\link[WBdif]{dif_models}}, \code{\link[WBdif]{effect_robustness}}, and \code{\link[WBdif]{dif_report}} in order to simplify report production when desired.
#'
#' @return a summary report of the DIF analysis, treatment effect robustness checks, or both
#'
#' @examples
#' data("mdat")
#'
#' # prep data
#' dif.data <- dif_data_prep(item.data = mdat`[`5:ncol(mdat)],
#'                           dif.group.id = mdat$gender,
#'                           tx.group.id = mdat$treated,
#'                           cluster.id = mdat$clusterid,
#'                           na.to.0 = TRUE)
#'
#' summary_report(dif.data = dif.data,
#'                file.name = "DIF-Effects-Gender-MDAT-Language",
#'                report.type = "dif.effects",
#'                report.title = "MDAT Language: Gender DIF and Tx Effects",
#'                measure.name = "MDAT Language")
#' @export

summary_report <- function(dif.data,
                           file.name,
                           report.type = "dif.effects",
                           report.format = "html_document",
                           report.title = file.name,
                           measure.name = "measure",
                           dataset.name = "dataset",
                           dif.methods = c("loess", "MH", "logistic", "IRT"),
                           biased.items = "IRT",
                           match.type  = "Total",
                           match.bins = NULL,
                           irt.scoring = "WLE"){

  ## Input checks
  if(!(biased.items %in% c("MH", "logistic", "IRT"))) {
    stop("biased.items must be one of c(\'MH\', \'logistic\', \'IRT\').")
  }

  if(report.type %in% c("dif.only", "dif.effects")){

    ## run dif_analysis
    dif.analysis <- dif_analysis(dif.data = dif.data,
                                 dif.methods = dif.methods,
                                 match.type = match.type,
                                 match.bins = match.bins)

    nodif <- is.character(dif.analysis[[biased.items]]$biased.items) # T if no diffy items
  }

  if(report.type == "dif.only" | nodif == TRUE){

    dif_report(dif.analysis = dif.analysis,
               file.name = file.name,
               biased.items = biased.items,
               report.format = report.format,
               report.title = report.title,
               measure.name = measure.name,
               dataset.name = dataset.name)


  } else {

    dif.models <- dif_models(dif.analysis = dif.analysis,
                             biased.items = biased.items)

    effect.robustness <- effect_robustness(dif.models = dif.models,
                                           irt.scoring = irt.scoring)

    if(report.type == "effects.only"){

      effect_report(dif.models = dif.models,
                    effect.robustness = effect.robustness,
                    file.name = file.name,
                    report.format = report.format,
                    report.title = report.title,
                    measure.name = measure.name,
                    dataset.name = dataset.name)

    } else {

      dif_effect_report(dif.analysis = dif.analysis,
                        dif.models = dif.models,
                        effect.robustness = effect.robustness,
                        file.name = file.name,
                        biased.items = biased.items,
                        report.format = report.format,
                        report.title = report.title,
                        measure.name = measure.name,
                        dataset.name = dataset.name)
    }

  }

}