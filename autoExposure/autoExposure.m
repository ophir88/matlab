
close all;
clear;
% ==== Load image ====.
img = imread('photos/plant.jpg');

img = imresize(img, 0.1);

% ==== Get Luminance channel====.
imgYCB = rgb2ycbcr(img);
imgY = imgYCB(:,:,1);
normImgY = im2double(imgY);
normImgY = normImgY - min(normImgY(:)) ;
normImgY = normImgY / max(normImgY(:)) ;
imgY = im2uint8(normImgY);
imgY2 = int32(imgY);
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
    visibilityAll = sum(sum(allEdges((segmentedImg==i))));
    if (visibilityAll > 0 )
        visibilityShadow(1,i) = sum(sum(shadowEdges(segmentedImg==i))) / visibilityAll;
        visibilityHighlight(1,i) = sum(sum(HighlightEdges(segmentedImg==i))) / visibilityAll;
    else
        visibilityShadow(1,i) = 0;
        visibilityHighlight(1,i) = 0;
    end
end

% Measure of relative contrast:
relativeContrast = zeros(10,10);
for i = 1 : 10
    currentHistogram = histcounts(imgYD(segmentedImg==i), 50);
    for j = 1 : 10
        compareHistogram = histcounts(imgYD(segmentedImg==j), 50);
        maxContr = 0;
        maxIndex = 0;
        for distance = 0 : 50
           shiftedCompare = circshift(compareHistogram,[0,distance]);
           intersection = sum(currentHistogram .* shiftedCompare);
           if (intersection > maxContr)
               maxContr = intersection;
               maxIndex = distance;
           end
        end
        if (maxIndex > 25 )
                maxIndex = abs(50 - maxIndex);
        end
        relativeContrast(i,j) = maxIndex;
    end
end

[rows,cols,d] = size(segmentedImg);
imgSize = rows * cols;

% ==== MRF minimization ====:
nStates = ones(10,1) * 10; % Number of states that each node can take
maxState = max(nStates); % Maximum number of states that any node can take
nNodes = length(nStates); % Total number of nodes

adj = ones(nNodes) - eye(nNodes); % Symmetric {0,1} matrix containing edges

% Make structure that tracks edge information
edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nEdges = edgeStruct.nEdges;
% Make (non-negative) potential of each node taking each state
nodePot = zeros(nNodes,maxState);
for n = 1:nNodes
    regionSize = sum(sum(find(segmentedImg == n))) / imgSize;
    visibility = visibilityShadow(1,n);
    for s = 1:nStates(n)
        zoneCost = 0;
        if (n < 5 )
            zoneCost = 1/(1+ exp(-(s-n)));
            nodePot(n,s) =  -log(regionSize * visibility * zoneCost);
        elseif(n > 5)
            zoneCost = 1/(1+ exp(-(n-s)));
            nodePot(n,s) =  -log(regionSize * visibility * zoneCost);
        else
        nodePot(n,s) =  1;
        end
    end
end

% Make (non-negative) potential of each edge taking each state combination
edgePot = zeros(maxState,maxState,edgeStruct.nEdges);
for e = 1:nEdges
    n1 = edgeStruct.edgeEnds(e,1);
    n2 = edgeStruct.edgeEnds(e,2);
    for s1 = 1:nStates(n1)
        for s2 = 1:nStates(n2)
            currentContrast = relativeContrast(n1,n2);
            %           adjust exposure:
            imgYDs1 = imgYD * 2^(s1/10);
            imgYDs2 = imgYD * 2^(s2/10);
            %           get new histograms and find the new contrast:
            currentHistogram = histcounts(imgYDs1(segmentedImg==n1), 50);
            compareHistogram = histcounts(imgYDs2(segmentedImg==n2), 50);
            maxContr = 0;
            maxIndex = 0;
            for distance = 0 : 50
                shiftedCompare = circshift(compareHistogram,[0,distance]);
                intersection = sum(currentHistogram .* shiftedCompare);
                if (intersection > maxContr)
                    maxContr = intersection;
                    maxIndex = distance;
                end
            end
            if (maxIndex > 25 )
                newContrast = abs(50 - maxIndex);
            else
                newContrast = maxIndex;
            end
            regionSize = sum(sum(find(segmentedImg == n2))) / imgSize;
            gaussVal = gauss(newContrast - currentContrast,0,0.15);
            if (regionSize * gaussVal == 0)
                's';
            end
            edgePot(s1,s2,e) = -log(regionSize * gaussVal);
        end
    end
end

adjustments = [0 1 ; 1 3 ; 1 3 ; 1 3 ; 0 0 ; 1 3 ; 1 3 ; 1 3 ; 1 3 ; 0 1];
signs = [1 ; 1 ; 1 ; 1 ; 1 ; -1 ; -1 ; -1 ; -1 ; -1];

finalResults = zeros(10,1);
minEnergy = 1000;
for a = adjustments(1,1) : adjustments(1,2)
    for b = adjustments(2,1) : adjustments(2,2)
        for c = adjustments(3,1) : adjustments(3,2)
            for d = adjustments(4,1) : adjustments(4,2)
                for f = adjustments(6,1) : adjustments(6,2)
                    for g = adjustments(7,1) : adjustments(7,2)
                        for h = adjustments(8,1) : adjustments(8,2)
                            for i = adjustments(9,1) : adjustments(9,2)
                                for j = adjustments(10,1) : adjustments(10,2)
                                    sumContrast = 0;
                                    sumNode = 0;
                                    currentAddition = [a ;b ;c ; d; 0 ; f ; g; h ; i ; j];
                                    for e = 1 : nEdges
                                        n1 = edgeStruct.edgeEnds(e,1);
                                        n2 = edgeStruct.edgeEnds(e,2);
                                        sumContrast = sumContrast + edgePot(n1+currentAddition(n1)*signs(n1),n2 +currentAddition(n2)*signs(n2), e);
                                    end
                                    for n = 1 : 10
                                        sumNode = sumNode +  nodePot(n,n + currentAddition(n)*signs(n));
                                    end
                                    currentEnergy = sumContrast + sumNode;
                                    
                                    if (currentEnergy < minEnergy)
                                        minEnergy = currentEnergy;
                                        finalResults = currentAddition.*signs;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

's';