function cl = plot_state_dyn(dist, s_ave, Nwindow, file_size)
% Calculate and plot the state dynamics given the distance matrix between
% snapshots
%
% Download the dunns function from the following website and save it as
% dunns.m in the same folder as that for the otehr source files
%
% https://uk.mathworks.com/matlabcentral/fileexchange/27859-dunn-s-index
%
%
% Input
%   dist: distance matrix
%   s_ave: time series of average node strength
%   Nwindow: number of windows, i.e., network snapshots 
%
% Output
%   cl: time series of the system's state
%
% A figure with three panels is also generated. The upper panel is the
% similarity matrix. The middle panel is the time series of the mean node
% strength (- mean event rate per node in a snapshot). The bottom panel
% is the time series of the system's state.

% If you want to omit some snapshots (typically because they do not have any event)
% specify the index of snapshots which will be removed from the analysis as follows:
%
% ind_del = [11:20 31:40];
% dist(ind_del,:) = [];
% dist(:,ind_del) = [];
% s_ave(ind_del) = [];
% file_size(ind_del) = [];
% Nwindow = Nwindow - size(ind_del,2);

% transform distance matrix to similarity matrix
dist = dist / max(max(dist));
simi = 1 - dist;
for i = 1:Nwindow
    if (file_size(i) == 0)
        simi(:,i) = 0.0;
        simi(i,:) = 0.0;
    end
end

dist_pdist_form = [];
% figure
for i=1:Nwindow
    dist_pdist_form = [dist_pdist_form dist(i,i+1:Nwindow)];
end
tree = linkage(dist_pdist_form, 'single');

% Calculate Dunn's index
Nc_max = 20; % largest number of clusters considered
dunn_list = [0]; % Dunn's index for different numbers of clusters.
% Set Dunn's index in the case of 1 cluster to 0 for convenience.
for Nc_tmp = 2:Nc_max
    cl = cluster(tree,'maxclust', Nc_tmp);
    dunn_list = [dunn_list dunns(Nc_tmp,dist,cl)];
end
[M,Nc] = max(dunn_list); % Select the number of states that maximizes the Dunn's index
fprintf('%d states\n', Nc);
cl = cluster(tree,'maxclust', Nc); % hierarchical clustering

close all
figure
pos = get(gcf,'pos');
set(gcf, 'pos', [pos(1), pos(2), 500, 700]);

% plot simialrity matrix
min_similarity_for_plot = 0.0; % to plot the similarity matrix in a color scale
max_similarity_for_plot = 1.0; % pl
subplot(5,1,1:3)
imagesc(simi)
c = colorbar;
c.Location = 'northoutside';
caxis([min_similarity_for_plot, max_similarity_for_plot]);
set(gca,'fontsize',18);
ylabel ('similarity', 'fontsize', 20);
text (-0.12*Nwindow, -0.08*Nwindow,'(d)','fontsize',28);
pos = get(gca, 'Position');
pos(1) = 0.14;
pos(3) = 0.84;
set(gca, 'Position', pos)

% plot time series of the event rate
subplot(5,1,4)
plot(1:Nwindow, s_ave,'r-');
xlim([0.5 Nwindow+0.5])
set(gca,'fontsize',18);
ylabel ('event rate', 'fontsize', 20);
pos = get(gca, 'Position');
pos(1) = 0.14;
pos(3) = 0.84;
set(gca, 'Position', pos)

% plot time series of the state
subplot(5,1,5)
stairs(1:Nwindow, cl, 'LineWidth', 1.5);
xlim([0.5 Nwindow+0.5])
ylim([0.6 max(cl)+0.4]);
yticks([1:max(cl)-1:max(cl)])
set(gca,'fontsize',18);
xlabel ('time', 'fontsize', 20);
ylabel ('state', 'fontsize', 20);
pos = get(gca, 'Position');
pos(1) = 0.14;
pos(3) = 0.84;
set(gca, 'Position', pos)

% Optionally output the dendrogram used in the hierarchical clustering
%
% figure
% dendrogram(tree,Nwindow);