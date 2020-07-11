%% just movie (normalized)
clear
TR = 2
paths = dir(fullfile('../../data/realignment_params', '*movie*1D'))
b = transpose(struct2cell(paths))
filepaths = b(:,1)
folderpaths = b(:,2)
complete_paths = strcat(folderpaths,'/', filepaths)

[CLIM, ix_subject_scan,MU,SIGMA,P]=cat_mov_reg_power(complete_paths,TR, 'brain_radius_in_mm',50);

%% just movie (not normalized)
clear
TR = 2
paths = dir(fullfile('../../data/realignment_params', '*movie*1D'))
b = transpose(struct2cell(paths))
filepaths = b(:,1)
folderpaths = b(:,2)
complete_paths = strcat(folderpaths,'/', filepaths)

[CLIM, ix_subject_scan,MU,SIGMA,P]=cat_mov_reg_power(complete_paths,TR, 'brain_radius_in_mm',50, 'normalize_power_flag', 0);

