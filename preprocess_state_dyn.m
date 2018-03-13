function [inname, Nwindow, nV, s_ave, file_size] = preprocess_state_dyn()
%
% Preproess input data (i.e., adj.*.csv) for calculating state dynamics of
% a temporal network
%
% inname: time series of input files
% Nwindow: number of time windows
% nV: number of nodes
% s_ave: time series of mean node strength
% file_size: time series of the file size of the adjacency matrix
%
% Note: One should set dir_data to the path of the folder that contains
% adj.*.csv

dir_data = '/Users/usename/foldername/';
inFileList = dir([strcat(dir_data, 'adj*.csv')]);
Nwindow = size(inFileList,1);

s_ave = zeros(Nwindow,1); % initialization
nV = 0;
inname = cell(Nwindow,1); % initialization
for i = 1:Nwindow
    inname{i} = [strcat(dir_data, 'adj', num2str(i), '.csv')];
    file1 = dir(inname{i});
    file_size(i) = file1.bytes;
    if file_size(i) > 0 % file is not empty
        edge_list = load(inname{i}, '-ascii'); % just to calculate nV
        if nV < max(max(edge_list(:,1:2)))
            nV = max(max(edge_list(:,1:2)));
        end
        s_ave(i) = sum(edge_list(:,3)); % sum of the edge weight in the snapshot
    else % file is empty
        disp(strcat('File ', inname{i}, ' is empty'));
    end
end

s_ave = s_ave/nV*2; % mean node strength in a snapshot, i.e., average number of events a node has in a snapshot
fprintf('Number of nodes = %d\n', nV);
end