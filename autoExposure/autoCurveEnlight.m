function [ output ] = autoCurveEnlight( img )
%AUTOCURVE Summary of this function goes here
%   Detailed explanation goes here

[R,C,d] = size(img);
maxSize = max(R,C);
aspect = maxSize / 400;
% tStart = tic;  % TIC, pair 2  
imgOrigin = imresize(img, 3/ aspect);
img = imresize(img, 1/ aspect);

% ==== Get Luminance channel====.
imgYCB = rgb2ycbcr(img);
imgY = imgYCB(:,:,1);
[J, T] = histeq(imgY);
x = fminsearch(@(x) enlightCurveError(x,T),[0,0,0]);

x(x>1)=1;
x(x<0)=0;

Icurve = 0:1/255:1;
LUT = enlightCurve(x, Icurve);
% resultCurve = real(sCruveImg(Icurve,shadow, highlight));
% figure; plot(resultCurve);
imgOriginD = im2double(imgOrigin);
imgOriginYCB = rgb2ntsc(imgOriginD);
[oRow, oCols,d] = size(imgOriginD);
radius = round(min(oRow,oCols) * 4 / 100);
filteredImg = imguidedfilter(imgOriginD,'NeighborhoodSize',[radius radius]);

detailImage = imgOriginD - filteredImg;
% figure; imshow(imgOriginYCB(:,:,1));
% figure; imshow(applyLUT(imgOriginYCB(:,:,1),LUT));
imgOriginYCB(:,:,1) = applyLUT(imgOriginYCB(:,:,1),LUT);

% 
% imgOriginYCB(:,:,2) = applyLUT(imgOriginYCB(:,:,2),LUT);
% imgOriginYCB(:,:,3) = applyLUT(imgOriginYCB(:,:,3),LUT);

finalResult1 = ntsc2rgb(imgOriginYCB);
output = finalResult1 + (2*finalResult1.*(1 - finalResult1)).*detailImage;

end

