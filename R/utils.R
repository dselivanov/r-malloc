top_ram_used_resident = function(pid = Sys.getpid(), indicator = "RES") {
  args = sprintf("-p %d -b -n 1", pid)
  top_out = system2("top", args, stdout = TRUE)
  top_out = paste(top_out, collapse = "\n")
  top_out = data.table::fread(top_out, header = T, skip = 6)
  res = top_out[[indicator]]
  # catch if top reported RAM in gigabytes
  if(grepl(pattern = "g$", res))
    res = as.numeric(gsub("g$", "", res)) * 1e6
  # catch if top reported RAM in megabytes
  if(grepl(pattern = "m$", res))
    res = as.numeric(gsub("m$", "", res)) * 1e3
  # convert to mb
  as.numeric(res) / 1e3
}
#------------------------------------------
gc_ram_used = function() {
  memusage = sum(gc()[, "(Mb)"])
  memusage
}

malloc_trim_finalizer = function(e) {
  # message("Calling malloc_trim(0L)")
  mallinfo::malloc.trim(0L)
}

generate_list = function(n_elem, list_size, finalizer = FALSE) {
  if(finalizer) {
    e = environment()
    reg.finalizer(e, malloc_trim_finalizer)
  }
  lapply(seq_len(list_size), function(i) sample.int(n_elem, replace = TRUE))
  TRUE
}
