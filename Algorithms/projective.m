function [px] = projective (x, t, d, m, r) 
% PROJECTIVE  
%
% CALL: [px] = projective (x, t, d, m, r);
%
% INPUTS:
%   x: the vector containing the scalar observations
%   t: delay parameter used in embedding
%   d: embedding dimension to consider
%   m: dimensiona of null space
%   r: number of nearest neighbors to consider
%
% OUTPUT:
%   px: cleaned scalar observations
%
% copiright (c) and written by David Chelidze 4/20/2011
% [px] = projective (foetal_ecg(:,2), 1, 50, 45, 1500);
 
if nargin < 5
    error('need five input variables')
end
if nargin > 5
    error('too many input variables, needs only five')
end
 
% check data and make a raw vector of scalar data
if min(size(x)) ~= 1
   error('first input should be a vector of scalar data points.')
else
    x=x(:)'; % just the way we need it
end
px = x;
 
n = length(x) - d*t; % maximum number of reconstructed points possible

indx = 1:n; % index of points in the embedding
y = zeros(d+1,n);
dy = y; % initialize corrective array

% reconstruct the phase space
for i = 1:d+1
    y(i,:) = x(indx+(i-1)*t);
end

% define the weighting matrix
W = eye(d+1,d+1); W(1,1) = 10^3; W(d+1,d+1) = 10^3;

fprintf('Partitioning data\n')
[kd_tree, q] = kd_partition(y, 256); % partition into kd-tree

fprintf('Filtering data\n')
for k = 1:n % find the nearest neighbors and their properties
    [nns, ~, ~] = kd_search(y(:,k), r, kd_tree, y(:,q));
    nns = nns{1};
    for i = 1:d
        nns(i,:) = nns(i,:) - mean(nns(i,:)); % remove the mean
    end
    D = nns*nns.'/r; % find correlation matrix
    G = W*D*W; % transform it
    %[E,~] = eig(G); % assuming the MATLAB gives them in increasing order
    %E = E(:,end-1:end); 
    %E = E(1:m);
    % if eig does not sort correctly use the following instead:
    [E,g] = eig(G);
    [~,srt] = sort(diag(g));
    E = E(:,srt(1:m));
    nns(:,1) = (nns(:,1) - mean(nns,2));
    dy(:,k) = W\(E*E.'*W*nns(:,1)); % corrective vector
    dy(:,k) = mean(nns,2) + dy(:,k);
    px(i) = mean(dy(:,k));
end

% clean the time series
indx = [0:t:d*t, n+(0:t:d*t)];
for q = [1:d+1, d:-1:1]
    for l = (1+indx(q)):indx(q+1)
        cx = 0;
        for k = 1:q % go through all of possible corrections
        cx = cx + dy(k,l-(k-1)*t); % all possible corrections to x(l)
        end
        px(l) = x(l) -  cx/q; % cleaned values
    end
end

%--------------------------------------------------------------------------            
function [kd_tree, r] = kd_partition(y, b, c)
% KD_PARTITION  Create a kd-tree and partitioned database for efficiently 
%               finding the nearest neighbors to a point in a 
%               d-dimensional space.
%
% USE: [kd_tree, r] = kd_partition(y, b, c);
%
% INPUT:
%   y: original multivariate data (points arranged columnwise, size(y,1)=d)
%   b: maximum number of distinct points for each bin (default is 100)
%   c: minimum range of point cluster within a final leaf (default is 0)
%
% OUTPUT:
%   kd_tree structure with the following variables:
%       splitdim: dimension used in splitting the node
%       splitval: corresponding cutting point
%       first & last: indices of points in the node
%       left & right: node #s of consequent branches to the current node
%   r: sorted index of points in the original y corresponding to the leafs
%
% to find k-nearest neighbors use kd_search.m
%
% copyrighted (c) and written by David Chelidze, January 28, 2009.
 
% check the inputs
if nargin == 0
    error('Need to input at least the data to partition')
elseif nargin > 3
    error('Too many inputs')
end
 
 
% initializes default variables if needed
if nargin < 2
    b = 100;
end
if nargin < 3
    c = 0;
end
 
[d, n] = size(y); % get the dimension and the number of points in y
 
r = 1:n; % initialize original index of points in y
 
% initializes variables for the number of nodes and the last node
node = 1;
last = 1;
 
% initializes the first node's cut dimension and value in the kd_tree
kd_tree.splitdim = 0;
kd_tree.splitval = 0;
 
% initializes the bounds on the index of all points
kd_tree.first = 1;
kd_tree.last = n;
 
% initializes location of consequent branches in the kd_tree
kd_tree.left = 0;
kd_tree.right = 0;

while node <= last % do until the tree is complete
    
    % specify the index of all the points that are partitioned in this node
    segment = kd_tree.first(node):kd_tree.last(node);
    
    % determines range of data in each dimension and sorts it
    [rng, index] = sort(range(y(:,segment),2));
    
    % now determine if this segment needs splitting (cutting)
    if rng(d) > c && length(segment)>= b % then split
        yt = y(:,segment); 
        rt = r(segment);
        [sorted, sorted_index] = sort(yt(index(d),:));
        % estimate where the cut should go
        lng = size(yt,2);
        cut = (sorted(ceil(lng/2)) + sorted(floor(lng/2+1)))/2;
        L = (sorted <= cut); % points to the left of cut
        if sum(L) == lng % right node is empty
            L = (sorted < cut); % decrease points on the left
            cut = (cut + max(sorted(L)))/2; % adjust the cut
        end
        
        % adjust the order of the data in this node
        y(:,segment) = yt(:,sorted_index); 
        r(segment) = rt(sorted_index);
 
        % assign appropriate split dimension and split value
        kd_tree.splitdim(node) = index(d);
        kd_tree.splitval(node) = cut;
        
        % assign the location of consequent bins and 
        kd_tree.left(node) = last + 1;
        kd_tree.right(node) = last + 2;
        
        % specify which is the last node at this moment
        last = last + 2;
        
        % initialize next nodes cut dimension and value in the kd_tree
        % assuming they are terminal at this point
        kd_tree.splitdim = [kd_tree.splitdim 0 0];
        kd_tree.splitval = [kd_tree.splitval 0 0];
 
        % initialize the bounds on the index of the next nodes
        kd_tree.first = [kd_tree.first segment(1) segment(1)+sum(L)];
        kd_tree.last = [kd_tree.last segment(1)+sum(L)-1 segment(lng)];
 
        % initialize location of consequent branches in the kd_tree
        % assuming they are terminal at this point
        kd_tree.left = [kd_tree.left 0 0];
        kd_tree.right = [kd_tree.right 0 0];
        
    end % the splitting process
 
    % increment the node
    node = node + 1;
 
end % the partitioning

%--------------------------------------------------------------------------            
function [pqr, pqd, pqi] = kd_search(y,r,tree,yp)
% KD_SEARCH     search kd_tree for r nearest neighbors of point yq.
%               Need to partition original data using kd_partition.m
%
% USE: [pqr, pqd, pqi] = kd_search(y,r,tree,yp);
%
% INPUT:
%       y: array of query points in columnwise form
%       r: requested number of nearest neighbors to the query point yq
%       tree: kd_tree constructed using kd_partition.m
%       yp: partitioned (ordered) set of data that needs to be searched
%          (using my kd_partirion you want to input ym(:,indx), where ym 
%           is the data used for partitioning and indx sorted index of ym)
%
% OUTPUT:
%       pqr: cell array of the r nearest neighbors of y in yp 
%       pqd: cell array of the corresponding distances
%       pqi: cell array of the indices of r nearest neighbors of y in yp 
%
% copyright (c) and written by David Chelidze, February 02, 2009.
 
% check inputs
if nargin < 4
    error('Need four input variables to work')
end
 
% declare global variables for subfunctions
global yq qri qr qrd finish b_lower b_upper
 
[~, n] = size(y);
pqr = cell(n,1);
pqd = cell(n,1);
pqi = cell(n,1);
 
for k = 1:n
    yq = y(:,k);
    qrd = Inf*ones(1,r); % initialize array for r distances
    qr = zeros(size(yq,1),r); % initialize r nearest neighbor points
    qri = zeros(1,r); % initialize index of r nearest neighbors
    finish = 0; % becomes 1 after search is complete
 
    % set up the box bounds, which start at +/- infinity (whole kd space)
    b_upper = Inf*ones(size(yq));
    b_lower = -b_upper;
 
    kdsrch(1,r,tree,yp); % start the search from the first node
    pqr{k} = qr;
    pqd{k} = sqrt(qrd);
    pqi{k} = qri;
end
 
%--------------------------------------------------------------------------            
function kdsrch(node,r,tree,yp)
% KDSRCH    actual kd search
% this drills down the tree to the end node and updates the 
% nearest neighbors list with new points
%
% INPUT: starting node number, and kd_partition data
%
% copyright (c) and written by David Chelidze, February 02, 2009.
 
global yq qri qr qrd finish b_lower b_upper
 
% first find the terminal node containing yq
if tree.left(node) ~= 0 % not a terminal node, search deeper
 
    % first determin which child node to search
    if yq(tree.splitdim(node)) <= tree.splitval(node)
        % need to search left child node
        tmp = b_upper(tree.splitdim(node));
        b_upper(tree.splitdim(node)) = tree.splitval(node);
        kdsrch(tree.left(node),r,tree,yp);
        b_upper(tree.splitdim(node)) = tmp;
    else % need to search the right child node
        tmp = b_lower(tree.splitdim(node));
        b_lower(tree.splitdim(node)) = tree.splitval(node);
        kdsrch(tree.right(node),r,tree,yp);
        b_lower(tree.splitdim(node)) = tmp;
    end % when the terminal node (leaf) containing yq is reached
    if finish % done searching
        return
    end
 
    % check if other nodes need to be searched
    if yq(tree.splitdim(node)) <= tree.splitval(node)
        tmp = b_lower(tree.splitdim(node));
        b_lower(tree.splitdim(node)) = tree.splitval(node);
        if overlap(yq, b_lower, b_upper, qrd(r)) 
            % need to search the right child node
            kdsrch(tree.right(node),r,tree,yp);
        end
        b_lower(tree.splitdim(node)) = tmp;
    else
        tmp = b_upper(tree.splitdim(node));
        b_upper(tree.splitdim(node)) = tree.splitval(node);
        if overlap(yq, b_lower, b_upper, qrd(r)) 
            % need to search the left child node
            kdsrch(tree.left(node),r,tree,yp);
        end
        b_upper(tree.splitdim(node)) = tmp;
    end % when all the other nodes are searched
    if finish % done searching
        return
    end
 
else % this is a terminal node: update the nearest neighbors
 
    yt = yp(:,tree.first(node):tree.last(node)); % all points in node
    dstnc = zeros(1,size(yt,2));
    for k = 1:size(yt,1)
        dstnc = dstnc + (yt(k,:)-yq(k)).^2; 
    end
    %dstnc = sum((yt-yq*ones(1,size(yt,2))).^2,1); % distances squared
    qrd = [qrd dstnc]; % current list of distances squared
    qr = [qr yt]; % current list of nearest neighbors
    qri = [qri tree.first(node):tree.last(node)];
    [qrd, indx] = sort(qrd); % sorted distances squared and their index
    qr = qr(:,indx); % sorted list of nearest neighbors
    qri = qri(indx); % sorted list of indexes
    if size(qr,2) > r % truncate to the first r points
        qrd = qrd(1:r);
        qr = qr(:,1:r);
        qri = qri(1:r);
    end
    % be done if all points are with this box on the first run
    if within(yq, b_lower, b_upper, qrd(r));
        finish = 1;
    end % otherwise (during backtracking) WITHIN will always return 0.
    
end % if
 
%--------------------------------------------------------------------------            
function flag = within(yq, b_lower, b_upper, ball)
% WITHIN    check if additional nodes need to be searched (i.e. if the ball
%  centered at yq and containing all current nearest neighbors overlaps the
%  boundary of the leaf box containing yq)
%
% INPUT:
%   yq: query point
%   b_lower, b_upper: lower and upper bounds on the leaf box
%   ball: square of the radius of the ball centered at yq and containing
%         all current r nearest neighbors
% OUTPUT:
%   flag: 1 if ball does not intersect the box, 0 if it does
%
% Modified by David Chelidze on 02/03/2009.
 
if ball <= min([abs(yq-b_lower)', abs(yq-b_upper)'])^2
    % ball containing all the current nn is inside the leaf box (finish)
    flag = 1;
else % ball overlaps other leaf boxes (continue recursive search)
    flag = 0; 
end
 
%--------------------------------------------------------------------------            
function flag = overlap(yq, b_lower, b_upper, ball)
% OVERLAP   check if the current box overlaps with the ball centered at yq
%   and containing all current r nearest neighbors’.
%
% INPUT:
%   yq: query point
%   b_lower, b_upper: lower and upper bounds on the current box
%   ball: square of the radius of the ball centered at yq and containing
%         all current r nearest neighbors
% OUTPUT:
%   flag: 0 if ball does not overlap the box, 1 if it does
%
% Modified by David Chelidze on 02/03/2009.
 
il = find(yq < b_lower); % index of yq coordinates that are lower the box 
iu = find(yq > b_upper); % index of yq coordinates that are upper the box
% distance squared from yq to the edge of the box
dst = sum((yq(il)-b_lower(il)).^2,1)+sum((yq(iu)-b_upper(iu)).^2,1);
if dst >= ball % there is no overlap (finish this search)    
    flag = 0;
else % there is overlap and the box needs to be searched for nn
    flag = 1;
end