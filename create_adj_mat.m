function A = create_adj_mat(inname,nV)
% create the adjacency matrix from an edge list given by the input file 
% Input
%   inname: infile name
%      The input file should consist of three columns.
%      Each row corresponds to an edge.
%      1st and 2nd columns: the two nodes on the edge
%      3rd column: edge weight
%      Undirected network assumed
%   nV: number of nodes
% Output
%   A: adjacency matrix in the sparse matrix format

file1 = dir(inname);
file_size = file1.bytes;
if file_size == 0 % input file is empty
    A = zeros(nV,nV);
else % input file is non-empty
    edge_list = load(inname, '-ascii');
    A = spconvert([edge_list ; edge_list(:,[2 1 3])]); % adjacency matrix
    % edge_list(:,[2 1 3]) is a copy of the list of edges "edge_list"
    % but the two nodes constituting the edge swapped
    if size(A,1) < nV
        A(nV,nV) = 0; % enlarge matrix A to an nV * nV matrix
    end
end
end