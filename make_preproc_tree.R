library(tidyverse)


df = crossing(`AFNI 3dDespike` =  0:1,
              `Spike regression with .2mm thresh` = 0:1, 
              `GSR` = 0:1,
              `aCompCor` = 0:1,
              `Filter` = c(2,3,4))


df = crossing(df, pipe = c('RETROICOR', 'RETROICOR + RVT-8', 'No externally-based correction'))

df = df %>%
  dplyr::arrange(pipe, Filter) %>% 
  mutate(index = 1:nrow(.))
  

df_long = df %>%
  pivot_longer(-c(index, pipe)) %>%
  mutate(category = ifelse(name %in% c('RC', 'RC + RVT-8', 'None', 'RVT-8'), 'Pre-CPAC', 'CPAC')) %>%
  dplyr::filter() %>%
  mutate(Filtering = case_when(
    value == 0 ~ 'no',
    value == 1 ~ 'yes',
    value == 2 ~ 'Bandpass data after nuisance reg',
    value == 3 ~ 'Bandpass data before nuisance reg',
    value == 4 ~ 'Notch filter motion params before nuisance reg, bandpass data after'))



df_long$name = factor(df_long$name, levels = rev(c(
  'Filter',
  'AFNI 3dDespike',
  'Spike regression with .2mm thresh',
  'GSR',
  'aCompCor'
)))



tree = ggplot(df_long, aes(x = index, y = name, fill = Filtering)) + 
  geom_tile() + 
  theme_classic() + 
  facet_grid(~pipe, drop = TRUE, scales = 'free') +
  labs(x = 'Pipeline #', y = '') +
  scale_fill_manual(breaks = c("Bandpass data after nuisance reg", 'Bandpass data before nuisance reg', 'Notch filter motion params before nuisance reg, bandpass data after'),
                    values = c('dark blue', "dark red", "black", "dark green", 'white')) +
  theme(legend.position = 'top', legend.title = element_blank())

tree

ggsave(tree, file = '../plots/preproc_tree.png', width = 12, height = 4)

