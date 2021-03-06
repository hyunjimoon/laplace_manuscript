## 5/27/2016: v1.0

## functions to run cmdStan

compileModel <- function(model, stanDir = stanDir) {
  modelName <- basename(model)
  dir.create(model)
  file.copy(paste(model, "stan", sep = "."),
            file.path(model, paste(modelName, "stan", sep = ".")),
            overwrite = TRUE)
  model <- file.path(model, modelName)
  system(paste0("make --directory=", stanDir, " ", model))
}

# this function directly compiles a C++ file.
# FIX ME -- doesn't do what it's supposed to do!!
compileCpp <- function(model, stanDir = stanDir) {
  modelName <- basename(model)
  system(paste0("./compileCpp.sh ", model, "/", modelName, " ", stanDir))
}
  

stanc3compileModel <- function(model, stanDir = stanDir,
                               stanc3Dir = stanc3Dir) {
  # TO DO -- all of this doesn't need to happen in here
  modelName <- basename(model)
  dir.create(model)
  file.copy(paste(model, "stan", sep = "."),
            file.path(model, paste(modelName, "stan", sep = ".")),
            overwrite = TRUE)
  model <- file.path(model, modelName)
  system(paste0("STANC3=", stanc3Dir, " make --directory=", stanDir,
                " ", model))
}

runModel <- function(model, data, iter, warmup, thin, init = "", seed, chain = 1,
                     stepsize = 1, adapt_delta = 0.8, max_depth = 10,
                     refresh = 100, tag = NULL) {
  modelName <- basename(model)
  model <- file.path(model, modelName)
  if(! is.null(tag)) output <- paste0(model, "_", tag, "_") else output=model
  system(paste(model, " sample algorithm=hmc engine=nuts",
               " max_depth=", max_depth,
               " stepsize=", stepsize,
               " num_samples=", iter,
               " num_warmup=", warmup, " thin=",  thin,
               " adapt delta=", adapt_delta, 
               " data file=", data,
               " init=", init,
               " random seed=", seed,
               " output file=", paste(output, chain, ".csv", sep = ""),
               " refresh=", refresh,
               sep = ""))
}

runDiagnose <- function(model, data, init, seed, chain = 1, refresh=100){
  modelName <- basename(model)
  model <- file.path(model, modelName)
  system(paste(model, " diagnose",
               " data file=", data,
               " init=", init, " random seed=", seed, 
               " output file=", paste(model, chain, ".csv", sep = ""),
               " refresh=", refresh,
               sep = ""))
}

runModelFixed <- function(model, data, iter, warmup, thin, init = "", 
                          seed, chain = 1,
                          stepsize = 1, adapt_delta = 0.8, max_depth = 10,
                          refresh = 100) {
  modelName <- basename(model)
  model <- file.path(model, modelName)
  system(paste(model, " sample algorithm=fixed_param",
               " num_samples=", iter,
               " data file=", data,
               " init=", init,
               " random seed=", seed,
               " output file=", paste(model, chain, ".csv", sep = ""),
               " refresh=", refresh,
               sep = ""), invisible = FALSE)
}

check_div <- function(fit) {
  sampler_params <- get_sampler_params(fit, inc_warmup=FALSE)
  divergent <- do.call(rbind, sampler_params)[,'divergent__']
  n = sum(divergent)
  N = length(divergent)
  
  print(sprintf('%s of %s iterations ended with a divergence (%s%%)',
                n, N, 100 * n / N))
  if (n > 0)
    print('  Try running with larger adapt_delta to remove the divergences')
}
