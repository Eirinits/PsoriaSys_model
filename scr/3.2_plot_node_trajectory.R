library(tidyverse)

path <- "output/Perturbation_analysis"

# As a separate element in a list
temp = list.files(path = path,pattern="*.csv", full.names = T)
myfiles = lapply(temp, read.delim, sep = ",")
myfiles = setNames(myfiles, gsub(path, "", temp))
myfiles = setNames(myfiles, gsub("/", "", names(myfiles)))
myfiles = setNames(myfiles, gsub(".csv", "", names(myfiles)))

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
                    dplyr::select(-PopRatio))

KC_fate <- cbind("Node" = c("KC","aKC","Prol_KC","preDiff_KC","Diff_KC","Division","Death"), "Type" = rep("KC_fate"))
Innate <- cbind("Node" = c("LC","pDC","iDC","M1","M2","Fibroblast","Neutrophil"), "Type" = rep("Innate"))
T_cells <- cbind("Node" = c("Th0","Th1","Th2","Th17","Th22","Treg","ILC3"), "Type" = rep("T_cells"))
Node_group <- as.data.frame(rbind(KC_fate,Innate,T_cells))

myfiles_long = lapply(myfiles, function(x) gather(x, Node, Prob, -Time) %>%
                        as.data.frame() %>% left_join(Node_group, by = "Node"))

table_init_long <- gather(table_init, Node, Prob, -X) %>%
  rename ("Time" = "X") %>% left_join(Node_group) 

myfiles_long = lapply(myfiles_long, function(x) rbind(table_init_long,x))

untreated_long <- gather(untreated, Node, Prob, -X) %>%
  rename ("Time" = "X") %>% left_join(Node_group, by = "Node") %>% 
  mutate(Condition = "Untreated")

myfiles_long[["Untreated"]] <- untreated_long

all_per_long <- map2(myfiles_long, names(myfiles_long), ~ mutate(.x, Condition = .y))
all_per_long <- do.call("rbind", all_per_long) 

all_per_long <- read.delim("All_perturbations_long.csv", sep = ",")
## Plot specific nodes

# Create a vector with the given values
node_colors <- c("#000000","#009292","#FF6DB6","#FFB6DB","#490092","#006DDB","#920000","#D82632","#920000","#009E73","#DB6D00","#24FF24","#FFC34C","#009999","#029")
names(node_colors) <- c("Prol_KC","Diff_KC", "preDiff_KC", "pDC", "iDC", "M1", "M2", "Neutrophil", "Th1", "Th2", "Th17", "Th22", "Treg", "Fibroblast","ILC3")

# Example: Plot trajectories for perturbation with common biologics.

all_per_long %>% 
  filter(Node == "Prol_KC" & Condition %in% c("Untreated","IL17_OFF", "TNFa_OFF","table_ustekinumab")) %>% 
  mutate(Treat = ifelse(Condition == "Untreated","1","0")) %>% 
  ggplot(aes(x=Time, y=Prob, color = Condition, linetype = Treat)) +
  scale_color_manual(values = c("#E69F00","#56B4E9","#009E73","black"),labels = c("IL-17 inhibition", "IL-23 & IL-12 inhibition","TNFa inhibition","Untreated"))+
  geom_line() + 
  ylab("Proliferating KC population size") +
  theme_minimal() + labs(color='Perturbation') +
  scale_x_continuous(breaks = c(0,300,600))

ggsave("Prol_KC_biologics.png",
       height = 10, width = 15, units = "cm")
