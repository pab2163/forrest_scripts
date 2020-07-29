cat participants.txt | while read line; 
do 
	echo $line; 
	sbatch one_participant_cpac_slurm.sh $line
done
