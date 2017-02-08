% Plot ch2 traces
function traces_out = plot_trace_ch2(ch2_trace)
    curr = ch2_trace.('ch2');
    plot(curr(:,1),curr(:,2),'r');
    hold on
end