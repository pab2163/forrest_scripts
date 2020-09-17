#!/bin/bash

#SBATCH --account=psych
#SBATCH --job-name=forrest_cpac_fork_pipeine_no_qc
#SBATCH --mail-type=ALL
#SBATCH --constraint=docker
#SBATCH -c 8
#SBATCH --time=11:55:00
#SBATCH --mem-per-cpu=20gb

sub=$1

mkdir /rigel/psych/users/pab2163/studyforrest/preproc_forks/

module load singularity
singularity run \
    -B /rigel/psych/users/pab2163/studyforrest/bids_raw:/bids_dataset \
    -B /rigel/psych/users/pab2163/studyforrest/scripts/cpac/configs:/configs \
    -B /rigel/psych/users/pab2163/studyforrest/preproc_forks:/outputs \
    -B /rigel/psych/users/pab2163/studyforrest/scratch:/scratch \
    /rigel/psych/users/pab2163/singularity_images/cpac_1_7_august_10_2020.simg /bids_dataset /outputs participant --participant_label $sub  --pipeline_file /configs/studyforrest_pipelines_afni_skullstrip_no_qc.yaml --n_cpus 8 --mem_gb 20
