function [Mu, P, S, S1, h, w, SP] = multiscale_superpixels(src, ns, scales, use_cache, cache_dir)
default_parameters = [
    "src",          "";
    "ns",           200;
    "scales",       6;
    "use_cache",    0;
    "cache_dir"     "'./cache'";
];

for i=2:size(default_parameters, 1)
    if nargin < i
        s = strcat(default_parameters(i, 1), "=", default_parameters(i, 2), ";");
        eval(s);
    end
end

if ~exist(cache_dir, 'dir')
    mkdir(cache_dir)
end

[~, name, ~] = fileparts(src);
cache_file = fullfile(cache_dir, sprintf("%s_%d_%d.mat", name, ns, scales));
if use_cache && exist(cache_file, "file")
    load(cache_file, "Mu", "P", "S", "S1", "h", "w", "SP");
    return
end

f_ori=imread(src);
[h, w, ~] = size(f_ori);
rgb=imgaussfilt3(f_ori,0.5);
rgb = im2double(rgb);
% lab = rgb2lab(rgb);
% hsv = rgb2hsv(rgb);
features = {
    rgb;
%     lab;
%     hsv;
};
n_features = length(features);

n_pixels = h * w;

for i =1:scales
    ni = floor(n_pixels / ns / 2.^(i-1));
    if ni <= 2
        break;
    end
    SP{i} = superpixels(lab, ni, 'Compactness', 1, 'IsInputLab', true);
    
    for j=1:n_features
        [Mu{j, i}, Pi, Si]=superpixel2data(features{j}, SP{i});
        P{j, i} = Pi;
        
        if i == 1
            S1 = Si;
            S{j, 1} = eye(size(S1, 2));
        else
            Si = S1' * Si;
            Si = Si ./ sum(Si, 2);
            S{j, i} = Si;
        end
    end
end

Mu = reshape(Mu, 1, size(Mu, 1) * size(Mu, 2));
S = reshape(S, 1, size(S, 1) * size(S, 2));
P = reshape(P, 1, size(P, 1) * size(P, 2));
save(cache_file, "Mu", "P", "S", "S1", "h", "w", "SP");
end