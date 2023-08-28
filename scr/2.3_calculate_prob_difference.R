library(tidyverse)

path <- "output/Perturbation_analysis/"

# As a separate element in a list
temp = list.files(path = path,pattern="*.txt", full.names = T)
myfiles = lapply(temp, read.delim, sep = ",")
myfiles = setNames(myfiles, gsub(path, "", temp))
myfiles = setNames(myfiles, gsub("/", "", names(myfiles)))
myfiles = setNames(myfiles, gsub(".txt", "", names(myfiles)))

untreated <- read.delim("output/WT_model_trajectories/WT_trajectories_600steps.csv", sep = ",")%>% 
  mutate(Prol_KC = PopRatio*Prol_KC) %>% 
  dplyr::select(-PopRatio)

table_init <- read.delim("output/WT_model_trajectories/WT_trajectories_300steps.csv", sep = ",")%>%    
  mutate(Prol_KC = PopRatio*Prol_KC) %>% 
  dplyr::select(-PopRatio) 


myfiles <- lapply(myfiles, function(x) x %>%
                    rename ("Time" = "X") %>%
                    mutate(Time = Time + 301) %>%
                    mutate(Prol_KC = PopRatio*Prol_KC) %>% 
                    dplyr::select(-PopRatio) )


KC_fate <- cbind("Node" = c("KC","aKC","Prol_KC","preDiff_KC","Diff_KC","Division","Death"), "Type" = rep("KC_fate"))
Innate <- cbind("Node" = c("LC","pDC","iDC","M1","M2","Fibroblast","Neutrophil"), "Type" = rep("Innate"))
T_cells <- cbind("Node" = c("Th0","Th1","Th2","Th17","Th22","Treg","ILC3"), "Type" = rep("T_cells"))
Node_group <- as.data.frame(rbind(KC_fate,Innate,T_cells))
node_red <-data.frame()

for (per in 1:length(myfiles)) {
  for (node in Node_group$Node) {
    df <- myfiles[[per]]
    sim <- names(myfiles)[per]
    node_name <- node
    node_WT <- untreated[nrow(untreated),node]
    node_treat <- df[nrow(df),node]
    
    #node_red[per,] <- sim
    node_red[sim, node_name] <- as.numeric((node_treat - node_WT) / node_WT *100)
  }
}

node_red <- cbind(rownames(node_red),node_red)

round_df <- function(x, digits) {
  # round all numeric variables
  # x: data frame 
  # digits: number of digits to round
  numeric_columns <- sapply(x, mode) == 'numeric'
  x[numeric_columns] <-  round(x[numeric_columns], digits)
  x
}

node_red<-round_df(node_red, 2)

write.table(node_red, file = "output/Probability_differences_all_perturbations.csv", quote = F, row.names = F,sep = ",")

