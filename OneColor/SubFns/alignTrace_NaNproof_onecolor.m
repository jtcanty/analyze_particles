function [out_655]= alignTrace_NaNproof_onecolor(d_655)
%UPDATE 01/24/2012: Fixed to be for one color, not two


%  Calculates the principal components of a set of data points
%  and aligns the set along the longest axis 
%  (in dynein processive motor's case, along the axoneme/MT)
%
%      usage:   alignTrace(filename);
%
%  outputs a file x_filename, containing only the data of the 
%  longest axis and a file rot_filename with both x and y.
%
% alignTrace v.0.1 
% Elizabeth Villa, Physiology Course 2007
% villa@ks.uiuc.edu


fprintf(1,'Rotating along the direction of the axoneme... ')

% Read the data (expects two columns with x,y)

% d_655 = load (filename655);
x655 = d_655(:,1);
y655 = d_655(:,2);

%substitute -1s for NaNs, to prevent confusion
for i = 1:length(x655)
    if (x655(i) == -1)
        x655(i) = NaN;
        y655(i) = NaN;
    end
end
        

%655 is generally better, so strip out NaNs, and run pca on that
%rebuild 655 trace without NaNs. Order doesn't matter in pca, right?
x655_strip = -1;
y655_strip = -1;
counter = 0;
for i = 1:length(x655)
    if (isnan(x655(i)))
        
    else
        counter = counter + 1;
        x655_strip(counter) = x655(i);
        y655_strip(counter) = y655(i);
    end
end

% The deviation from the mean

disp('means:');
disp(nanmean(x655));
disp(nanmean(y655));
%do same operatiion deviation for 655 trace, to preserve mapping
xc655 = x655 - nanmean(x655);
yc655 = y655 - nanmean(y655);

% Calculate the principal components
pca = princomp([x655_strip' y655_strip']);     %pca for 655 trace only
disp(pca(3)); disp(pca(4));

% Get the angle of the longer axis
alpha = atan(pca(3)/pca(4));


%do the same to the other trace
xx655 = nanmean(x655) + xc655 * cos(alpha) - yc655 * sin(alpha);
yy655 = nanmean(y655) + xc655 * sin(alpha) + yc655 * cos(alpha); 
out_655 = [xx655 yy655];

% % Hack
% xx = xx(5:end-5);
% yy = yy(5:end-5);

% We want the value of the distance along the axoneme to
% increase (so that when we do statistics we count all 
% forward/backwards steps with the same convention.

% if xx(1) > xx(end)    
%     xx = mean(xx) - xx ;
%  %   yy = mean(yy) - yy ;
% end


% Show the traces in a figure, with the principal axes displayed
%figure;
%plot(x,y,'-x'); hold on;
%plot(xx,yy, '-x', 'Color', 'r');

% Write files for both coordinates
% data = [xx'; yy'];
% foutname = ['rot_' filename585];
% fout =fopen(foutname,'w');
% fprintf(fout, '%f %f\n', data);
% fclose(fout);
% 
% % Write another file with only the coordinate along the axoneme.
% foutname = ['x_' filename585];
% fout =fopen(foutname,'w');
% fprintf(fout, '%f\n', xx');
% fclose(fout);
% 
% %Do the same for the 655 trace
% % Write files for both coordinates
% data = [xx655'; yy655'];
% foutname = ['rot_' filename655];
% fout =fopen(foutname,'w');
% fprintf(fout, '%f %f\n', data);
% fclose(fout);
% 
% % Write another file with only the coordinate along the axoneme.
% foutname = ['x_' filename655];
% fout =fopen(foutname,'w');
% fprintf(fout, '%f\n', xx655');
% fclose(fout);


fprintf(1,'Finished rotating the trace.\n ')


  