#!/bin/sh

#SBATCH --account=psych
#SBATCH --job-name=fmriprep
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --time=31:55:00
#SBATCH --mem=30gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pab2163

mkdir /rigel/psych/users/pab2163/studyforrest/fmriprep_test/
mkdir /rigel/psych/users/pab2163/studyforrest/fmriprep_work

module load singularity

singularity run /rigel/psych/projects/software/fmriprep-1.4.0.simg \
	/rigel/psych/users/pab2163/studyforrest/bids_raw/ \
	/rigel/psych/users/pab2163/studyforrest/fmriprep_test/ \
	participant --participant-label sub-20 \
	-w /rigel/psych/users/pab2163/studyforrest/fmriprep_work \
	--nthreads 8 --fs-license-file /rigel/psych/users/pab2163/PACCT/scripts/fmriprep/fmriprep_license.txt