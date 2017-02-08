% Create a cell array where each element is an array of data for each trace
function [alltracks] = reshape_tracks(tracksFinal)

alltracks = cell(1,length(tracksFinal));
for j = 1:length(tracksFinal)
    data = tracksFinal(j).tracksCoordAmpCG;   
    alltracks{1,j} = reshape(data,[8 length(data)/8])';
end
end