% Prepare data for PR_utrack_v3.m 
function [idx, frame, params, trace] = prepare_for_PR(alltracks)

atprime = alltracks';
params = cell2mat(atprime); %Converts data into array
idx = linspace(1,length(params),length(params))'; %Prepare index column

trace = zeros(length(idx),1);
frame = zeros(length(idx),1);
n = 1;
for k = 1:length(atprime) %Prepare trace column and frame column
    m = length(atprime{k}); 
    trace(n:m+n-1,1) = k*ones(length(atprime{k}),1);
    frame(n:m+n-1,1) = linspace(1,length(atprime{k}),length(atprime{k}));
    n = m+n;
end
end