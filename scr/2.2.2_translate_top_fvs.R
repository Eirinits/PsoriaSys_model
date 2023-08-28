library(tidyverse)

node_SUID <- read.csv("~/data/model_files/node_SUID.csv")

inter <- read.csv("output/FVS_analysis/interVals_2node.csv") %>% 
  separate(X, c("Target1","Target2"), sep = ",") %>% 
  mutate(across(where(is.character), str_trim))

inter$Target1_tr <- plyr::mapvalues(inter$Target1, from = node_SUID$SUID, to = node_SUID$Node)
inter$Target2_tr <- plyr::mapvalues(inter$Target2, from = node_SUID$SUID, to = node_SUID$Node)

inter2_flt <- inter %>% 
  select(PRINCE..ModPRINCE..CheiRank, Target1_tr,Target2_tr) %>% 
  filter(!Target1_tr %in% c("Prol_KC","Th1","Th17","Treg")) %>% 
  filter(!Target2_tr %in% c("Prol_KC","Th1","Th17","Treg")) %>% 
  arrange(desc(PRINCE..ModPRINCE..CheiRank)) %>% 
  top_n(20, PRINCE..ModPRINCE..CheiRank)


node_freq <- inter2_flt %>% 
  select(PRINCE..ModPRINCE..CheiRank, Target1_tr,Target2_tr) %>% 
  mutate(inter = paste0(Target1_tr,"__",Target2_tr))

nodes <- as.character(unique(c(inter2_flt$Target1_tr,inter2_flt$Target2_tr)))

freq_nodes <- as.data.frame(colSums(sapply(nodes, stringr::str_count, string = node_freq$inter))) %>% 
  rownames_to_column("Nodes")

names(freq_nodes$`colSums(sapply(nodes, stringr::str_count, string = node_freq$inter[1:50]))`) <- "Frequency"
barplot(freq_nodes$`colSums(sapply(nodes, stringr::str_count, string = node_freq$inter))`)
