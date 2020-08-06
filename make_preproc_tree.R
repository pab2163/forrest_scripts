library(tidyverse)


df = crossing(#RC = 0:1, `RC + RVT-8` = 0:1, `RVT-8` = 0:1, `None` = 0:1,
              `Despiking with .2mm thresh` = 0:1, 
              `GSR` = 0:1,
              `aCompCor` = 0:1,
              `filter` = c(1,2,3,4),
              `Filter (bandpass) at nuisance regression step` = 0:1) %>%
  mutate(
         'Notch filter motion params' = ifelse(filter == 1, 1, 0),
         'Lowpass filter motion params' = ifelse(filter == 2, 1, 0),
         'Lowpass filter BOLD before 3dvolreg' = ifelse(filter == 3, 1, 0),
         'No filtering before nuisance regression' = ifelse(filter == 4, 1, 0)) 

df = crossing(df, pipe = c('RETROICOR', 'RETROICOR + RVT-8', 'No externally-based correction'))

df = df %>%
  dplyr::arrange(pipe, `Notch filter motion params`, `Lowpass filter motion params`, 
                 `Lowpass filter BOLD before 3dvolreg`, 
                 `No filtering before nuisance regression`, GSR, `Despiking with .2mm thresh`, aCompCor, `Filter (bandpass) at nuisance regression step`) %>% 
  mutate(index = 1:nrow(.))
  

df_long = df %>%
  pivot_longer(-c(index, pipe)) %>%
  mutate(category = ifelse(name %in% c('RC', 'RC + RVT-8', 'None', 'RVT-8'), 'Pre-CPAC', 'CPAC')) %>%
  dplyr::filter(name != 'filter')



df_long$name = factor(df_long$name, levels = rev(c(
  'No filtering before nuisance regression',
  'Lowpass filter BOLD before 3dvolreg',
  'Lowpass filter motion params',
  'Notch filter motion params',
  'GSR',
  'Despiking with .2mm thresh',
  'aCompCor',
  'Filter (bandpass) at nuisance regression step'
)))



ggplot(df_long, aes(x = index, y = name, fill = value)) + 
  geom_tile() + 
  theme_classic() + 
  facet_grid(~pipe, drop = TRUE, scales = 'free') +
  scale_fill_gradient2(low="white",high="blue") +
  theme(legend.position = 'None') +
  labs(x = 'Pipeline #')

