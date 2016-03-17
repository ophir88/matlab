function [ finalResult ] = autoExpose2( img )
% Automatically fixes low / high exposed areas in photos.
% The algorithm calculates an optimal exposure curve for the image, and
% applies it in a global way so. The idea is to increment low exposed areas
% while decreasing highly exposed areas. An area's exposure will only
% change if by doing so, more details will be visible.
% img - input img.
% finalResult - fixed img.

fprintf('started quick calculation \n')

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
% imgY = im2uint8(normImgY);
imgLight = zeros(size(imgY));
imgShadow = zeros(size(imgY));

imgLight(imgY>0.5) = imgY(imgY>0.5);
imgShadow(imgY<=0.5) = imgY(imgY<=0.5);
% figure; imshow(imgLight);
% figure; imshow(imgShadow);

%  ==== Optimal zone estimation ====.
% Detection of visible details:
highG = 2.2;
lowG = 1 / highG;
imgHighG = imgLight.^highG;
imgLowG = imgShadow.^lowG;

imgHighGEdge = edge(imgHighG,'canny');
imgLowGEdge = edge(imgLowG,'canny');
imgOriginalEdge = edge(imgY,'canny');
shadowEdges = imgLowGEdge - imgLowGEdge.*imgHighGEdge;
HighlightEdges = imgHighGEdge - imgLowGEdge.*imgHighGEdge;
allEdges = imgHighGEdge + imgLowGEdge + imgOriginalEdge;
visibilityAll = sum(sum(allEdges));
shadow = sum(sum(shadowEdges)) * 1.7 / visibilityAll;
highlight = -sum(sum(HighlightEdges)) / visibilityAll;
tElapsed = toc(tStart);  
fprintf('total time for img : %.2f seconds. \n',tElapsed')
imgOriginD = im2double(imgOrigin);
imgOriginYCB = rgb2ntsc(imgOriginD);
[oRow, oCols,d] = size(imgOriginD);
radius = round(min(oRow,oCols) * 4 / 100);
filteredImg = imguidedfilter(imgOriginD,'NeighborhoodSize',[radius radius]);

detailImage = imgOriginD - filteredImg;

Icurve = 0:1/255:1;
resultCurve = real(sCruveImg(Icurve,shadow, highlight));
        
imgOriginYCB(:,:,1) = sCruveImg(imgOriginYCB(:,:,1) , shadow, highlight);
imgOriginYCB(:,:,2) = sCruveImg(imgOriginYCB(:,:,2) , shadow/8, highlight/8);
imgOriginYCB(:,:,3) = sCruveImg(imgOriginYCB(:,:,3) , shadow/8, highlight/8);

finalResult1 = ntsc2rgb(imgOriginYCB);
finalResult = finalResult1 + (2*finalResult1.*(1 - finalResult1)).*detailImage;
% figure; imshow(finalResult);

end

