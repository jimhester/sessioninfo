
context("package_info")

test_that("package_info, loaded", {

  descs <- readRDS("fixtures/devtools-deps.rda")
  alldsc <- readRDS("fixtures/descs.rda")

  mockery::stub(package_info, "loaded_packages", descs)
  mockery::stub(
    package_info,
    'utils::packageDescription',
    function(x) alldsc[[x]]
  )

  pi <- package_info()
  exp <- readRDS("fixtures/devtools-info.rda")
  expect_identical(pi, exp)
})

test_that("package_info, dependent", {

  descs <- readRDS("fixtures/devtools-deps.rda")
  alldsc <- readRDS("fixtures/descs.rda")

  mockery::stub(package_info, "dependent_packages", descs)
  mockery::stub(
    package_info,
    'utils::packageDescription',
    function(x) alldsc[[x]]
  )

  pi <- package_info("devtools")
  exp <- readRDS("fixtures/devtools-info.rda")
  expect_identical(pi, exp)
})

test_that("pkg_date", {
  crayon <- readRDS("fixtures/descs.rda")$crayon
  expect_equal(pkg_date(crayon), "2016-06-28")

  crayon$`Date/Publication` <- NULL
  expect_equal(pkg_date(crayon), "2016-06-29")

  crayon$`Built` <- NULL
  expect_identical(pkg_date(crayon), NA_character_)
})

test_that("pkg_source", {
  descs <- readRDS("fixtures/descs.rda")

  expect_identical(
    pkg_source(descs$debugme),
    "Github (gaborcsardi/debugme@df8295a)"
  )

  expect_identical(pkg_source(descs$curl), "CRAN (R 3.3.3)")

  biobase <- readRDS("fixtures/biobase.rda")
  expect_identical(pkg_source(biobase), "Bioconductor")

  memoise <- readRDS("fixtures/memoise.rda")
  expect_identical(pkg_source(memoise), "cran (@1.1.0)")
})

test_that("pkg_source edge case, remote repo, but no RemoteSha", {
  desc <- readRDS("fixtures/no-sha.rda")
  expect_identical(pkg_source(desc), "github (r-pkgs/desc)")
})

test_that("pkg_source edge case, remote repo, no RemoteRepo", {
  desc <- readRDS("fixtures/no-remote-repo.rda")
  expect_identical(pkg_source(desc), "github")
})

test_that("print.packages_info", {
  info <- readRDS("fixtures/devtools-info.rda")
  expect_output(
    print(info), "package    * version     date       source",
    fixed = TRUE
  )
})
