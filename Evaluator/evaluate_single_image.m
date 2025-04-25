function [PRI, SC, VOI, GCE, BDE] = evaluate_single_image(prediction, groundTruth)
out_vals  = eval_segmentation(prediction, groundTruth);
PRI = out_vals.PRI;
VOI = out_vals.VoI;
GCE = out_vals.GCE;
BDE = out_vals.BDE;

SC = segmentation_covering(prediction, groundTruth);
end