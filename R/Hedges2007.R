#' Estimate standardized treatment effects
#'
#' Computes treatment effects standardized by the "total variance", and their standard errors, using the method described by Hedges (2007).
#'
#' @param outcome A numeric \code{vector} containing the outcome variable.
#' @param tx.group.id A \code{vector} of \code{length(outcome)} indicating the treatment groups.
#' @param std.group An optional value of \code{tx.group.id} that identifies the group whose standard deviation will be used to standardize the treatment effect. If \code{NULL} (default), the pooled standard deviation is used.
#' @param cluster.id An optional \code{vector} of \code{length(outcome)} indicating the primary sampling unit in a multi-stage / clustered sampling design.
#' @param subset An optional logical \code{vector} of \code{length(outcome)} indicating a subset of the data to use in the calculations.
#'
#' @details
#' Standardized treatment effects and their standard errors are computed using Equations 15 and 16 of Hedges (2007); unequal cluster sizes are replaced with their average as computed in Equation 19.
#'
#' @return
#' A \code{vector} containing the standardized treatment effect and its standard error.
#'
#' @references
#' Hedges, L. V. (2007). Effect sizes in cluster-randomized designs. \emph{Journal of Educational and Behavioral Statistics, 32}(4), 341–370. \url{https://doi.org/10.3102/1076998606298043}.
#'
#' @export

hedges2007 <- function(outcome, tx.group.id, std.group = NULL, cluster.id = NULL, subset = NULL) {

  if(!is.null(std.group)){
    std.group <- as.character(std.group) # in case numeric is supplied
  }
  tx.groups <- get_tx.groups(tx.group.id, std.group)

  if (!is.null(subset)) {
    if (length(subset) != length(outcome)) {
      warnings("subset is not the same length as outcome.")
    }
    outcome <- outcome[subset]
    tx.group.id <- tx.group.id[subset]
    cluster.id <- cluster.id[subset]
  }

  # when cluster.id = NULL, icc = cluster.n = 0
  icc <- get_icc(outcome, cluster.id)
  cluster.n <- get_avg_cluster_n(tx.group.id, cluster.id)

  SD <- get_sd(outcome, tx.group.id, std.group)
  M <- tapply(outcome, tx.group.id, mean, na.rm = T)
  N <- table(tx.group.id)
  NT <- sum(N)

  # Effect size (Hedges 2007 Eq 15)
  coeff <-  1 - (2 * (cluster.n - 1) * icc) / (NT - 2)
  effect.size <- (M[tx.groups[2]] - M[tx.groups[1]]) / SD * coeff

  # Effect size SE (Hedges 2007 Eq 16)
  part1 <- NT / N[1] / N[2] * (1 + (cluster.n - 1) * icc)
  part2.num <- (NT - 2) * (1 - icc)^2 + cluster.n * (NT - 2 * cluster.n) * icc^2 +
    2 * (NT - 2 * cluster.n ) * icc * (1 - icc)
  part2.denom <- 2 * (NT - 2) * ((NT - 2) - 2 * (cluster.n - 1) * icc)
  effect.size.se <- sqrt(part1 + effect.size^2 * part2.num / part2.denom)

  names(effect.size) <- names(effect.size.se) <- NULL # sigh
  return(c(effect.size = effect.size, effect.size.se = effect.size.se))
}

#' Estimate the intraclass correlation (ICC)
#'
#' Helper function for \code{hedges2007} that requires \code{lme4}.
#'
#' @param outcome A numeric \code{vector} containing the outcome variable.
#' @param cluster.id An optional \code{vector} of \code{length(outcome)} indicating the primary sampling unit in a multi-stage / clustered sampling design.
#' @return
#' The ICC; returns 0 if \code{is.null(cluster.id)}.

get_icc <- function(outcome, cluster.id) {
  if (!is.null(cluster.id)) {
    variances <- lme4::VarCorr(lme4::lmer(outcome ~ 1 + (1|cluster.id)))
    variances <- c(as.numeric(variances), attr(variances, "sc")^2)
    icc <- variances[[1]] / sum(variances)
  } else {
    icc <- 0
  }
 return(icc)
}


#' Compute average cluster size
#'
#' Helper function for \code{hedges2007} that computes Equation 19 of Hedges (2007).
#'
#' @param tx.group.id A \code{vector} of indicating the treatment groups.
#' @param cluster.id An optional \code{vector} of \code{length(group.id)} indicating the primary sampling unit in a multi-stage / clustered sampling design.
#' @return
#' The average cluster size; returns 0 if \code{is.null(cluster.id)}.

get_avg_cluster_n <- function(tx.group.id, cluster.id) {
  # Hedges 2007 Equation 19
  if (!is.null(cluster.id)) {
    N  <- table(tx.group.id)
    cluster.n1 <- table(cluster.id[tx.group.id == names(N)[1]])
    n1 <- (N[1]^2 - sum(cluster.n1^2)) / (N[1] * (length(cluster.n1) - 1))
    cluster.n2 <- table(cluster.id[tx.group.id == names(N)[2]])
    n2 <- (N[2]^2 - sum(cluster.n2^2)) / (N[2] * (length(cluster.n2) - 1))
    avg.cluster.n <- mean(c(n1, n2))

    #avg.cluster.n = NaN if only 1 cluster per group...
    if(is.nan(avg.cluster.n)){
      avg.cluster.n <- 0
    }
  } else {
    avg.cluster.n <- 0
  }
  return(avg.cluster.n)
}

#' Computes the pooled standard deviation
#'
#' Helper function for \code{hedges2007}.
#'
#' @param outcome A numeric \code{vector} containing the outcome variable.
#' @param tx.group.id A \code{vector} of \code{length(outcome)} indicating the treatment groups.
#' @param std.group An optional value of \code{tx.group.id} that identifies the group whose standard deviation will be used to standardize the treatment effect. If \code{NULL} (default), the pooled standard devaition is used.
#' @return If \code{is.null(std.group)}, returns the pooled standard deviation; else returns the standard deviation of \code{std.group}.

get_sd <- function(outcome, tx.group.id, std.group = NULL){
  N <- table(tx.group.id)
  Var <- tapply(outcome, tx.group.id, var, na.rm = T)

  if (is.null(std.group)) {
    SD <- sqrt(((N[1] - 1) * Var[1] + (N[2] - 1) * Var[2]) / (sum(N) - 2))
  } else {
    SD <- sqrt(Var[std.group])
  }
  return(SD)
}