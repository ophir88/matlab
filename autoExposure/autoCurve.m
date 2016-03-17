function [ output ] = autoCurve( img )
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
x = fminsearch(@(x) sCurveLUT(x,T),[0,0]);
Icurve = 0:1/255:1;
resultCurve = real(sCruveImg(Icurve,x(1), x(2)));
% resultCurve = real(sCruveImg(Icurve,shadow, highlight));
% figure; plot(resultCurve);
imgOriginD = im2double(imgOrigin);
imgOriginYCB = rgb2ntsc(imgOriginD);
[oRow, oCols,d] = size(imgOriginD);
radius = round(min(oRow,oCols) * 4 / 100);
filteredImg = imguidedfilter(imgOriginD,'NeighborhoodSize',[radius radius]);

detailImage = imgOriginD - filteredImg;

imgOriginYCB(:,:,1) = sCruveImg(imgOriginYCB(:,:,1) , x(1), x(2));
imgOriginYCB(:,:,2) = sCruveImg(imgOriginYCB(:,:,2) , x(1)/8, x(2)/8);
imgOriginYCB(:,:,3) = sCruveImg(imgOriginYCB(:,:,3) , x(1)/8, x(2)/8);

finalResult1 = ntsc2rgb(imgOriginYCB);
output = finalResult1 + (2*finalResult1.*(1 - finalResult1)).*detailImage;

end

