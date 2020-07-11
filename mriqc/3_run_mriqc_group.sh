#!/bin/sh

#SBATCH --account=psych
#SBATCH --job_name=mriqc
#SBATCH -c 10
#SBATCH --time=11:55:00
#SBATCH --mem-per-cpu=10gb

sub_name=$1

module load singularity
singularity exec -e ../../../singularity_images/mriqc_latest.sif mriqc ../../bids_raw/ ../../mriqc/ group
