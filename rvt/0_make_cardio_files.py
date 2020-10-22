# script to go through and convert the second column of every zipped bids cardresp file to a separate 1D cardio file

import json
import numpy as np
import glob


def read_cardio_trace(bids_physio_file, column=1):
    resp_index = int(column)
    # read physio data
    physio_data = np.genfromtxt(bids_physio_file)
    # return column of respiratory trace
    return physio_data[:, resp_index]

in_files = glob.glob('../../bids_raw/sub-*/ses-movie/func/sub-*_ses-movie_task-movie_run-*_recording-cardresp_physio.tsv.gz')
for file in in_files:
    out_dir = '/'.join(file.split('/')[0:-1])
    run = file.split('/')[-1][32]
    subid = file.split('/')[3]
    card_outfile = f'{out_dir}/{subid}_ses-movie_task-movie_run-{run}_recording-cardio.1D'
    print(card_outfile)

    cardio_trace = read_cardio_trace(bids_physio_file = file, column = 1)
    np.savetxt(card_outfile, cardio_trace, fmt="%.06f")