library(ggplot2)
library(data.table)
fls = list.files(path = "data/create_small_obj_first/", pattern = ".csv", full.names = T)
# fls = list.files(path = "data/create_big_obj_first/", pattern = ".csv", full.names = T)

dt = rbindlist(lapply(fls, function(x) {
    dt = fread(x) 
    dt[, malloc := tools::file_path_sans_ext(basename(x))]
  })
)
dt[, operation_order := 1L:.N, by = malloc]

# plot allocators "top" ram usage dynamics
ggplot(dt) + 
  geom_line(aes(x = operation_order, y = ram_top_after_gc, col = malloc)) + 
  scale_y_log10(breaks = seq(0, 5000, 500))

ggplot(dt[, .(time_spent = sum(time_spent)), by = malloc]) +
  geom_bar(aes(y = time_spent, fill = malloc, x = malloc), stat = "identity")

dt2 = melt(dt, id.vars = c("malloc", "vec_size", "list_size"), 
           measure.vars = c("ram_top_before_gc", "ram_gc_reported", "ram_top_after_gc"))
dt2[, vec_size := paste0("vec=", vec_size)]
dt2[, list_size := paste0("list=", list_size)]

# plot "top" ram usage comparison between allocators
ggplot(dt2) + 
  geom_bar(aes(x = variable, y = value, fill = malloc), stat = "identity", position = "dodge") + 
  facet_wrap(~ vec_size + list_size, scales = "free") +
  theme(axis.text.x = element_text(angle = 15, hjust = 1))
