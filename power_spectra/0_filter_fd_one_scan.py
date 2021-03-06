# Filters motion parameters for one scan to get notch-filtered and lowpass-filtered FD timeseries
# Lowpass filter should be comparable to: https://github.com/GrattonLab/Gratton2020_NI_HFmotion/blob/master/filter_motion.m
# Author: Paul A. Bloomm
# May 2020

# Input file is a 6-column file of head realigment params (as generated by AFNI 3dvolreg), such that the first 3 columns are rotation and last 3 are translation
# Takes 3 command-line args: [path to input file] [output directory] [scan type]

import numpy as np
from scipy.signal import butter, lfilter, filtfilt, iirnotch
from scipy.fftpack import fft, fftfreq
import math
import sys
import os

# function to convert degrees of motion to mm using head readius
def degrees_to_mm(num_degrees, head_radius):
    dist_mm = 2*math.pi*head_radius*(num_degrees/360)
    return dist_mm


# make a butterworth lopass filter, order 1
def make_butter_lowpass(highcut, tr, order=1):
    nyq = 0.5 / tr
    high = highcut / nyq
    b, a = butter(order, high, btype='lowpass')
    return b, a

# apply butterworth lowpass filter forwards and backwards
def apply_butter_lowpass_filter(data, highcut, tr, order=1):
    b, a = make_butter_lowpass(highcut, tr, order=order)
    y = filtfilt(b, a, x = data, padtype = 'odd', axis = 0)
    return y

# make a notch filter
def make_notch(center, width, tr):
    sampling_freq = 1/tr
    center_s = center/(sampling_freq/2)
    q_s = center/width
    b, a = iirnotch(center_s, q_s)
    return b, a

# apply notch filter forwards and backwards
def apply_notch_filter(data,center, width, tr):
    # pad with 100 zeros before and after the data
    b, a = make_notch(center, width, tr)
    y = filtfilt(b, a, x = data, padtype = 'odd', axis = 0)
    return y

# take in data in absolute position (relative to a certain frame) and make the framewise displacement timeseries as in Power 2012
# returns a list with both the difference (derivative) matrix, and a 1d array of the filtered timeseries
def make_fd_timeseries(data):
    # calculate differences between each TR and the previous
    data_diff = np.diff(data, axis = 0)
    # get one timeseries for framewise displacement, as in Power 2012
    # sum abs values of the parameters (differences from last TR), at each TR
    fd_ts = np.sum(abs(data_diff), axis = 1)

    return([data_diff,fd_ts])


### ----- RUN DATA THROUGH FUNCTIONS ---------------

raw_file = sys.argv[1] # input 6-column file
output_dir = sys.argv[2] # output directory
scan_type = sys.argv[3] # BIDS style sequence name (i.e. REST_run-1) to keep track of fd timeseries
sub = sys.argv[4]

# Load in raw from file input in command line argument
raw_data = np.loadtxt(raw_file)

# convert rotation params from degrees to mm
raw_data[:,0:3] = degrees_to_mm(raw_data[:,0:3], head_radius = 50)

# apply lowpass filter with cutoff at .1Hz as in Gratton et al. 2020 (https://www.biorxiv.org/content/10.1101/837161v2)
lowpass_filtered = apply_butter_lowpass_filter(data = raw_data, highcut = 0.1, tr = 2, order = 1)

# apply notch filter as in Fair et al. 2020 (http://www.sciencedirect.com/science/article/pii/S1053811919309917)
#notch_filtered = apply_notch_filter(data = raw_data, center = .31, width = .43, tr = 2)

# make the fd timeseries for each
raw_ts = make_fd_timeseries(raw_data)
lowpass_ts = make_fd_timeseries(lowpass_filtered)
#notch_ts = make_fd_timeseries(notch_filtered)


# save files out in the output_dir
os.system(f'mkdir {output_dir}')
np.savetxt(fname = output_dir + '/' + sub + '_' + scan_type + '_fd_ts_unfiltered.txt', X = raw_ts[1], delimiter=',')
#np.savetxt(fname = output_dir + '/' + sub + '_' + scan_type + '_fd_ts_notch.txt', X = notch_ts[1], delimiter=',')
np.savetxt(fname = output_dir + '/' + sub + '_' + scan_type + '_fd_ts_lowpass.txt', X = lowpass_ts[1], delimiter=',')
np.savetxt(fname = output_dir + '/' + sub + '_' + scan_type + '_realignment_raw.txt', X = raw_data, delimiter=',')
#np.savetxt(fname = output_dir + '/' + sub + '_' + scan_type + '_realignment_notch.txt', X = notch_filtered, delimiter=',')
np.savetxt(fname = output_dir + '/' + sub + '_' + scan_type + '_realignment_lowpass.txt', X =lowpass_filtered, delimiter=',')
