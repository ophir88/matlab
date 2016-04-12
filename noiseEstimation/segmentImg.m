function [ segmentedImg ] = segmentImg( img )
%SEGMENTIMG Summary of this function goes here
%   Detailed explanation goes here

% ==== Load image ====.
[R,C,d] = size(img);
maxSize = max(R,C);
aspect = maxSize / 400;
tStart = tic;  % TIC, pair 2  
imgOrigin = imresize(img, 3/ aspect);
img = imresize(img, 1/ aspect);

% ==== Get Luminance channel====.
imgYCB = rgb2ycbcr(img);
imgY = imgYCB(:,:,1);
normImgY = im2double(imgY);
normImgY = normImgY - min(normImgY(:)) ;
normImgY = normImgY / max(normImgY(:)) ;
imgY = im2uint8(normImgY);


%  ==== Segmentation ====.
% Luminance LUT, [1,255] -> [0,10].
lut = luminanceLUT; 
regionSize = 20;
regularizer = 10;
% Get segmentation labels for each pixel.
labels = vl_slic(single(img), regionSize, regularizer);
maxLabel = max(max(labels));
% For each lable group, we find the mean luminance, and set the whole
% segment to it's matching LUT value.
segmentedImg = zeros(size(imgY),'uint8');
for i = 0: maxLabel
    indexs = (labels == i);
    numOfInd = sum(sum(indexs));
    if(numOfInd > 0 )
        value = ceil(mean(mean(imgY(indexs))));
        if (value == 0)
            value = 1;
        end
        segmentedImg(indexs) = lut(1,value);
    end
end
end

