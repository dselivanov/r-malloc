# System set up

* Ubuntu 16.04 LTS
* Xeon X3470
* 32gb RAM

# Install memory allocators

```sh
sudo apt-get install libtcmalloc-minimal4 libjemalloc1
```

# Naive benchmark

### test-malloc.R 
```r
a = replicate(2e6, new.env()) # ~ 1.4 GB of memory
b = new.env()
rm(a)
gc()
Sys.sleep(10)
```

### test-malloc2.R 

```r
a = replicate(2e6, new.env()) # ~ 1.4 GB of memory
b = new.env()
rm(a)
gc()
gc()
gc()
Sys.sleep(10)
```

## glibc

```sh
Rscript test-malloc.R 
```
`top` reports **1332M**

```sh
Rscript test-malloc2.R 
```
`top` reports **1332M**


## tcmalloc

```sh
env LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.4 Rscript test-malloc.R 
```
`top` reports **819M**

```sh
env LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.4 Rscript test-malloc2.R 
```
`top` reports **44M**

## jemalloc

```sh
env LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1 Rscript test-malloc.R 
```
`top` reports **879M**

```sh
env LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1 Rscript test-malloc2.R 
```
`top` reports **50M**