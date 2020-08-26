import numpy as np
from scipy.fftpack import fft, fftfreq
from scipy.interpolate import interp1d
import math
import pandas as pd
import glob
from scipy.stats import zscore
import sys

"""
This script extracts the power spectra of motion parameters all 3dVolreg output files in a directory
It will interpolate the power spectra to a common set of frequencies for each scan, despite differeing #s of TRs
The script returns a .csv file in long format with the power at each frequency for each scan for each of the 6 parameters

5 command line arguments:
	1: path to input directory with motion param files (assuming 6 columns from AFNI 3dvolreg)
	2: a string for wildcarding specific files from the input directory (use * to use all files)
	3: the 'reference' number of TRs to use to interpolate the power spectra resolution to match
	4: the TR (in seconds)
	5: path to an output file (.csv format) for saving all participants' power spectra in long format
"""


# input directory full of motion param files (assuming 6 columns from AFNI 3dvolreg)
input_dir = sys.argv[1]

input_tag = sys.argv[2]

# max number of TRs in a scan. This will be used as the 'reference' number of TRs.
# scans with different numbers of TRs will have their power spectra interpolated to match the resolution (in the freq domain) of the power spectra for this number of TRs 
max_tr_num = int(sys.argv[3])

# TR in seconds
tr = float(sys.argv[4])

# an output csv file with all participants' power spectra
output_file = sys.argv[5]

# convert degrees to mm
def degrees_to_mm(num_degrees, head_radius):
	dist_mm = 2*math.pi*head_radius*(num_degrees/360)
	return dist_mm


# function to get the power spectra for 1 scan
def get_motion_freq(raw_data, tr, scan_id, max_tr_num):
	half_max_num = math.ceil(max_tr_num/2)
	sampling_rate = 1/tr

	# get the frequencies to use for the reference
	full_freqs = (fftfreq(max_tr_num) * sampling_rate)[0:half_max_num]

	# set up size of output matrix
	freq_mat = np.zeros((half_max_num, 6))

	# generate spectra for each of the 6 parameters
	for i in range(6):
		# generate the fft and raw frequencies
		fft_init = (fft(raw[:,i]))[0:math.ceil(raw_data.shape[0]/2)]
		raw_freqs = (fftfreq(raw_data.shape[0]) * sampling_rate)[0:math.ceil(raw_data.shape[0]/2)]

		# if number of trs in scan is not equal to the reference number of TRs, interpolate
		# save the absolute value at each frequency
		if raw_data.shape[0] != max_tr_num:
			upsample_func = interp1d(raw_freqs, fft_init, fill_value = 'extrapolate')
			freq_mat[:,i] = np.abs(upsample_func(full_freqs))
		else:
			freq_mat[:,i] = np.abs(fft_init[0:half_max_num])

	# output scan-specific DataFrame
	df = pd.DataFrame(freq_mat)
	df['frequency'] = full_freqs
	df = df[df.frequency >= 0]
	df['scan_id'] = scan_id
	return(df)

# funtion to getnerate fd timeseries
def make_fd_timeseries(data):
	# calculate differences between each TR and the previous
	data_diff = np.diff(data, axis = 0)

	# get one timeseries for framewise displacement, as in Power 2012
	# sum abs values of the parameters (differences from last TR), at each TR
	fd_ts = np.sum(abs(data_diff), axis = 1)

	return(fd_ts)

# make a list of realignment files to include
realign_files = glob.glob(input_dir + f'/*{input_tag}*')

out_df_list = []
for index, file in enumerate(realign_files):
	raw = np.loadtxt(file)
	# assuming 3dvolreg output, convert first 3 columns to mm
	raw[:,0:3] = degrees_to_mm(raw[:,0:3], head_radius = 50)

	# get the motion power spectra for 1 scan
	motion_power_spectra = get_motion_freq(raw_data= raw, tr = tr, scan_id = file.split('/')[-1], max_tr_num = max_tr_num)
	# add median fd to scan (for ranking)
	fd_ts = make_fd_timeseries(raw)
	motion_power_spectra['median_fd'] = np.median(fd_ts)
	motion_power_spectra['num_tr'] = raw.shape[0]
	out_df_list.append(motion_power_spectra)

# concatenate power spectra for all scans
combined_df = pd.concat(out_df_list)

# write to csv
combined_df.to_csv(output_file, index = False)

