#!/bin/bash

#SBATCH --account=psych
#SBATCH --job-name=forrest_cpac_test
#SBATCH --mail-type=ALL
#SBATCH --constraint=docker
#SBATCH -c 10
#SBATCH --time=11:55:00
#SBATCH --mem-per-cpu=20gb

module load singularity
 
singularity run \
    -B /rigel/psych/users/pab2163/studyforrest/bids_raw \
    -B /rigel/psych/users/pab2163/studyforrest/scripts/cpac/configs \
    -B /rigel/psych/users/pab2163/studyforrest/preproc \
    -B /rigel/psych/users/pab2163/studyforrest/scratch \
    /rigel/psych/app/cpac/cpac-singularity-image-06302020.simg /bids_dataset /outputs participant --participant_label sub-01  --pipeline_file /configs/cpac_init.yaml --n_cpus 10 --mem_gb 20 --save_working_dir
