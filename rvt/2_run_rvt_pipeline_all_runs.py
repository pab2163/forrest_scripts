import numpy as np
import glob
import os

subs = glob.glob('../../bids_raw/sub*')
runs = np.arange(8)

for sub in subs:
	subid = sub.split('/')[-1]
	for run in runs:
		message = f'bash 1_run_rvt_pipeline.sh {subid} {run +1}'
		os.system(message)
