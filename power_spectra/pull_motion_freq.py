from scipy.signal import butter, lfilter, filtfilt, iirnotch
import numpy as np
from scipy.fftpack import fft, fftfreq
from scipy.interpolate import interp1d
import matplotlib.pyplot as plt
import math
import pandas as pd
import glob
from scipy.stats import zscore

def degrees_to_mm(num_degrees, head_radius):
	dist_mm = 2*math.pi*head_radius*(num_degrees/360)
	return dist_mm

def get_motion_freq(raw_data, tr, scan_id, max_tr_num):
	half_max_num = math.ceil(max_tr_num/2)
	sampling_rate = 1/tr
	full_freqs = (fftfreq(max_tr_num) * sampling_rate)[0:half_max_num]

	# if we have all 750 TRs, then 375 frequencies in fft
	freq_mat = np.zeros((half_max_num, 6))

	for i in range(6):
		fft_init = (np.abs(fft(raw[:,i])))[0:math.ceil(raw_data.shape[0]/2)]
		raw_freqs = (fftfreq(raw_data.shape[0]) * sampling_rate)[0:math.ceil(raw_data.shape[0]/2)]

		# if less than 750 TRs, upsample
		if raw_data.shape[0] < max_tr_num:
			upsample_func = interp1d(raw_freqs, fft_init, fill_value = 'extrapolate')
			freq_mat[:,i] = upsample_func(full_freqs)
		else:
			freq_mat[:,i] = fft_init[0:half_max_num]

	df = pd.DataFrame(freq_mat)
	df['frequency'] = full_freqs
	df = df[df.frequency >= 0]
	df['scan_id'] = scan_id
	return(df)


def make_fd_timeseries(data):
	# calculate differences between each TR and the previous
	data_diff = np.diff(data, axis = 0)

	# get one timeseries for framewise displacement, as in Power 2012
	# sum abs values of the parameters (differences from last TR), at each TR
	fd_ts = np.sum(abs(data_diff), axis = 1)

	return(fd_ts)

realign_files = glob.glob('../../data/realignment_params/*movie_*.1D')

out_df_list = []

for index, file in enumerate(realign_files):
	raw = np.loadtxt(file)
	raw[:,0:3] = degrees_to_mm(raw[:,0:3], head_radius = 50)
	motion_power_spectra = get_motion_freq(raw_data= raw, tr = 2, scan_id = file.split('/')[4], max_tr_num = 542)
	fd_ts = make_fd_timeseries(raw)
	motion_power_spectra['median_fd'] = np.median(fd_ts)
	out_df_list.append(motion_power_spectra)


combined_df = pd.concat(out_df_list)
combined_df.to_csv('../../data/rest_power_spectra.csv', index = False)


# SB
realign_files_sb = glob.glob('../../../sb/data/realignment_params/*.1D')

out_df_list = []

for index, file in enumerate(realign_files_sb):
	raw = np.loadtxt(file)
	raw[:,0:3] = degrees_to_mm(raw[:,0:3], head_radius = 50)
	motion_power_spectra = get_motion_freq(raw_data= raw, tr = 2, scan_id = file.split('/')[6], max_tr_num = 180)
	fd_ts = make_fd_timeseries(raw)
	motion_power_spectra['median_fd'] = np.median(fd_ts)
	out_df_list.append(motion_power_spectra)


combined_df = pd.concat(out_df_list)
combined_df.to_csv('../../../sb/data/rest_power_spectra.csv', index = False)
