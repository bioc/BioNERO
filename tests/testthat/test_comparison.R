
#----Load data------------------------------------------------------------------
set.seed(1)
data(og.zma.osa)
data(zma.se)
data(osa.se)

og <- og.zma.osa
explist <- list(osa = osa.se, zma = zma.se)
explist <- lapply(
    explist, exp_preprocess, Zk_filtering = FALSE,
    variance_filter = TRUE, n = 200
)
exp_ortho <- exp_genes2orthogroups(explist, og, summarize = "mean")

powers <- c(12, 7)
gcn_osa <- exp2gcn(
    exp_ortho$osa, net_type = "signed hybrid", SFTpower = powers[1],
    cor_method = "pearson"
)
gcn_zma <- exp2gcn(
    exp_ortho$zma, net_type = "signed hybrid", SFTpower = powers[2],
    cor_method = "pearson"
)


#----Start tests----
test_that("parse_orthofinder() parses OrthoFinder's orthogroups", {
    path <- system.file("extdata", "Orthogroups.tsv", package = "BioNERO",
                        mustWork = TRUE)
    og <- parse_orthofinder(path)
    expect_equal(ncol(og), 3)
})


test_that("exp_genes2orthogroups() replaces genes with orthogroups", {
    exp_ortho <- exp_genes2orthogroups(explist, og, summarize = "mean")
    expect_equal(length(exp_ortho), 2)
    expect_equal(class(exp_ortho), "list")
    expect_true(startsWith(rownames(exp_ortho[[1]])[1], "ORTH"))
})

test_that("modPres_WGCNA() calculates module preservation", {
    explist <- exp_ortho
    ref_net <- gcn_osa
    pres_wgcna <- modPres_WGCNA(explist, ref_net, nPerm = 2)
    expect_true("patchwork" %in% class(pres_wgcna))
    expect_true("ggplot" %in% class(pres_wgcna))
})

# PASSED on Feb 26, 2021.
# Commented because R CMD check was taking more than 10m.
# test_that("modPres_netrep() calculates module preservation", {
#     explist <- exp_ortho
#     ref_net <- gcn_osa
#     test_net <- gcn_zma
#     expect_message(pres_netrep <- modPres_netrep(explist, ref_net, test_net,
#                                                  nPerm=10, nThreads = 2),
#                    "None of the modules in osa were preserved in zma.")
# })

test_that("module_preservation() calculates module preservation", {

    explist <- exp_ortho
    names(explist) <- NULL
    ref_net <- gcn_osa
    test_net <- gcn_zma
    pres <- suppressWarnings(
        module_preservation(explist, ref_net, test_net, nPerm = 2)
    )
    pres_wgcna <- module_preservation(
        explist, ref_net, nPerm = 2, algorithm = "WGCNA"
    )

    ref_net$params$cor_method <- "biweight"
    pres_wgcna2 <- module_preservation(
        explist, ref_net, nPerm = 2, algorithm = "WGCNA"
    )

    ref_net$params$cor_method <- "spearman"
    pres_wgcna2 <- module_preservation(
        explist, ref_net, nPerm = 2, algorithm = "WGCNA"
    )

    expect_equal(class(pres), "list")
    expect_true("ggplot" %in% class(pres_wgcna))
    expect_error(module_preservation(
        explist, ref_net, nPerm = 2, algorithm = "wrong"
    ))
})








