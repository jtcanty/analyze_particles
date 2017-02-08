% reformat_for_PR.m
% This function reformats obtained dual color traces for entry into
% PR_utrack.m

function [dual_walkers] = reformat_for_PR(vars)

dual_walkers = [];
j = 0;
for i = 1:length(vars)
    var = evalin('base', vars{i});
    k = size(var,1);
    trace_id = i*ones(k,1);
    frame = linspace(1,k,k)';
    id = linspace(j+1,j+k,k)';
    % Reformat for PR_utrack format
    var_reformat = [id frame var trace_id];
    dual_walkers = [dual_walkers;var_reformat];
    j = j+k;
end