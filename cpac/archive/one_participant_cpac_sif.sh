#!/bin/bash

#SBATCH --account=psych
#SBATCH --job-name=forrest_cpac_test
#SBATCH --mail-type=ALL
#SBATCH --constraint=docker
#SBATCH -c 1
#SBATCH --time=11:55:00
#SBATCH --mem-per-cpu=20gb

sub=$1

module load singularity
singularity run \
    -B /rigel/psych/users/pab2163/studyforrest/bids_raw_temp:/bids_dataset \
    -B /rigel/psych/users/pab2163/studyforrest/scripts/cpac/configs:/configs \
    -B /rigel/psych/users/pab2163/studyforrest/cpac_init:/outputs \
    -B /rigel/psych/users/pab2163/studyforrest/scratch:/scratch \
    /rigel/psych/users/pab2163/singularity_images/cpac_1_7_july_29_2020.simg /bids_dataset /outputs participant --participant_label $sub  --data_config_file /configs/data_config_cpac_init_default.yml --n_cpus 1 --mem_gb 20
