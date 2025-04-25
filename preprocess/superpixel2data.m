function [Mu, P, S]=superpixel2data(feature,label_matrix)
[M, N, D] = size(feature);

unique_labels = unique(label_matrix);
n_labels = length(unique_labels);
Mu=zeros(n_labels, D);
n_pixels = M*N;
S = zeros([n_pixels, n_labels]);
P = zeros(n_labels, 1);

for i=1:n_labels
    label = unique_labels(i);
    label_vector = reshape(label_matrix, 1,n_pixels);
    index=label_matrix==label;
    index_vector = label_vector==label;
    S(index_vector, i)=1;
    P(i) = sum(index_vector);
    
    
    X = [];
    for d=1:D
        feature_d=feature(:,:,d);
        pixels=feature_d(index);
        X = cat(2, X, pixels);
    end
    Mu(i, :)=mean(X, 1);
end
Mu = NormalizeFea(Mu);
S = sparse(S);
end