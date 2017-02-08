% TwoColorScreen.m                      Created by John Canty
% Last updated 02/04/2017
% 
% This function takes a list files with tracked particles from 2 channels
% The traces of each channel are plottedon. The user is
% then prompted to select pairs of traces to save.
%
% Inputs:
%   PR_input_name = list of files containing traces
%
% Outputs:
%   dual_walkers = array of traces of dual-color walkers
%   Note: The two channels of a single dual-colored walker are saved as two consecutive traces.
%       i.e. Traces 1/2 are channels 1/2 of the first walker. Traces 3/4 are channels 1/2 of the second 
%             walker. Traces 5/6 are channels 1/2 of the third walker. etc...


function dual_walkers = TwoColorScreen(PR_input_name,i)
%% Step 1: Plot global traces from both channels
% Loading each channel
ch1_path = strcat(cdir,'\',PR_input_name{i});
ch2_path = strcat(cdir,'\',PR_input_name{i+1});
ch1 = load(ch1_path);
ch2 = load(ch2_path);
ch_array ={ch1 ch2};
ch_name = {'ch1','ch2'};

% Splitting traces
ch1_traces = struct('ch1',{});
ch2_traces = struct('ch2',{});
for i = 1:2
    first = min(ch_array{i}(:,end));
    last = max(ch_array{i}(:,end));
    for j = first:last
        selector = logical(ch_array{i}(:,end) == j);
        if ~isempty(ch_array{i}(selector,3:4))
            if i == 1
                ch1_traces(j-first+1).(ch_name{1}) = ch_array{i}(selector,3:4);
            elseif i == 2
                ch2_traces(j-first+1).(ch_name{2}) = ch_array{i}(selector,3:4);
            end
        end
     end
end

%% Step 2: Select colocalizing traces
% Use the paintbrush tool to select each trace from two-color colocalizing traces
% and save them at ch1_i and ch2_i (i = trace number). You can delete
% traces after saving them as variables so you don't get confused.
figure;
arrayfun(@plot_trace_ch1, ch1_traces);
arrayfun(@plot_trace_ch2, ch2_traces);
pause

%% Step 3: Obtain variables from workspace and merge into a single
% array. Format for PR_utrack_2color
workspacevars = who;
str = regexpi(workspacevars,'ch*\d_*\d');
ind = ~cellfun('isempty',str);
vars = workspacevars(ind);

dual_walkers = reformat_for_PR(vars);
end
    




