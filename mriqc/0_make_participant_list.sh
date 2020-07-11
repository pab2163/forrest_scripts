# make .txt file with list of participants to run run mriqc for

cd ../../bids_raw
rm ../participant_list.txt
for i in sub*;
	do
		echo $i >> ../participant_list.txt;
	done
