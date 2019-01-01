function state_dyn_with_spectdist(if_normalize)
%
% Calculate and visualize state dynamics of temporal neteworks
% The distance between two snapshots is measured by a Laplacian spectral
% distance.
%
% The snapshots should be stored as adj1.csv, adj2.csv, ...
%
% 'if_normalize' specifies the distance measure used. The following lines are
% self-explanatory.

% preprocessing
[inname, Nwindow, nV, s_ave, file_size] = preprocess_state_dyn();

if (if_normalize == 1)
    disp('Unnormalized spectrum distance, combinatorial Laplacian');
elseif (if_normalize == 2)
    disp('Normalized spectrum distance, combinatorial Laplacian');
elseif (if_normalize == 3)
    disp('Unnormalized Laplacian spectrum distance, normalized Laplacian');
elseif (if_normalize == 4)
    disp('Normalized Laplacian spectrum distance, normalized Laplacian');
else
    error('1 <= if_normalize <= 4 violated');
end

clear spect_dist
spectrum = [];
nV_max = 0;


% Calculate the eigenvalue spectrum for each snapshot
for i = 1:Nwindow % i-th snapshot
    A = create_adj_mat(inname{i},nV);
    L = diag(sum(A)) - A; % combinatorial Laplacian matrix
    if (if_normalize==3 | if_normalize==4) % normalized Laplacian matrix
        v = 1 ./ sqrt(sum(A));
        v(v==Inf) = 0;
        v(v==-Inf) = 0;
        L = diag(v) * L * diag(v);
    end
    spectrum(:,i) = sort(real(eig(L)),'descend'); % eigenvalues in descending order
end

spectrum(end,:) = []; % eliminate zero eigenvalues

% Calculate the spectral distance
for i = 1:Nwindow
    dist(i,i) = 0.0;
    for j = 1:i-1
        dist(i,j) = sqrt(sum((spectrum(:,i) - spectrum(:,j)) .^ 2));
        if mod(if_normalize, 2) == 0 % Normalize the distance
            if max(max(spectrum(:,i)), max(spectrum(:,j))) > 1e-10
                dist(i,j) = dist(i,j) / sqrt(max(sum(spectrum(:,i) .^ 2), sum(spectrum(:,j) .^ 2)));
            else % rewritten around here; both snapshots are empty matrices
                dist(i,j) = 0.0;
            end
        end
        dist(j,i) = dist(i,j);
    end
end

plot_state_dyn(dist, s_ave, Nwindow, file_size);

end