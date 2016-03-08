function [ depth ] = depthForTripleFocus( img1,img2 , img3)
%DEPTHFORCOUPLEFOCUS Summary of this function goes here
%   Detailed explanation goes here


[r,c,d] = size(img1);
kernelSize = max(r,c)/20;
kernelSize = round(kernelSize);
H = fspecial('average',kernelSize);
Hdepth = fspecial('average',round(kernelSize/5));

% imgGray1 = rgb2gray(img1);
% imgGray2 = rgb2gray(img2);
% imgGray3 = rgb2gray(img3);
imgGray1 = imgradient( rgb2gray(img1));
imgGray2 = imgradient(rgb2gray(img2));
imgGray3 = imgradient(rgb2gray(img3));

imgGrayG1 = imfilter(imgGray1,H,'replicate');
imgGrayG2 = imfilter(imgGray2,H,'replicate');
imgGrayG3 = imfilter(imgGray3,H,'replicate');

% figure;
%     ax1=subplot(1,3,1);
%     imshow(imgGray1);
%     ax2=subplot(1,3,2);
%     imshow(imgGray2);
%     ax3=subplot(1,3,3);
%     imshow(imgGray3);
% 
% linkaxes([ax1 ax2 ax3],'xy')
imgs ={};
imgs{1} = imgGrayG1;
imgs{2} = imgGrayG2;
imgs{3} = imgGrayG3;

epsilon = 0.00001;
depth = 2*imgs{1}./(imgs{1} + imgs{2} + epsilon);
% figure; imshow(depth);
depth = normalize(depth);
% figure; imshow(depth);
meanVal = mean(mean(depth));
depth = remapInterpolation(depth, (meanVal*10-5), 1);
depthW = wlsFilter(depth, 1, 1.2, imgGray1);
depthW = remapInterpolation(depthW, 2, 1.2);

figure; imshow(depthW);

% depth = imfilter(depth,Hdepth,'replicate');

% depth = depth.^2;

% depth = zeros(r,c);
% idx1 = imgGray1 > imgGray2 & imgGray1 > imgGray3;
% idx2 = imgGray2 > imgGray1 & imgGray2 > imgGray3;
% idx3 = imgGray3 > imgGray1 & imgGray3 > imgGray2;
% depth(idx1) = 1;
% depth(idx2) = 0.5;
% depth(idx3) = 0;

depth = repmat(depthW, [1,1,3]);


end

