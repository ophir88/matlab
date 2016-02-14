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

% [pixelCounts, grayLevels] = imhist(imgY);
% cdf = cumsum(pixelCounts); % Make transfer function (look up table).
% cdf = cdf / sum(cdf); % Normalize
% plot(grayLevels, cdf, 'b-');
% T = round(T * 255);

% figure; plot(T);
% figure; imshow(imgY);
% figure; imshow(J);
Icurve = 0:1/255:1;
shadow = 0;
highlight = 0;
minError = 100;
for i = -5 : 0.1 : 5
    for j = -5 : 0.1 : 5
        resultCurve = real(sCruveImg(Icurve,i, j));
        error = norm(resultCurve-T,2)/norm(resultCurve);
        if (error < minError)
            minError = error;
            shadow = i;
            highlight = j;
        end
    end
end

% resultCurve = real(sCruveImg(Icurve,shadow, highlight));
% figure; plot(resultCurve);
imgOriginD = im2double(imgOrigin);
imgOriginYCB = rgb2ntsc(imgOriginD);
[oRow, oCols,d] = size(imgOriginD);
radius = round(min(oRow,oCols) * 4 / 100);
filteredImg = imguidedfilter(imgOriginD,'NeighborhoodSize',[radius radius]);

detailImage = imgOriginD - filteredImg;
% imgOriginYCB(:,:,1) = histeq(imgOriginYCB(:,:,1));
imgOriginYCB(:,:,1) = sCruveImg(imgOriginYCB(:,:,1) , shadow, highlight);
imgOriginYCB(:,:,2) = sCruveImg(imgOriginYCB(:,:,2) , shadow/8, highlight/8);
imgOriginYCB(:,:,3) = sCruveImg(imgOriginYCB(:,:,3) , shadow/8, highlight/8);

finalResult1 = ntsc2rgb(imgOriginYCB);
output = finalResult1 + (2*finalResult1.*(1 - finalResult1)).*detailImage;
% figure; imshow(output);
's';


end

