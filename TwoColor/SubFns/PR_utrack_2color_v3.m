% PR_utrack_2color_v3.m
% Adapted by John Canty 02/06/2017

% Inputs:   
%   inpath = input path
%   pixsize = pixelsize
%
% Outputs:
%   traces_out = on/off axis of each trace
%   trace_id = id of trace
%   sig_all = standard deviation of traces

function [traces_out,trace_id,sig_all] = PR_utrack_2color_v3(inpath,pixsize)

%load input data direct from specified path
in = load (inpath);

%% Step One: Break traces into separate spots
%input looks like: [ [index] [frame] [x] [y] [trace#]
disp('splitting traces');
limit = max(in(:,end));
lower = min(in(:,end));
traces = cell(1,limit-lower+1);
for i=lower:limit
    selector = logical(in(:,end) == i);
    if ~isempty(in(selector,3:4))
        traces{i-lower+1} = in(selector,3:4);
    end
end
limit = length(traces);
disp(['split into ' num2str(limit) ' traces.']);

%% Step Two: align and center each trace
%output: Aligned and centered traces for each two-color walker. Apply the
%same rotation matrix to each pair of channels for each walker.
traces = align_and_center(traces);
for i=1:limit
    if ~isempty(traces{i})
        traces{i} = traces{i}.*pixsize;       %convert to nm from pixels
    end    
end

%% Step Three: Review each two-color trace with user input
%user picks a start and finish with the mouse, or can reject trace entirely

do = 0;
while ~do
    
    %prompt = 'Finished pre-processing. Review traces? [Y or N]';
    %review = input(prompt,'s'); %NOTE: Turned off
    
    review='Y'; %LF added

    if strcmp(review,'Y')
        [traces,id,sig] = review_traces(traces);
        if isempty(traces)
            break
        end
        disp('aligning reviewed traces');
        traces = align_and_center(traces);
        do = 1;
    elseif strcmp (review,'N')
        do = 1;
    else
        disp('Please type Y or N');
    end
    
end

traces_out = traces;
trace_id = id;
sig_all = sig;

end

function [traces_out,trace_id,sig_all] = review_traces(traces_in)    %go through each trace and ask for some rudimentary edits/modifications
j = 0;
figure;
for i=1:2:length(traces_in)  
    sig_ch1 = std(abs(traces_in{i}(:,1)-smooth(traces_in{i}(:,1),10)));
    sig_ch2 = std(abs(traces_in{i+1}(:,1)-smooth(traces_in{i+1}(:,1),10)));
    if sig_ch1<3 && sig_ch2<3
        plot(traces_in{i}(:,1));
        hold on
        plot(traces_in{i+1}(:,1));
        prompt = ['Two-color traces ' num2str(i) ' & ' num2str(i+1) ': keep (k), mod(m), sep(s), ig(i), break(b) '];
        review = input(prompt,'s');
        if ( strcmp(review,'m') )       %modify by clicking on end and beginning of the trace
            endpoint = length(traces_in{i}(:,1));
            startpoint = 1;
            disp(['select endpoint, startpoint [' num2str(endpoint) ',' num2str(startpoint) ']']);
            [x,~] = ginput(2);          %we assume more likely to keep existing startpoint, so default to that if one point is picked
            if (length(x)>=1)
                endpoint = min(round(x(1)),endpoint);
                if (length(x)>=2)
                    startpoint = round(x(2));
                end
            end
            disp(['setting end, start to ' num2str(endpoint) ',' num2str(startpoint) ]);
            j  = j + 2;
            disp(['count is ' num2str(j)])
            traces_out{j} = traces_in{i}(startpoint:endpoint,:);
            trace_id(j,1) = i;
            sig_all(j,1) = sig_ch1;
        elseif strcmp(review,'s')               %split the traces up as user inputs
            x = ginput(Inf);                    %get a bunch of points from ginput, which can be open-ended
            endpoint = length(traces_in{i});
            startpoint = 1;
            disp(['select beginning and end of each sub-trace, press enter when finished [' num2str(endpoint) ',' num2str(startpoint) ']']);
            for (j = 2:2:length(x))             %loop over the traces and put the sub-traces in the traces_out object
                pt_1 = round(x(j-1,1));
                pt_2 = round(x(j,1));
                if (pt_1 > pt_2)
                    j = j + 1;
                    disp(['count is ' num2str(j)])
                    traces_out{j} = traces_in{i}(pt_2:pt_1,:);
                    trace_id(j,1) = i;
                    sig_all(j,1) = sig_ch1;
                    disp (['made sub trace from' num2str(pt_2) ' to ' num2str(pt_1) '.']);
                elseif (pt_2 > pt_1)
                    j = j + 1;
                    traces_out{j} = traces_in{i}(pt_1:pt_2,:);
                    trace_id(j,1) = i;
                    sig_all(j,1) = sig_ch1;
                    disp (['made sub trace from' num2str(pt_2) ' to ' num2str(pt_1) '.']);
                end
            end
        elseif strcmp(review,'i');        
            disp(['ignoring traces' num2str(i) ' & ' num2str(i+1)]);
        elseif strcmp(review,'b');        
            break
        else
            disp(['keeping trace' num2str(i) ' & ' num2str(i+1)]);
            j = j + 2;
            disp(['count is ' num2str(j)])
            traces_out{j-1} = traces_in{i};
            traces_out{j} = traces_in{i+1};
            trace_id(j-1,1) = i;
            trace_id(j,1) = i+1;
            sig_all(j-1,1) = sig_ch1;
            sig_all(j,1) = sig_ch2;
        end 
    end     
end 
if exist('traces_out') == 0
    traces_out = [];
    trace_id =[];
    sig_all = [];
end
end 


function traces_out = align_and_center(traces)

limit = length(traces);
% Aligh pairs of two-color traces
for i=1:2:limit
    try
        if ~isempty(traces{i})
            disp(['rotating trace ' num2str(i) ]);
            [traces{i},traces{i+1}] = alignTrace_NaNproof_twocolor(traces{i},traces{i+1});
        end
    catch %this is if an error occurs, loop is aborted and it continues to next iteration
        fprintf('Trace rotation messed up');
        continue;  % Jump to next iteration
    end %for the try     
end

%and re-align and normalize each trace
for i=1:2:limit
    if ~isempty(traces{i} && traces{i+1})
        [a b] = polyfit (traces{i}(:,1),(1:1:length(traces{i}(:,1)))',1);
        if (a(1) < 0);              %if the traces is decreasing (in the x axis), flip to make it increasing
            traces{i} = -traces{i};
        end
        % Normalize trace
        traces{i}(:,1) = traces{i}(:,1) - min(traces{i}(:,1));
        traces{i}(:,2) = traces{i}(:,2) - min(traces{i}(:,2)); 
        traces{i+1}(:,1) = traces{i+1}(:,1) - min(traces{i+1}(:,1));
        traces{i+1}(:,2) = traces{i+1}(:,2) - min(traces{i+1}(:,2));
    end
end

traces_out = traces;


end

    

