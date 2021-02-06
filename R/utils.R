
#' Check if object is a SummarizedExperiment object
#'
#' @param object Object to test class.
#'
#' @return Logical indicating whether object is SummarizedExperiment or not.
#' @noRd
is_SE <- function(object) {
    if(class(object) == "SummarizedExperiment") {
        x <- TRUE
    } else {
        x <- FALSE
    }
    return(x)
}


#' Helper to handle SummarizedExperiment or expression data frame as input
#'
#' @param exp Expression data as a data frame or a SummarizedExperiment object
#'
#' @return If exp is a SummarizedExperiment object, it will return `assay(exp)`. Otherwhise, it will simply return exp as it is.
#' @noRd
#' @importFrom SummarizedExperiment assay
handleSE <- function(exp) {
    if(is_SE(exp)) {
        fexp <- SummarizedExperiment::assay(exp)
    } else {
        fexp <- exp
    }
    return(fexp)
}

#' Replace content of a SummarizedExperiment object based on filtered expression data frame
#'
#' @param exp Expression data frame with genes IDs in row names and samples in column names.
#' @param SE Original SummarizedExperiment object.
#' @return A SummarizedExperiment object
#' @noRd
#' @importFrom SummarizedExperiment SummarizedExperiment colData assay
exp2SE <- function(exp, SE) {

    # Get overlaps between samples in both sets
    SE_cols <- rownames(SummarizedExperiment::colData(SE))
    filt_exp_cols <- colnames(exp)
    overlap <- which(SE_cols %in% filt_exp_cols)

    # Modify original SE based on filtered expression data frame
    SE_final <- SummarizedExperiment::SummarizedExperiment(
        assays = exp,
        colData = SummarizedExperiment::colData(SE)[overlap, , drop=FALSE]
    )

    return(SE_final)
}


#' Generate custom color palette
#'
#' @param pal Numeric specifying palette number, from 1 to 3.
#'
#' @return Character vector of custom color palette with 20 colors
#' @noRd
custom_palette <- function(pal = 1) {
    pal1 <- c("#1F77B4FF", "#FF7F0EFF", "#2CA02CFF", "#D62728FF",
              "#9467BDFF", "#8C564BFF", "#E377C2FF", "#7F7F7FFF",
              "#BCBD22FF", "#17BECFFF", "#AEC7E8FF", "#FFBB78FF",
              "#98DF8AFF", "#FF9896FF", "#C5B0D5FF", "#C49C94FF",
              "#F7B6D2FF", "#C7C7C7FF", "#DBDB8DFF", "#9EDAE5FF")

    pal2 <- c("#3182BDFF", "#E6550DFF", "#31A354FF", "#756BB1FF",
              "#636363FF", "#6BAED6FF", "#FD8D3CFF", "#74C476FF",
              "#9E9AC8FF", "#969696FF", "#9ECAE1FF", "#FDAE6BFF",
              "#A1D99BFF", "#BCBDDCFF", "#BDBDBDFF", "#C6DBEFFF",
              "#FDD0A2FF", "#C7E9C0FF", "#DADAEBFF", "#D9D9D9FF")

    pal3 <- c("#393B79FF", "#637939FF", "#8C6D31FF", "#843C39FF",
              "#7B4173FF", "#5254A3FF", "#8CA252FF", "#BD9E39FF",
              "#AD494AFF", "#A55194FF", "#6B6ECFFF", "#B5CF6BFF",
              "#E7BA52FF", "#D6616BFF", "#CE6DBDFF", "#9C9EDEFF",
              "#CEDB9CFF", "#E7CB94FF", "#E7969CFF", "#DE9ED6FF")

    l <- list(pal1, pal2, pal3)
    l_final <- l[[pal]]
    return(l_final)
}


#' Wrapper to handle sample color annotation in heatmap
#'
#' @param col_metadata Sample annotation.
#' @param fexp Gene expression data frame
#'
#' @return List containing processed col_metadata, fexp and annotation_color.
#' @noRd
sample_cols_heatmap <- function(col_metadata, fexp) {
    col_names <- c("Sample group 1", "Sample group 2")
    if(is.data.frame(col_metadata)) {
        colnames(col_metadata) <- col_names[seq_along(col_metadata)]
        col_metadata <- col_metadata[order(col_metadata[, 1]), , drop=FALSE]
        fexp <- fexp[, rownames(col_metadata)]
        if(ncol(col_metadata) == 1) {
            colors1 <- custom_palette(1)[seq_along(unique(col_metadata[,1]))]
            annotation_color <- list(`Sample group 1` = colors1)
            names(annotation_color$`Sample group 1`) <- unique(col_metadata[,1])
        } else if(ncol(col_metadata) == 2) {
            colors1 <- custom_palette(1)[seq_along(unique(col_metadata[,1]))]
            colors2 <- custom_palette(2)[seq_along(unique(col_metadata[,2]))]
            annotation_color <- list(`Sample group 1` = colors1,
                                     `Sample group 2` = colors2)
            names(annotation_color$`Sample group 1`) <- unique(col_metadata[,1])
            names(annotation_color$`Sample group 2`) <- unique(col_metadata[,2])
        } else {
            stop("Maximum number of columns for col_metadata is 2.")
        }
    }

    if(!exists("annotation_color")) {
        annotation_color <- NA
    }
    results <- list(col_metadata = col_metadata,
                    fexp = fexp,
                    annotation_colors = annotation_color)
    return(results)

}


#' Wrapper to handle gene color annotation in heatmap
#'
#' @param row_metadata Gene annotation.
#' @param fexp Gene expression data frame.
#' @param annotation_color Object returned by \code{sample_cols_heatmap}.
#'
#' @return List containing processed row_metadata, fexp and annotation_color.
#' @noRd
gene_cols_heatmap <- function(row_metadata, fexp, annotation_color) {
    if(is.data.frame(row_metadata)) {
        colnames(row_metadata) <- "Gene annotation"
        row_metadata <- row_metadata[order(row_metadata[, 1]), , drop=FALSE]
        fexp <- fexp[rownames(row_metadata), ]
        if(!is.list(annotation_color)) {
            annotation_color <- list()
        }
        annotation_color$`Gene annotation` <- custom_palette(3)[
            seq_along(unique(row_metadata[,1]))
        ]
        names(annotation_color$`Gene annotation`) <- unique(row_metadata[,1])
    }

    results <- list(row_metadata = row_metadata,
                    fexp = fexp,
                    annotation_color = annotation_color)
    return(results)
}


#' Transform a correlation matrix to an edge list
#'
#' @param matrix Symmetrical correlation matrix.
#'
#' @return A 2-column data frame containing node 1, node 2 and edge weight
#' @export
#' @rdname cormat_to_edgelist
cormat_to_edgelist <- function(matrix) {
    edgelist <- matrix
    edgelist[lower.tri(edgelist, diag=TRUE)] <- NA
    edgelist <- na.omit(data.frame(as.table(edgelist), stringsAsFactors=FALSE))
    colnames(edgelist) <- c("Node1", "Node2", "Weight")
    edgelist$Node1 <- as.character(edgelist$Node1)
    edgelist$Node2 <- as.character(edgelist$Node2)
    edgelist$Weight <- as.numeric(edgelist$Weight)
    return(edgelist)
}


#' Check scale-free topology fit for a given network
#'
#' @param edgelist Edge list as a 2-column data frame containing node 1, node 2 and edge weight.
#' @param net_type Type of biological network. One of "gcn", "grn", or "ppi". Default: gcn.
#'
#' @rdname check_sft
#' @export
#' @importFrom igraph graph_from_data_frame as_adjacency_matrix fit_power_law
check_sft <- function(edgelist, net_type = "gcn") {

    # Calculate degree of the resulting graph
    if(net_type == "gcn") {
        graph <- igraph::graph_from_data_frame(edgelist, directed=FALSE)
        adj <- igraph::as_adjacency_matrix(graph, sparse = FALSE)
        diag(adj) <- 0
        degree <- apply(adj, 1, sum, na.rm=TRUE)
    } else if(net_type == "grn") {
        graph <- igraph::graph_from_data_frame(edgelist, directed=TRUE)
        degree <- igraph::degree(graph, mode = "out")
    } else if(net_type == "ppi") {
        graph <- igraph::graph_from_data_frame(edgelist, directed=FALSE)
        degree <- igraph::degree(graph, mode)
    } else {
        stop("Invalid network type. Please, input one of 'gcn', 'grn', or 'ppi'.")
    }

    # Test for scale-free topology fit
    test <- igraph::fit_power_law(degree)
    if(test$KS.p < 0.05) {
        message("At the 95% confidence level for the Kolmogorov-Smirnov statistic, your graph does not fit the scale-free topology. P-value:", test$KS.p)
    } else {
        message("Your graph fits the scale-free topology. P-value:", test$KS.p)
    }

    return(test)
}


























