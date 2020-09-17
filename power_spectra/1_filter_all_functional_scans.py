import glob
import os

files = glob.glob('../../data/realignment_params/*.1D')



for file in files:
    subject = file.split('/')[4][:6]
    scan = file.split('/')[4].split('task-')[1][:-14]
    print(subject, scan)

    # define and make output directories if they don't already exist
    out_dir = ('../../data/filtered_params')
    if not os.path.isdir(out_dir):
        os.system(f'mkdir {out_dir}')
    # if out directory does exist, run filter
    else:
        os.system(f'python 0_filter_fd_one_scan.py {file} {out_dir} {scan} {subject}')
