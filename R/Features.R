#' SummarizeHVF
#'
#' @param x Seurat object.
#'
#' @export
#'
SummarizeHVF <- function(x) {
  if (inherits(x, "Seurat")) x <- list(Seurat = x)
  total_datasets <- length(x)
  x <- lapply(names(x), function(n) {
    tibble(dataset = n, feature = VariableFeatures(x[[n]]))
  }) %>% bind_rows()
  total_features <- length(unique(x$feature))
  x %>% gather(dataset, feature) %>% count(feature, sort = TRUE, name = "n_datasets") %>% count(n_datasets, name = "n_features") %>% mutate(total_datasets = total_datasets, percentage_datasets = n_datasets / total_datasets, total_features = total_features, percentage_features = 100 * n_features / total_features, cumsum_features = rev(cumsum(rev(n_features))), cumsum_percentage_features = rev(cumsum(rev(percentage_features)))) %>% select(n_datasets, total_datasets, percentage_datasets, n_features, cumsum_features, total_features, percentage_features, cumsum_percentage_features)
}


#' TabulateHVF
#'
#' @param x Seurat object.
#'
#' @export
#'
TabulateHVF <- function(x) {
  if (inherits(x, "Seurat")) x <- list(Seurat = x)
  lapply(names(x), function(n) {
    tibble(dataset = n, feature = VariableFeatures(x[[n]]), n = 1)
  }) %>% bind_rows() %>%
    group_by(feature) %>% mutate(total = sum(n)) %>%
    spread(dataset, n, fill = 0)
}

#' IntersectFeatures
#'
#' @param x Seurat object.
#' @param assay assay name.
#' @param slot slot name.
#' @param use.hvf whether to use HVF.
#' @param cutoff cutoff for gene expression.
#'
#' @export
#'
IntersectFeatures <- function(x, assay = "RNA", slot = "data", use.hvf = TRUE, cutoff = 0) {
  features <- lapply(names(x), function(n) {
    if (use.hvf) {
      return(VariableFeatures(x[[n]]))
    } else {
      tmp <- GetAssayData(x[[n]], assay = assay, slot = slot)
      return(rownames(tmp)[rowSums(tmp) > cutoff] )
    }
  })
  Reduce(intersect, features)
}
