function [ finalResult ] = autoExpos( img )
% Automatically fixes low / high exposed areas in photos.
% The algorithm calculates an optimal exposure curve for the image, and
% applies it in a global way so. The idea is to increment low exposed areas
% while decreasing highly exposed areas. An area's exposure will only
% change if by doing so, more details will be visible.
% img - input img.
% finalResult - fixed img.

fprintf('started autoExpo calculation \n')

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

%  ==== segmented result ====.

% transform the image back to doubles.
% segmentedImgd =  double(segmentedImg) + 1;
% segmentedImgd = segmentedImgd/10;
% figure;
% imshow(segmentedImgd);

%  ==== Calculate each zone's optimal exposure ====.


[rows,cols,d] = size(segmentedImg);
imgSize = rows * cols;

% Calculate relative region size of each region.
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

% Get all node potentials:
nStates = ones(11,1) * 11; % Number of states that each node can take
maxState = max(nStates); % Maximum number of states that any node can take
nNodes = length(nStates); % Total number of nodes
nodePot = zeros(nNodes,maxState);
for n = 1:nNodes
    regionSize = relativeRegionSize(n,1);
    for s = 1:nStates(n)
        zoneCost = 0;
        if(regionSize * visibilityShadow(1,n) == 0)
            nodePot(n,s) = 0;
        else
            if (n < 6 )
                zoneCost = 1/(1+ exp(-(s-n)));
                nodePot(n,s) =  -log(regionSize * visibilityShadow(1,n) * zoneCost);
            elseif(n > 6)
                zoneCost = 1/(1+ exp(-(n-s)));
                nodePot(n,s) =  -log(regionSize * visibilityHighlight(1,n) * zoneCost);
            else
                nodePot(n,s) =  1;
            end
        end
    end
end
finalResults = zeros(11,1);
[val, I] = min(nodePot(1,1:4));
finalResults(1,1) = I-1;
for n = 2 : 11    
    if(relativeRegionSize(n,1) > 0 && sum(nodePot(n,:)) > 0)
    if n < 6
        [val, I] = min(nodePot(n,1:6));
        finalResults(n,1) = I-n;
    else
         [val, I] = min(nodePot(n,7:11));
        finalResults(n,1) = - (n - I) + 6;
        
    end
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

finalResult1 = ntsc2rgb(imgOriginYCB);
finalResult1 = finalResult1 + (2*finalResult1.*(1 - finalResult1)).*detailImage;
finalResult = finalResult1;
tElapsed = toc(tStart);  
fprintf('total time for img : %.2f seconds. \n',tElapsed')

end

