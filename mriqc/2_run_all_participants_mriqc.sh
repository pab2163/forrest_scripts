cat ../../participant_list.txt | while read line; 
do 
	echo $line; 
	sbatch 1_run_one_participant_mriqc.sh $line
done
