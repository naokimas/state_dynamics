function state_dyn_with_deltacon()
%
% Calculate and visualize state dynamics of temporal neteworks
% The distance between two snapshots is measured by DELTACON.
% 
% This code uses MATLAB code for DELTACON downloaded from 
%
% http://web.eecs.umich.edu/~dkoutra/
%
% The snapshots should be stored as adj1.csv, adj2.csv, ...

% preprocessing
[inname, Nwindow, nV, s_ave, file_size] = preprocess_state_dyn();

clear simi

for i = 1:Nwindow
    simi(i,i) = 0.0; % force
    for j = 1:i-1
        if (file_size(i) > 0 & file_size(j) > 0) % both files are nonempty
            simi(i,j) = DeltaCon('edge', 'naive', inname{i}, inname{j}, 0.1);
        else
            simi(i,j) = 0;
        end
        simi(j,i) = simi(i,j);
    end
end

plot_state_dyn(1-simi, s_ave, Nwindow, file_size);

end