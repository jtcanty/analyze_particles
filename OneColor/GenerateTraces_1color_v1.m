% GenerateTraces_1color_v1.m
% Adapted by John Canty
% Last modified: 01/13/2016

% pixelconversion = 81.33 for 307D at 1.5x with 100x objective.

% Workflow:
% Take traces from UTrack and put into a cell. Prepare and run through
% PR_utrack_v3.m
pixelconversion = 81.33;

% Open directory 
dirAll = dir();
isFolder = [dirAll(:).isdir];
dirFolders = dirAll(isFolder);
FoldersName = {dirFolders.name};
FoldersName(ismember(FoldersName,{'.','..'})) = [];
moviesnum = numel(FoldersName);
cdir = cd;

%% Step 1: Prepare for parse and review
for i = 1:moviesnum
    %Load the "tracksFinal" file
    loadinput = strcat(cdir,'\',FoldersName{i},'\TrackingPackage\tracks\Channel_1_tracking_result.mat'); %create directory string
    load(loadinput); %brings up tracksFinal
  
    % Reshape traces
    [alltracks] = reshape_tracks(tracksFinal);

    %Prepare data for input into PR_utrack_v3.m  
    [idx, frame, params, trace] = prepare_for_PR(alltracks);
   
    % Save traces
    PR_utrack=[idx frame params trace];
    name=strcat('PR_input_',FoldersName{i},'.txt');
    dlmwrite(name,PR_utrack,'precision','%10.5f','delimiter','\t');

    clearvars -except 'moviesnum' 'pixelconversion' ...
                       'cdir' 'FoldersName' 

end
    
%% Step 2: Runs PR_utrack_v3.m and saves a file of checked traces for each movie
PR_output = [];
PR_input = dir('PR_input_*.txt');
PR_input_name = {PR_input.name};

for i=1:length(PR_input_name)
    [PR_output,trace_id,sig_all] = PR_utrack_v3(strcat(cdir,'\',PR_input_name{i}),pixelconversion);
    if isempty(PR_output)
        continue
    end
    split = strsplit(PR_input_name{i},'.');
    save(strcat(cdir,'\',split{1},'_PR_output'));
end
    
PR_final = dir('*_output.mat');
PR_final_name = {PR_final.name};
for i=1:length(PR_final_name)
     f = load(PR_final_name{i});
     for j = 1:length(f.PR_output);
        name = [num2str(i) '_fiona.txt'];
        dlmwrite(name,f.PR_output{j},'precision','%10.5f','delimiter','\t');
     end
end






