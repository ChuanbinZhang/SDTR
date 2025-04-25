function [prediction, SP] = segmentation(image_file, n_clusters, alpha, beta, ns, scales, use_cache, max_iter, error, verbose, cache_dir)
default_parameters = [
    "image_file",   "";
    "n_clusters",	0;
    "alpha",        200;
    "beta",         0.01;
    "ns",           250;
    "scales",       6;
    "use_cache",    1;
    "max_iter",     30;
    "error",        0.05;
    "verbose",      0;
    "cache_dir"     "'./cache'";
];


for i=3:size(default_parameters, 1)
    if nargin < i
        s = strcat(default_parameters(i, 1), "=", default_parameters(i, 2), ";");
        eval(s);
    end
end

[Mu, P, S, S1, h, w, SP] = multiscale_superpixels(image_file, ns, scales, use_cache, cache_dir);

n_points = size(S1, 2);
[Y] = SDTR_core(Mu, P, S, n_points, n_clusters, alpha, beta, max_iter, error, verbose);

Y = S1 * Y;
prediction = reshape(Y, [h, w]);
end

