close all;

% ==== Load image ====.
img = imread('photos/plant.jpg');
img = imresize(img, 0.5);

% ==== Get Luminance channel====.
imgYCB = rgb2ycbcr(img);
imgY = imgYCB(:,:,1);
segmentedImg = zeros(size(imgY),'uint8');

%  ==== Segmentation ====.
% Luminance LUT, [1,255] -> [1,10].
lut = luminanceLUT; 
regionSize = 30;
regularizer = 10;
% Get segmentation labels for each pixel.
labels = vl_slic(single(img), regionSize, regularizer);
maxLabel = max(max(labels));
% For each lable group, we find the mean luminance, and set the whole
% segment to it's matching LUT value.
for i = 1: maxLabel
    indexs = (labels == i);
    numOfInd = sum(sum(indexs));
    if(numOfInd > 0 )
        value = ceil(mean(mean(imgY(indexs))));
        segmentedImg(indexs) = lut(1,value);
    end
    
end
% transform the image back to doubles.
segmentedImg =  double(segmentedImg) + 1;
segmentedImg = segmentedImg/10;
figure;
imshow(segmentedImg);

%  ==== Optimal zone estimation ====.

's';


