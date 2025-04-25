function W = constructW_PKN(X, k, issymmetric)
% construct similarity matrix with probabilistic k-nearest neighbors. It is a parameter free, distance consistent similarity.
% X: each column is a data point
% k: number of neighbors
% issymmetric: set W = (W+W')/2 if issymmetric=1
% W: similarity matrix

if nargin < 3
    issymmetric = 1;
end

[~, n] = size(X);

if nargin < 2
    k = n-2;
end


D = pdist2(X', X', 'squaredeuclidean');


[~, idx] = sort(D, 2); % sort each row

W = zeros(n);
for i = 1:n
    id = idx(i,2:k+2);
    di = D(i, id);
    if di(k+1) == 0
        W(i,id) = 1 / (k + 1); 
    else
    	W(i,id) = (di(k+1)-di)/(k*di(k+1)-sum(di(1:k))+eps);
    end
end

if issymmetric == 1
    W = (W+W')/2;
end