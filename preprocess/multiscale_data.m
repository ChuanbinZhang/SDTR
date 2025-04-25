function [Mu, P, S, n_points] = multiscale_data(src, ns, scales, use_cache, cache_dir, method)
default_parameters = [
    "src",          "";
    "ns",           3;
    "scales",       2;
    "use_cache",    1;
    "cache_dir"     "'./cache'";
    "method"        "'CLR'"
    ];

for i=2:size(default_parameters, 1)
    if nargin < i
        s = strcat(default_parameters(i, 1), "=", default_parameters(i, 2), ";");
        eval(s);
    end
end

[~, name, ~] = fileparts(src);
cache_dir = fullfile(cache_dir, name);
if ~exist(cache_dir, 'dir')
    mkdir(cache_dir)
end
cache_file = fullfile(cache_dir, sprintf("%d_%d.mat", ns, scales));
if use_cache && exist(cache_file, "file")
    load(cache_file, "Mu", "P", "S", "n_points");
    return
end

dataset = load(src, "X", "y");
X = dataset.X;
y = dataset.y;

v = length(X);
n_points = length(y);
n_clusters = length(unique(y));

clusters = zeros(scales, 1);
for j=1:scales
    current_k = floor(n_points / ns / 2^(j - 1));
    
    if current_k < n_clusters
        break;
    end
    
    clusters(j) = current_k;
end
clusters = clusters(clusters > 0);

scales = length(clusters);

Mu = cell(v, scales+1);
S = cell(v, scales+1);
P = cell(v, scales);

for i=1:v
    Xi = NormalizeFea(X{i});
    Mu{i, 1} = Xi;
    S{i, 1} = speye(n_points);
    
    for j=1:scales
        Mu1 = Mu{i, j};
        current_points = size(Mu1, 1);
        current_k = clusters(j);
        if current_k > current_points
            current_k = max([floor(current_points / 2), n_clusters]);
        end
        
        if size(Mu1, 2) > 3000
            X1 = reduce_data(Mu1, 0.1);
        else
            X1 = Mu1;
        end
        
        if method == "CLR"
            A0 = constructW_PKN(X1', 2, 1);
            labels = CLR(A0, current_k, 10);
        else
            labels = kmeans(X1, current_k, 'Replicates', 10);
        end
        
        unique_labels = unique(labels);
        n_ul = length(unique_labels);
        mu=zeros(n_ul, size(Xi, 2));
        Snv = zeros(current_points, n_ul);
        
        for l=1:n_ul
            ll = unique_labels(l);
            index = labels==ll;
            Snv(index, l)=1;
            Mu1l=Mu1(index, :);
            mu(l,:)=mean(Mu1l, 1);
        end
        
        Mu{i, j+1} = NormalizeFea(mu);
        S{i, j+1} = sparse(S{i, j}*Snv);
        P{i, j} = sum(Snv, 1)';
    end
end
Mu = Mu(:,2:end);
Mu =reshape(Mu, 1, size(Mu, 1) * size(Mu, 2));
S = S(:,2:end);
S = reshape(S, 1, size(S, 1) * size(S, 2));
P = reshape(P, 1, size(P, 1) * size(P, 2));
save(cache_file, "Mu", "P", "S", "n_points", "-v7.3");
end

function [data] = reduce_data(data, rate)
[data, Sigma, ~] = mySVD(data);
Sigma = diag(Sigma);
Sigma = Sigma ./ sum(Sigma);
sum_Sigma = 0;
end_idx = length(Sigma);
while end_idx > 1
    sum_Sigma = sum_Sigma + Sigma(end_idx);
    if sum_Sigma > rate
        break;
    end
    end_idx = end_idx - 1;
end
data = data(:, 1:end_idx);
end