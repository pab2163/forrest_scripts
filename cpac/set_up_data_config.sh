singularity run /rigel/psych/app/cpac/cpac-singularity-image-06302020.simg ../../bids_raw/ ../../preproc/ cli -- utils data_config new_settings_template

singularity run /rigel/psych/app/cpac/cpac-singularity-image-06302020.simg /rigel/psych/users/pab2163/studyforrest/bids_raw ../../preproc/ cli -- utils data_config build data_settings.yml 