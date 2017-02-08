% Plot ch1 traces
function traces_out = plot_trace_ch1(ch1_trace)
    curr = ch1_trace.('ch1');
    plot(curr(:,1),curr(:,2),'b');
    hold on
end