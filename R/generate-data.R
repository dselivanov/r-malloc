set.seed(1)
input_cmd_args = commandArgs(trailingOnly = TRUE)
if(length(input_cmd_args) <= 0)
  stop("expect following aruments:
       1. [character] output file
       2. [logical, default = TRUE] allocate big objects first 
       3. [logical, default = FALSE] whether to call malloc_trip 
       ")

#------------------------------------------------
# 1. [character] output file
OUT_FILE = input_cmd_args[[1]]
#------------------------------------------------
# 2. [logical, default = TRUE] allocate big objects first
LARGE_LIST_FIRST = TRUE
if(length(input_cmd_args) > 1)
  LARGE_LIST_FIRST = as.logical(input_cmd_args[[2]])
#------------------------------------------------
# 3. [logical, default = FALSE] whether to call malloc_trip 
CALL_MALLOC_TRIM = FALSE
if(length(input_cmd_args) > 2)
  CALL_MALLOC_TRIM = as.logical(input_cmd_args[[3]])
#------------------------------------------------

library(data.table)
library(microbenchmark)
source("R/utils.R")

N_TIMES_CALL_GC = 10

# result
ram_stats = NULL

#------------------------------------------------
if(LARGE_LIST_FIRST) {
  list_sizes = as.integer(10 ** seq(5, 2, -0.5))
  vec_sizes = as.integer(10 ** (4:2))
} else {
  list_sizes = as.integer(10 ** seq(2, 5, 0.5))
  vec_sizes = as.integer(10 ** (2:4))
}
#------------------------------------------------

for(vec_size in vec_sizes) {
  for(list_size in list_sizes) {
    message(sprintf("allocating list of %d integer vectors, each vector is %d elements", list_size, vec_size))
    t_start = Sys.time()
    res = generate_list(n_elem = vec_size, list_size = list_size, CALL_MALLOC_TRIM)

    ram_top_before_gc = top_ram_used_resident()
    # call gc() several times
    for(n in N_TIMES_CALL_GC) ram_gc_reported = gc_ram_used()
    
    ram_top_after_gc = top_ram_used_resident()
    time_spent = difftime(Sys.time(), t_start, units = "sec")
    
    df = data.frame(vec_size = vec_size,
                    list_size = list_size, 
                    ram_top_before_gc = ram_top_before_gc, 
                    ram_gc_reported = ram_gc_reported, 
                    ram_top_after_gc = ram_top_after_gc,
                    time_spent = time_spent
    )
    ram_stats = rbind(ram_stats, df)
  }
  ram_stats = as.data.table(ram_stats)
}

write.csv(ram_stats, file = OUT_FILE, quote = F, row.names = F)
