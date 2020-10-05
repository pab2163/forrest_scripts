#!/bin/bash

#SBATCH --account=psych
#SBATCH --job-name=forrest_cpac_fork_pipeine_filter_no_qc
#SBATCH --mail-type=ALL
#SBATCH --constraint=docker
#SBATCH -c 1
#SBATCH --time=11:59:00
#SBATCH --mem-per-cpu=100gb

sub=$1

mkdir /rigel/psych/users/pab2163/studyforrest/preproc_forks/

module load singularity
singularity run \
    -B /rigel/psych/users/pab2163/studyforrest/bids_raw:/bids_dataset \
    -B /rigel/psych/users/pab2163/studyforrest/scripts/cpac/configs:/configs \
    -B /rigel/psych/users/pab2163/studyforrest/preproc_forks:/outputs \
    -B /rigel/psych/users/pab2163/studyforrest/scratch:/scratch \
    -B /rigel/psych/users/pab2163/studyforrest/tmp:/tmp \
    /rigel/psych/users/pab2163/singularity_images/cpac-1.71_dev.simg /bids_dataset /outputs participant --participant_label $sub  --pipeline_file /configs/studyforrest_pipelines_filter_no_qc.yaml --n_cpus 1 --mem_gb 100
