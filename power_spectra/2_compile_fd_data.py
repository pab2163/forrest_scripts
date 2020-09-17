# This script loops through all fd estimates pulled from mriqc (unfiltered, notch, and lowpass), puts all in one big df and writes to csf
# Author: Paul Alexander Bloom
# Date: 5/5/2020

import glob
import os
import pandas as pd

# pull fd .txt files -- each is a timeseries
files = glob.glob('../../data/filtered_params/*fd*.txt')

sub_df_list = []

# for each file, load in, then make dataframe containing relevant info (subject, session, scan, tr, and filter type)
for index, file in enumerate(files):
    subject = file.split('/')[4][0:6]
    scan = "_".join((file.split('/')[4]).split('_fd')[0].split('_')[1:])
    filter = file.split('/')[4].split('.txt')[0].split('fd_ts_')[1]
    print(subject, scan, filter)


    sub_df = pd.read_csv(file, header=None)
    sub_df.rename(columns = {0:'fd'}, inplace = True)
    sub_df['subid'] = subject
    sub_df['scan'] = scan
    sub_df['filter'] = filter
    sub_df['tr'] = sub_df.index

    sub_df_list.append(sub_df)



master_df = pd.concat(sub_df_list)

# sort and write out to csv
master_df.sort_values(by = ['subid', 'scan', 'filter', 'tr'], inplace = True)
master_df.to_csv('../../data/fd_estimates_filtered.csv', index = False)
