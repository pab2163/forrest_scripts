# command line args for subid and run
subid=$1
run=$2

# make paths for input resp and cardio files
resp_file=/danl/Collaborations/studyforrest/bids_raw/${subid}/ses-movie/func/${subid}_ses-movie_task-movie_run-${run}_recording-cardresp_physio.1D
card_file=/danl/Collaborations/studyforrest/bids_raw/${subid}/ses-movie/func/${subid}_ses-movie_task-movie_run-${run}_recording-cardio.1D


#according to: https://afni.nimh.nih.gov/pub/dist/doc/program_help/RetroTS.py.html
# p: sampling frequency - 500Hz
# n: number of slices - 35
# v: tr for one volume (2s)
# slice_order: seq+z (sequential in the plus direction)
RetroTS.py -r $resp_file -c $card_file -p 500 -n 35 -v 2 -respiration_out 1 -cardiac_out 1 -prefix rvt_regressors/${subid}_run_${run} -slice_order seq+z


# run afni_proc.py for the current subid to generate rvt script
afni_proc.py                            \
                 -subj_id ${subid}_run_${run}             \
                 -dsets ../../bids_raw/${subid}/ses-movie/func/${subid}_ses-movie_task-movie_run-${run}_bold.nii.gz       \
                 -blocks despike ricor    \
                 -tcat_remove_first_trs 0             \
                 -ricor_regs_nfirst 0                 \
                 -ricor_regs rvt_regressors/${subid}_run_${run}.slibase.1D


# run the afni pipeline
./proc.${subid}_run_${run}

# run 3dvolreg on resulting BRIK file
3dvolreg -1Dfile /danl/Collaborations/studyforrest/motion_retroicor/motion_${subid}_run_${run}_rvt.1D ${subid}_run_${run}.results/pb02.${subid}_run_${run}.r01.ricor+orig.BRIK
# get rid of extra volreg file
rm volreg*
