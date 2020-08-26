library(tidyverse)

# This script graphs the power spectra of each of the 6 motion parameters for each subject
# It takes as input the csv file output by pull_motion_with_interpolate.py, and outputs the plot file
# 
# 4 command line args
#   1: the path to the input csv file output by pull_motion_with_interpolate.py
#   2: the z-score cutoff to truncate the power spectra distribution at (i.e. 2) for visualization 
#   3: whether to scale within each scan or not (TRUE or FALSE)
#   4: output plot filename (use either .pdf or .png format)
# 

args = commandArgs(trailingOnly=TRUE)

# read in data in first command-line arg
power_spectra = read_csv(args[1])

# z-value cutoff to truncate at (i.e. 2)
cutoff = as.numeric(args[2])

# whether to scale within scan or not
scale_within_scan = (args[3])

# output filename (pdf or png)
output_file = args[4]

print(c('Min TRs:', min(power_spectra$num_tr)))
print(c('Max TRs:', max(power_spectra$num_tr)))

# cast to long format
power_spectra_long = power_spectra %>%
  pivot_longer(cols = c(0,1,2,3,4,5, 6)) %>%
  mutate(name = case_when(
    name == '0' ~ 'roll',
    name == '1' ~ 'pitch',
    name == '2' ~ 'yaw',
    name == '3' ~ 'dS',
    name == '4' ~ 'dL',
    name == '5' ~ 'dP',
  ))

# get scan ranks by median FD
fd_ranks = power_spectra_long %>%
  group_by(scan_id) %>%
  summarise(median_fd = median_fd[1]) %>%
  mutate(median_fd_rank = rank(1-median_fd)) %>%
  dplyr::select(-median_fd)

# join in ranks
power_spectra_long = power_spectra_long %>%
  left_join(., fd_ranks, by = 'scan_id') 

# take log10, then z-score data (either within scan or across all scans)
if (scale_within_scan == TRUE){
  power_spectra_z = power_spectra_long %>%
  group_by(scan_id, name) %>%
  mutate(pow_scaled = scale(log10(value)), 
         pow_scaled = case_when(pow_scaled > cutoff ~ cutoff,
                                pow_scaled < -1*cutoff ~ -1*cutoff,
                                pow_scaled >= -1*cutoff & pow_scaled <= cutoff ~ pow_scaled))
}else{
  power_spectra_z = power_spectra_long %>%
    mutate(pow_scaled = scale(log10(value)), 
           pow_scaled = case_when(pow_scaled > cutoff ~ cutoff,
                                  pow_scaled < -1*cutoff ~ -1*cutoff,
                                  pow_scaled >= -1*cutoff & pow_scaled <= cutoff ~ pow_scaled))
}


# make plot
plt = ggplot(power_spectra_z, aes(x = frequency, y = median_fd_rank, fill = pow_scaled)) +
  geom_tile() +
  facet_grid(~name) +
  theme_bw() +
  scale_fill_viridis_c() +
  labs(fill = 'Power (z-scored)', x = 'Frequency', y = 'Scams Ranked by FD') +
  theme(axis.text.y = element_blank())

ggsave(plt, file = output_file, width = 15, height = 8)