
close all;
clear;
% ==== Load image ====.
img = imread('photos/img1.jpg');
imgOrigin = imresize(img, 1);
img = imresize(img, 0.4);

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
segmentedImgd =  double(segmentedImg) + 1;
segmentedImgd = segmentedImgd/10;
figure;
imshow(segmentedImgd);

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

% Measure of relative contrast:
relativeContrast = zeros(11,11);
for i = 1 : 11
    currentHistogram = histcounts(imgYD(segmentedImg==i-1), 50);
    for j = 1 : 11
        compareHistogram = histcounts(imgYD(segmentedImg==j-1), 50);
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
nStates = ones(11,1) * 11; % Number of states that each node can take
maxState = max(nStates); % Maximum number of states that any node can take
nNodes = length(nStates); % Total number of nodes

adj = ones(nNodes) - eye(nNodes); % Symmetric {0,1} matrix containing edges

% Make structure that tracks edge information
edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nEdges = edgeStruct.nEdges;
% Make (non-negative) potential of each node taking each state
nodePot = zeros(nNodes,maxState);
nodePotTotal = 0;
for n = 1:nNodes
    regionSize = sum(sum(segmentedImg == n-1)) / imgSize;
    for s = 1:nStates(n)
        zoneCost = 0;
        if (n < 6 )
            zoneCost = 1/(1+ exp(-(s-n)));
            nodePot(n,s) =  -log(regionSize * visibilityShadow(1,n) * zoneCost);
        elseif(n > 6)
            zoneCost = 1/(1+ exp(-(n-s)));
            nodePot(n,s) =  -log(regionSize * visibilityHighlight(1,n) * zoneCost);
        else
        nodePot(n,s) =  1;
        end
        nodePotTotal = nodePotTotal + nodePot(n,s);
    end
end

% Make (non-negative) potential of each edge taking each state combination
edgePot = zeros(maxState,maxState,edgeStruct.nEdges);
edgePotTotal = 0;
epsilon = .00001;
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
            currentHistogram = histcounts(imgYDs1(segmentedImg==n1-1), 50);
            compareHistogram = histcounts(imgYDs2(segmentedImg==n2-1), 50);
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
            regionSize = sum(sum(segmentedImg == n2-1)) / imgSize;
            gaussVal = gauss(newContrast - currentContrast,0,0.15);
            if (regionSize * gaussVal == 0)
             edgePot(s1,s2,e) = -log(epsilon);
            else
            edgePot(s1,s2,e) = -log(regionSize * gaussVal);
            end
            edgePotTotal = edgePotTotal + edgePot(s1,s2,e);
        end
    end
end
gamaWeight = nodePotTotal / edgePotTotal;
adjustments = [0 0 ; 0 1 ; 1 2 ; 1 3 ; 1 1 ;0 0 ; 0 1 ; 0 1 ;0 2 ; 0 1 ; 0 0];
signs = [1 ; 1 ; 1 ; 1 ; 1 ; 1; -1 ; -1 ; -1 ; -1 ; -1];

finalResults = zeros(10,1);
minEnergy = 1000;
for a = adjustments(1,1) : adjustments(1,2)
    for b = adjustments(2,1) : adjustments(2,2)
        for c = adjustments(3,1) : adjustments(3,2)
            for d = adjustments(4,1) : adjustments(4,2)
                for e = adjustments(5,1) : adjustments(5,2)
                    for f = adjustments(7,1) : adjustments(7,2)
                        for g = adjustments(8,1) : adjustments(8,2)
                            for h = adjustments(9,1) : adjustments(9,2)
                                for i = adjustments(10,1) : adjustments(10,2)
                                    for j = adjustments(11,1) : adjustments(11,2)
                                        sumContrast = 0;
                                        sumNode = 0;
                                        currentAddition = [a ;b ;c ; d; e ; 0; f ; g; h ; i ; j];
                                        for E = 1 : nEdges
                                            n1 = edgeStruct.edgeEnds(E,1);
                                            n2 = edgeStruct.edgeEnds(E,2);
%                                             fprintf('writing at: edgePot(%d,%d,%d)\n',n1+currentAddition(n1)*signs(n1) ,n2 +currentAddition(n2)*signs(n2) , E);
%                                             currentAddition
                                            sumContrast = sumContrast + edgePot(n1+currentAddition(n1)*signs(n1),n2+currentAddition(n2)*signs(n2), E);
                                        end
                                        for n = 1 : 11
                                            sumNode = sumNode +  nodePot(n,n + currentAddition(n)*signs(n));
                                        end
                                        currentEnergy = gamaWeight * sumContrast + sumNode;
                                        
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
end

% calculate the s-curve shadow ammount for each region:
%  (e - e') * c * fd
[shadow, highlight] = shadowAndHighlight(imgYD,segmentedImg,11,  finalResults);
curve = 0:1/255:1;
curve = double(curve);
curve = sCruveImg(curve , shadow, highlight);

figure;plot(curve);
% ==== Get Luminance channel====.
imgOriginD = im2double(imgOrigin);
imgOriginYCB = rgb2ntsc(imgOriginD);
[oRow, oCols,d] = size(imgOriginD);
radius = round(min(oRow,oCols) * 4 / 100);
filteredImg = imguidedfilter(imgOriginD,'NeighborhoodSize',[radius radius]);

detailImage = imgOriginD - filteredImg;


imgOriginYCB1 = imgOriginYCB;
imgOriginYCB(:,:,1) = sCruveImg(imgOriginYCB(:,:,1) , shadow, highlight);
imgOriginYCB(:,:,2) = sCruveImg(imgOriginYCB(:,:,2) , shadow/2, highlight/2);
imgOriginYCB(:,:,3) = sCruveImg(imgOriginYCB(:,:,3) , shadow/2, highlight/2);

finalResult = ntsc2rgb(imgOriginYCB);
finalResult = finalResult + (finalResult.*(1 - finalResult)).*filteredImg;
figure;
subplot(2,2,1);
imshow(imgOriginD);
subplot(2,2,2);
imshow(finalResult);
naiveExpo = imgOriginD * 2^(5/10);
subplot(2,2,3);
imshow(naiveExpo);


's';