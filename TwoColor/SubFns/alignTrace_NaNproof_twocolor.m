function [cy3_out,cy5_out]= alignTrace_NaNproof_twocolor(cy3,cy5)
% Update: Modified for one color
% Adapted by John Canty
%  Calculates the principal components of a set of data points
%  and aligns the set along the longest axis 
%  (in dynein processive motor's case, along the axoneme/MT)
%  Repeats the same rotation mapping for both channels.
%  
%  Inputs:
%     x/y coordinates for two separate channels
%  
%  Outputs:
%   a file x_filename, containing only the data of the 
%  longest axis and a file rot_filename with both x and y.
%
% alignTrace v.0.1 
% Elizabeth Villa, Physiology Course 2007
% villa@ks.uiuc.edu


fprintf(1,'Rotating along the direction of the axoneme... ')

% Read the data 
cy3_x = cy3(:,1);
cy3_y = cy3(:,2);
cy5_x = cy5(:,1);
cy5_y = cy5(:,2);

%substitute -1s for NaNs, to prevent confusion
for i = 1:length(cy3_x)
    if (cy3_x(i) == -1)
        cy3_x(i) = NaN;
        cy3_y(i) = NaN;
    end
end   

% repeat for Cy5 channel
for i = 1:length(cy5_x)
    if (cy5_x(i) == -1)
        cy5_x(i) = NaN;
        cy5_y(i) = NaN;
    end
end   

%Cy3 is generally better, so strip out NaNs, and run pca on that
%rebuild Cy3 trace without NaNs. Order doesn't matter in pca, right?
cy3_x_strip = -1;
cy3_y_strip = -1;
counter = 0;
for i = 1:length(cy3_x)
    if (isnan(cy3_x(i)))
        continue
    else
        counter = counter + 1;
        cy3_x_strip(counter) = cy3_x(i);
        cy3_y_strip(counter) = cy3_y(i);
    end
end

% The deviation from the mean for Cy3
cy3_xc = cy3_x - nanmean(cy3_x);
cy3_yc = cy3_y - nanmean(cy3_y);

% Same operation for Cy5 to preserve mapping
cy5_xc = cy5_x - nanmean(cy5_x);
cy5_yc = cy5_y - nanmean(cy5_y);

% Calculate the principal components of Cy3 trace
pca = princomp([cy3_x_strip' cy3_y_strip']);     
disp(pca(3)); disp(pca(4));

% Get the angle of the longer axis
alpha = atan(pca(3)/pca(4));


% Apply rotation matrix to Cy3
cy3_xx = nanmean(cy3_x) + cy3_xc * cos(alpha) - cy3_yc * sin(alpha);
cy3_yy = nanmean(cy3_y) + cy3_xc * sin(alpha) + cy3_yc * cos(alpha); 
cy3_out = [cy3_xx cy3_yy];

% Apply same rotation matrix to Cy5
cy5_xx = nanmean(cy5_x) + cy5_xc * cos(alpha) - cy5_yc * sin(alpha);
cy5_yy = nanmean(cy5_y) + cy5_xc * sin(alpha) + cy5_yc * cos(alpha); 
cy5_out = [cy5_xx cy5_yy];

fprintf(1,'Finished rotating the trace.\n ')


  