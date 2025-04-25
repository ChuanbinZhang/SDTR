clc;
clear all;
close all;
addpath("./preprocess")
addpath("./solver")
addpath("./Evaluator")


use_cache = 1; % Use cache data
data_dir = "./data";

%% Image segmentation
img_name = "10_11_s.bmp";
label_dir = "./data";
label_name = "10_11_s.mat";

image_file = fullfile(data_dir, img_name);
f_ori=imread(image_file);

[clusters,groundTruths] = getNClusters(fullfile(label_dir, label_name));
num_clusters = numel(clusters);

for c = 1:num_clusters
    n_clusters = clusters{c};
    [prediction, SP] = segmentation(image_file, n_clusters, 650, 0.05, 250, 6, use_cache);

    if c == 1
        figure(1);
        n_sp = length(SP);
        n_row = ceil(n_sp / 2);
        for i=1:n_sp
            subplot(n_row, 2, i)
            BW = boundarymask(SP{i}, 4);
            sp_image = imoverlay(f_ori,BW,'yellow');
%             imwrite(sp_image, sprintf("%d.bmp", i), 'bmp');
            imshow(sp_image,'InitialMagnification',67);
            title(sprintf('%d superpixels', length(unique(SP{i}))));
        end
    end
    [PRI, SC, VOI, GCE, BDE] = evaluate_single_image(prediction, groundTruths);
    fprintf("%s: Clusters[%d]\tPRI[%.3f]\tSC[%.3f]\tVOI[%.3f]\tGCE[%.3f]\tBDE[%.3f]\n", img_name, n_clusters, PRI, SC, VOI, GCE, BDE);
    
    figure(2);
    subplot(num_clusters, 3, 3 * c - 2)
    imshow(f_ori)
    title('Image')
    
    subplot(num_clusters, 3, 3 * c - 1)
%     imwrite(label2rgb(groundTruths{c}), "G.bmp");
    imshow(label2rgb(groundTruths{c}))
    title('GroundTruth')
    
    subplot(num_clusters,3, 3 * c)
%     imwrite(label2rgb(prediction), "P.bmp");
    imshow(label2rgb(prediction))
    title('Segmentation')
    drawnow;
end

    
%% Multi-view data clustering
dataset = 'Movies.mat';
data_path = fullfile(data_dir,dataset);
load(data_path, "y");
n_clusters = length(unique(y));
prediction = clustering(data_path, n_clusters, 20, 0.6, 2, 4, use_cache);
result = ClusteringMeasure(y, prediction);
fprintf("%s: Clusters[%d]\tPurity[%.2f]\tARI[%.2f]\tNMI[%.2f]\n", dataset, n_clusters, result(2)* 100, result(4)* 100, result(3)* 100);