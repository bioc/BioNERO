% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gcn_inference.R
\name{exp2gcn_blockwise}
\alias{exp2gcn_blockwise}
\title{Infer gene coexpression network from gene expression in a blockwise manner}
\usage{
exp2gcn_blockwise(
  exp,
  net_type = "signed",
  module_merging_threshold = 0.8,
  SFTpower = NULL,
  cor_method = "pearson",
  TOM_type = NULL,
  max_block_size = 5000,
  min_module_size = 30,
  ...
)
}
\arguments{
\item{exp}{Either a `SummarizedExperiment` object, or a gene expression
matrix/data frame with genes in row names and samples in column names.}

\item{net_type}{Character indicating the type of network to infer.
One of 'signed', 'signed hybrid' or 'unsigned'. Default: 'signed'.}

\item{module_merging_threshold}{Numeric indicating the minimum correlation
threshold to merge similar modules into a single one. Default: 0.8.}

\item{SFTpower}{Numeric scalar indicating the value of the \eqn{\beta}
power to which correlation coefficients will be raised to ensure
scale-free topology fit. This value can be obtained with
the function \code{SFT_fit()}.}

\item{cor_method}{Character with correlation method to use.
One of "pearson" or "biweight". Default: "pearson".}

\item{TOM_type}{Character specifying the method to use to calculate a
topological overlap matrix (TOM). If NULL, TOM type will be automatically
inferred from network type specified in \strong{net_type}. Default: NULL.}

\item{max_block_size}{Numeric indicating the maximum block size for module
detection.}

\item{min_module_size}{Numeric indicating the minimum module size.
Default: 30.}

\item{...}{Additional arguments to \code{WGCNA::blockwiseModules()}.}
}
\value{
A list containing the following elements: \itemize{
  \item \emph{MEs} Data frame of module eigengenes, with samples
  in rows, and module eigengenes in columns.
  \item \emph{genes_and_modules} Data frame with columns 'Genes' (character)
  and 'Modules' (character) indicating the genes and the modules to
  which they belong.
  \item \emph{params} List with network inference parameters passed
  as input.
  \item \emph{dendro_plot_objects} List with objects to plot the dendrogram
  in \code{plot_dendro_and_colors}. Elements are named 'tree' (an hclust
  object with gene dendrogram), 'Unmerged' (character with per-gene module
  assignments before merging similar modules), and 'Merged' (character
  with per-gene module assignments after merging similar modules).
}
}
\description{
Infer gene coexpression network from gene expression in a blockwise manner
}
\examples{
data(filt.se)
# The SFT fit was previously calculated and the optimal power was 16
cor <- WGCNA::cor
gcn <- exp2gcn_blockwise(
    exp = filt.se, SFTpower = 18, cor_method = "pearson"
)
}
\author{
Fabricio Almeida-Silva
}
