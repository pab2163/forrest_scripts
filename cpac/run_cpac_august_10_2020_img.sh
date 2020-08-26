#!/bin/bash

#SBATCH --account=psych
#SBATCH --job-name=forrest_cpac_test
#SBATCH --mail-type=ALL
#SBATCH --constraint=docker
#SBATCH -c 8
#SBATCH --time=11:55:00
#SBATCH --mem-per-cpu=20gb

sub=$1

module load singularity
singularity run \
    -B /rigel/psych/users/pab2163/studyforrest/bids_raw:/bids_dataset \
    -B /rigel/psych/users/pab2163/studyforrest/scripts/cpac/configs:/configs \
    -B /rigel/psych/users/pab2163/studyforrest/cpac_init:/outputs \
    -B /rigel/psych/users/pab2163/studyforrest/scratch:/scratch \
    /rigel/psych/users/pab2163/singularity_images/cpac_1_7_august_10_2020.simg /bids_dataset /outputs participant --participant_label $sub  --data_config_file /configs/data_config_cpac_init_default.yml --pipeline_file /configs/cpac_august_10_2020.yaml --n_cpus 8 --mem_gb 20
