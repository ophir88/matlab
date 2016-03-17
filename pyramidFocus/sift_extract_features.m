function [featureData] = sift_extract_features(images)
% sift_estimate_transformation(images)
% registering images using SIFT and RANSAC and fusing them
% first image in array is used as reference

Nimages=size(images,4);
featureData=cell(Nimages,1);
%% Feature extraction
tic
for j=1:Nimages
    [featureData{j}.feature, featureData{j}.descriptor] = ...
        vl_sift(im2single(images(:,:,:,j)),...
        'PeakThresh',1e-2,'edgethresh', 10*5, ...
        'FirstOctave',1,'Magnif',1);
end
fprintf('%s: VL SIFT Feature Extraction: %g seconds\n',mfilename,toc())

end