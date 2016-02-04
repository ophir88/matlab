function [ finalResult ] = autoExpos( img )
%AUTOEXPOS Summary of this function goes here
%   Detailed explanation goes here

fprintf('started autoExpo calculation')


% ==== Load image ====.
[R,C,d] = size(img);
maxSize = max(R,C);
aspect = maxSize / 400;
tStart = tic;  % TIC, pair 2  
imgOrigin = img;
img = imresize(img, 1/ aspect);

% ==== Get Luminance channel====.
imgYCB = rgb2ycbcr(img);
imgY = imgYCB(:,:,1);
normImgY = im2double(imgY);
normImgY = normImgY - min(normImgY(:)) ;
normImgY = normImgY / max(normImgY(:)) ;
imgY = im2uint8(normImgY);
% figure; imshow(imgY);

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
for i = 0: maxLabel
    indexs = (labels == i);
    numOfInd = sum(sum(indexs));
    if(numOfInd > 0 )
        value = ceil(mean(mean(imgY(indexs))));
        segmentedImg(indexs) = lut(1,value);
    end
end

% transform the image back to doubles.
% segmentedImgd =  double(segmentedImg) + 1;
% segmentedImgd = segmentedImgd/10;
% figure;
% imshow(segmentedImgd);
[rows,cols,d] = size(segmentedImg);
imgSize = rows * cols;

relativeRegionSize = zeros(11,0);
for i = 1 : 11
    relativeRegionSize(i,1) = sum(sum(segmentedImg == i-1)) / imgSize; 
end
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
visibilityShadow = zeros(1,11);
visibilityHighlight = zeros(1,11);
for i = 1 : 11
    visibilityAll = sum(sum(allEdges((segmentedImg==i-1))));
    if (visibilityAll > 0 )
        visibilityShadow(1,i) = sum(sum(shadowEdges(segmentedImg==i-1))) / visibilityAll;
        visibilityHighlight(1,i) = sum(sum(HighlightEdges(segmentedImg==i-1))) / visibilityAll;
    else
        visibilityShadow(1,i) = 0;
        visibilityHighlight(1,i) = 0;
    end
end

epsilon = .00001;

% % %  Without Edge pot:


load adjustmentPermutaions;  

finalResults = zeros(10,1);
minEnergy = 1000;
for permutation = 1 : length(adjustmentPermutaions)
    sumNode = 0;
    currentAddition = adjustmentPermutaions(permutation,:);
    for n = 1 : 11
        
        %         node potential:
        regionSize = relativeRegionSize(n,1);
        zoneCost = 0;
        currentNodePot = 0;
        if(regionSize * visibilityShadow(1,n) == 0)
            currentNodePot = -log(epsilon);
        else
            if (n < 6 )
                zoneCost = 1/(1+ exp(-(currentAddition(n))));
                currentNodePot =  -log(regionSize * visibilityShadow(1,n) * zoneCost);
            elseif(n > 6)
                zoneCost = 1/(1+ exp(-(-currentAddition(n))));
                currentNodePot =  -log(regionSize * visibilityHighlight(1,n) * zoneCost);
            else
                currentNodePot =  1;
            end
        end        
        sumNode = sumNode +  currentNodePot;
    end
    currentEnergy = sumNode;
    
    if (currentEnergy < minEnergy)
        minEnergy = currentEnergy;
        finalResults = currentAddition;
    end
end

[shadow, highlight] = shadowAndHighlight(imgYD,segmentedImg,11,  finalResults);

tElapsed = toc(tStart);  
fprintf('calculated the curve in : %.2f seconds. \n',tElapsed')
% curve = 0:1/255:1;
% curve = double(curve);
% curve = sCruveImg(curve , shadow, highlight);

% figure;plot(curve);
% ==== Get Luminance channel====.
imgOriginD = im2double(imgOrigin);
imgOriginYCB = rgb2ntsc(imgOriginD);
[oRow, oCols,d] = size(imgOriginD);
radius = round(min(oRow,oCols) * 4 / 100);
filteredImg = imguidedfilter(imgOriginD,'NeighborhoodSize',[radius radius]);

detailImage = imgOriginD - filteredImg;


imgOriginYCB(:,:,1) = sCruveImg(imgOriginYCB(:,:,1) , shadow, highlight);
imgOriginYCB(:,:,2) = sCruveImg(imgOriginYCB(:,:,2) , shadow/8, highlight/8);
imgOriginYCB(:,:,3) = sCruveImg(imgOriginYCB(:,:,3) , shadow/8, highlight/8);

finalResult = ntsc2rgb(imgOriginYCB);
finalResult = finalResult + (finalResult.*(1 - finalResult)).*detailImage;
% figure;
% subplot(2,2,1);
% imshow(imgOriginD);
% subplot(2,2,2);
% imshow(finalResult);
% naiveExpo = imgOriginD * 2^(5/10);
% subplot(2,2,3);
% imshow(naiveExpo);
tElapsed = toc(tStart);  
fprintf('total time for img : %.2f seconds. \n',tElapsed')



's';
end

