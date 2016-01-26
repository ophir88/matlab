



close all;
clear;
% ==== Load image ====.
img = imread('photos/plant.jpg');
img = imresize(img, 0.1);

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
% segmentedImg =  double(segmentedImg) + 1;
% segmentedImg = segmentedImg/10;
% figure;
% imshow(segmentedImg);

%  ==== Optimal zone estimation ====.

% Detection of visible details:
highG = 2.2;
lowG = 1 / highG;
imgYD = double(imgY) / 255;
imgHighG = imgYD.^highG;
imgLowG = imgYD.^lowG;

imgHighGEdge = edge(imgHighG,'canny');
imgLowGEdge = edge(imgLowG,'canny');
imgOriginalEdge = edge(imgYD,'canny');
shadowEdges = imgLowGEdge - imgLowGEdge.*imgHighGEdge;
HighlightEdges = imgHighGEdge - imgLowGEdge.*imgHighGEdge;
allEdges = imgHighGEdge + imgLowGEdge + imgOriginalEdge;
visibilityShadow = sum(1,10);
visibilityHighlight = zeros(1,10);
for i = 1 : 10
    visibilityAll = sum(sum(allEdges((segmentedImg==i-1))));
    if (visibilityAll > 0 )
        visibilityShadow(1,i) = sum(sum(shadowEdges(segmentedImg==i-1))) / visibilityAll;
        visibilityHighlight(1,i) = sum(sum(HighlightEdges(segmentedImg==i-1))) / visibilityAll;
    else
        visibilityShadow(1,i) = 0;
        visibilityHighlight(1,i) = 0;
    end
end

% Measure of relative contrast:
relativeContrast = zeros(10,10);
for i = 1 : 10
    currentHistogram = histcounts(imgYD(segmentedImg==i-1), 50);
    for j = 1 : 10
        compareHistogram = histcounts(imgYD(segmentedImg==j-1), 50);
        max = 0;
        maxIndex = 0;
        for distance = 0 : 50
           shiftedCompare = circshift(compareHistogram,[0,distance]);
           intersection = sum(currentHistogram .* shiftedCompare);
           if (intersection > max)
               max = intersection;
               maxIndex = distance;
           end
        end
        relativeContrast(i,j) = maxIndex;
    end
end

[rows,cols,d] = size(segmentedImg);
imgSize = rows * cols;
% MRF minimization:
% create data terms:
dataTerms = zeros(1,10);
for i = 1: 10
    P = 0;
    if (i < 5 )
      regionSize = sum(sum(find(segmentedImg == i-1))) / imgSize;
      P = visibilityShadow(1,i); 
    else
        
    end
    
%     dataTerms(1,i) = 
end


's';



