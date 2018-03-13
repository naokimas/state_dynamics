function state_dyn_with_spectdivergence(beta)
%
% Calculate and visualize state dynamics of temporal neteworks
% The distance between two snapshots is measured by a Laplacian spectral
% distance.
%
% The snapshots should be stored as adj1.csv, adj2.csv, ...
%
% Input 
%   beta: time for which a fictive diffusion dynamics is run on the network

% preprocessing
[inname, Nwindow, nV, s_ave, file_size] = preprocess_state_dyn();

clear dist
rho = {};
nV_max = 0;

% Calculate the density matrix at each time point
for i = 1:Nwindow
    A = create_adj_mat(inname{i},nV);
    L = diag(sum(A)) - A; % combinatorial Laplacian matrix
    L = full(L);
    [V, D] = eig(L); % columns of V are eigenvectors of L; L*V = V*D
    rho = horzcat(rho, V * diag(exp(-beta * diag(D))) * V' / sum(exp(-beta * diag(D)))); % density matrix
end

% Calculate the spectral divergence
for i = 1:Nwindow
    dist(i,i) = 0.0;
    lambda_i = real(eig(rho{i}));
    lambda_i(lambda_i < 1e-10) = []; % discard 0 eigenvalues to avoid NaN in calculating the entropy
    for j = 1:i-1
        lambda_j = real(eig(rho{j}));
        lambda_j(lambda_j < 1e-10) = []; % discard 0 eigenvalues
        mix = (rho{i} + rho{j}) / 2; % mixture matrix
        lambda_ij = real(eig(mix));
        lambda_ij(lambda_ij < 1e-10) = []; % discard 0 eigenvalues
        dist(i,j) = sqrt(- sum(lambda_ij .* log2(lambda_ij)) + ...
            0.5 * sum(lambda_i .* log2(lambda_i)) + 0.5 * sum(lambda_j .* log2(lambda_j)));
        dist(j,i) = dist(i,j);
    end
end

plot_state_dyn(dist, s_ave, Nwindow, file_size)

end