function [ depth ] = depthForTripleFocus( img1,img2 , img3)
%DEPTHFORCOUPLEFOCUS Summary of this function goes here
%   Detailed explanation goes here


[r,c,d] = size(img1);
kernelSize = max(r,c)/250;
kernelSize = round(kernelSize);
H = fspecial('disk',kernelSize);

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
depth = 3*imgs{1}./(imgs{1} + imgs{2} + imgs{3}  + epsilon);
% figure; imshow(depth);
depth = normalize(depth);
meanVal = mean(mean(depth));
% depth = remapInterpolation(depth, (meanVal*10-5), 1);
figure; imshow(depth);

depthW = wlsFilter(depth, 1, 1.2, imgGray1);
depthW = remapInterpolation(depthW, 1.5, 2);

figure; imshow(depthW);
depth = repmat(depthW, [1,1,3]);


end

