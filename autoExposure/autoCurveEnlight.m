function [ output, T, LUT] = autoCurveEnlight( img, method )
%AUTOCURVE Summary of this function goes here
%   Detailed explanation goes here

[R,C,d] = size(img);
maxSize = max(R,C);
aspect = maxSize / 400;
imgOrigin = imresize(img, 3/ aspect);
img = imresize(img, 1/ aspect);

% ==== Get Luminance channel====.
imgYCB = rgb2ycbcr(img);
imgY = imgYCB(:,:,1);
[J, T] = histeq(matlab histogram
);
[curveSet, weights ] = curveSolver(T, 0);

LUT = applyCurves(curveSet, weights);
% [curveSet2, weights2 ] = curveSolver(T, 1);
% 
% LUTNormalized = applyCurves(curveSet2, weights2);

% LUT = LUT./max(LUT);

imgOriginD = im2double(imgOrigin);
imgOriginYCB = rgb2ntsc(imgOriginD);
imgOriginYCB(:,:,1) = imgOriginYCB(:,:,1) - min(min(imgOriginYCB(:,:,1)));
imgOriginYCB(:,:,1) = imgOriginYCB(:,:,1) ./ (max(max(imgOriginYCB(:,:,1))));
[oRow, oCols,d] = size(imgOriginD);
radius = round(min(oRow,oCols) * 4 / 100);
filteredImg = imguidedfilter(imgOriginD,'NeighborhoodSize',[radius radius]);

detailImage = imgOriginD - filteredImg;

imgOriginYCB(:,:,1) = applyLUT(imgOriginYCB(:,:,1),LUT);

finalResult1 = ntsc2rgb(imgOriginYCB);
output = finalResult1 + (2*finalResult1.*(1 - finalResult1)).*detailImage;

imgOriginYCBN = rgb2ntsc(imgOriginD);
imgOriginYCBN(:,:,1) = imgOriginYCBN(:,:,1) - min(min(imgOriginYCBN(:,:,1)));
imgOriginYCBN(:,:,1) = imgOriginYCBN(:,:,1) ./ (max(max(imgOriginYCBN(:,:,1))));

detailImage = imgOriginD - filteredImg;

% imgOriginYCBN(:,:,1) = applyLUT(imgOriginYCBN(:,:,1),LUTNormalized);
% 
% finalResult2 = ntsc2rgb(imgOriginYCBN);
% outputNormlized = finalResult2 + (2*finalResult2.*(1 - finalResult2)).*detailImage;
end

