function [prediction] = clustering(data_path, n_clusters, alpha, beta, ns, scales, use_cache, max_iter, error, verbose, cache_dir)
default_parameters = [
    "data_path",    "";
    "n_clusters",	0;
    "alpha",        50;
    "beta",         0.1;
    "ns",           2;
    "scales",       2;
    "use_cache",    1;
    "max_iter",     30;
    "error",        0.05;
    "verbose",      0;
    "cache_dir"     "'./cache'";
];

for i=2:size(default_parameters, 1)
    if nargin < i
        s = strcat(default_parameters(i, 1), "=", default_parameters(i, 2), ";");
        eval(s);
    end
end

[Mu, P, S, n_points] = multiscale_data(data_path, ns, scales, use_cache, cache_dir);

if verbose
    for i=1:size(default_parameters, 1)
        eval(default_parameters(i,1));
    end
end

[prediction] = SDTR_core(Mu, P, S, n_points, n_clusters, alpha, beta, max_iter, error, verbose);
end