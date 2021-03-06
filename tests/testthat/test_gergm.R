test_that("Simple model with no covariates runs", {
  skip_on_cran()
  ########################### 1. No Covariates #############################
  # Preparing an unbounded network without covariates for gergm estimation #
  #skip("Skipping test as it can only be run in the global environment.")

  set.seed(12345)
  net <- matrix(rnorm(100,0,20),10,10)
  colnames(net) <- rownames(net) <- letters[1:10]

  # one parameter model
  formula <- net ~ edges + ttriads

  test <- gergm(formula,
                normalization_type = "division",
                network_is_directed = TRUE,
                use_MPLE_only = FALSE,
                estimation_method = "Metropolis",
                number_of_networks_to_simulate = 40000,
                thin = 1/40,
                proposal_variance = 0.5,
                downweight_statistics_together = TRUE,
                MCMC_burnin = 10000,
                seed = 456,
                convergence_tolerance = 0.01,
                MPLE_gain_factor = 0,
                force_x_theta_updates = 4)

  check_against <- c(-0.086)
  expect_equal(round(as.numeric(test@theta.coef[1,]),3), check_against)

  # three parameter model
  formula <- net ~  edges + mutual + ttriads

  test <- gergm(formula,
                normalization_type = "division",
                network_is_directed = TRUE,
                use_MPLE_only = FALSE,
                estimation_method = "Metropolis",
                number_of_networks_to_simulate = 40000,
                thin = 1/40,
                proposal_variance = 0.5,
                downweight_statistics_together = TRUE,
                MCMC_burnin = 10000,
                seed = 456,
                convergence_tolerance = 0.01,
                MPLE_gain_factor = 0,
                force_x_theta_updates = 4)

  check_against <- c(2.075, -0.253)
  expect_equal(round(as.numeric(test@theta.coef[1,]),3), check_against)

  # five parameter model
  formula2 <- net ~  edges + mutual + ttriads + in2stars

  test <- gergm(formula2,
              normalization_type = "division",
              network_is_directed = TRUE,
              use_MPLE_only = FALSE,
              estimation_method = "Metropolis",
              number_of_networks_to_simulate = 40000,
              thin = 1/40,
              proposal_variance = 0.5,
              downweight_statistics_together = TRUE,
              MCMC_burnin = 10000,
              seed = 456,
              convergence_tolerance = 0.01,
              MPLE_gain_factor = 0,
              force_x_theta_updates = 4)

check_against <- c(2.445,  0.053, -0.492)
expect_equal(round(as.numeric(test@theta.coef[1,]),3), check_against)

#check that code works for undirected network

formula <- net ~ edges + ttriads + twostars

test <- gergm(formula,
              normalization_type = "division",
              network_is_directed = FALSE,
              use_MPLE_only = FALSE,
              estimation_method = "Metropolis",
              number_of_networks_to_simulate = 40000,
              thin = 1/40,
              proposal_variance = 0.5,
              downweight_statistics_together = TRUE,
              MCMC_burnin = 10000,
              seed = 456,
              convergence_tolerance = 0.01,
              MPLE_gain_factor = 0,
              force_x_theta_updates = 4)

check_against <- c(0.096, -0.244)
expect_equal(round(as.numeric(test@theta.coef[1,]),3), check_against)

#check that code works with MPLE only

formula <- net ~ edges + ttriads + in2stars

test <- gergm(formula,
              normalization_type = "division",
              network_is_directed = TRUE,
              use_MPLE_only = TRUE,
              estimation_method = "Metropolis",
              number_of_networks_to_simulate = 40000,
              thin = 1/40,
              proposal_variance = 0.5,
              downweight_statistics_together = TRUE,
              MCMC_burnin = 10000,
              seed = 456,
              convergence_tolerance = 0.01,
              MPLE_gain_factor = 0,
              force_x_theta_updates = 2,
              force_x_lambda_updates = 3)

check_against <- c(0.226, -0.610)
expect_equal(round(as.numeric(test@theta.coef[1,]),3), check_against)

})

test_that("Model with covariates runs", {
  skip_on_cran()

  set.seed(12345)
  net <- matrix(runif(100,0,1),10,10)
  colnames(net) <- rownames(net) <- letters[1:10]
  node_level_covariates <- data.frame(Age = c(25,30,34,27,36,39,27,28,35,40),
                                      Height = c(70,70,67,58,65,67,64,74,76,80),
                                      Type = c("A","B","B","A","A","A","B","B","C","C"))
  rownames(node_level_covariates) <- letters[1:10]
  network_covariate <- net + matrix(rnorm(100,0,.5),10,10)
  formula <- net ~ edges + mutual + ttriads + sender("Age") +
  netcov("network_covariate") + nodemix("Type",base = "A")

  test <- gergm(formula,
                covariate_data = node_level_covariates,
                network_is_directed = TRUE,
                use_MPLE_only = FALSE,
                estimation_method = "Metropolis",
                number_of_networks_to_simulate = 100000,
                thin = 1/100,
                proposal_variance = 0.5,
                downweight_statistics_together = TRUE,
                MCMC_burnin = 50000,
                seed = 456,
                convergence_tolerance = 0.01,
                MPLE_gain_factor = 0,
                force_x_theta_updates = 2)

  check_against <- c(0.824, -0.072, -0.016, -0.026, -0.024, -0.056, -0.055,
                     -0.035,  0.002, -0.040, -0.050,  3.061, 0.129, -1.931)
  expect_equal(c(round(as.numeric(test@theta.coef[1,]),3),round(as.numeric(test@lambda.coef[1,]),3)), check_against)

  formula <- net ~ edges + mutual + ttriads + sender("Age") +
    netcov("network_covariate") + nodematch("Type")

  test <- gergm(formula,
                covariate_data = node_level_covariates,
                network_is_directed = TRUE,
                use_MPLE_only = FALSE,
                estimation_method = "Metropolis",
                number_of_networks_to_simulate = 100000,
                thin = 1/100,
                proposal_variance = 0.5,
                downweight_statistics_together = TRUE,
                MCMC_burnin = 50000,
                seed = 456,
                convergence_tolerance = 0.01,
                MPLE_gain_factor = 0,
                force_x_theta_updates = 2)

  check_against <- c(1.434, -0.083, -0.017, -0.025,  3.117, 0.132, -1.837)
  expect_equal(c(round(as.numeric(test@theta.coef[1,]),3),round(as.numeric(test@lambda.coef[1,]),3)), check_against)

})
