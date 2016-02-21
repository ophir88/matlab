function [ depth ] = depthForCoupleFocus( img1,img2 , gray)
%DEPTHFORCOUPLEFOCUS Summary of this function goes here
%   Detailed explanation goes here


[r,c,d] = size(img1);
kernelSize = max(r,c)/100;
kernelSize = round(kernelSize.^(1.8));
H = fspecial('average',kernelSize);

imgGray1 = rgb2gray(img1);
imgGray2 = rgb2gray(img2);


imgGray1 = imfilter(imgGray1,H,'replicate');
imgGray2 = imfilter(imgGray2,H,'replicate');
depthGray = (imgGray2 - imgGray1);
sorted = sort(reshape(depthGray,[],1), 'descend');
minVal = mean(sorted(round(length(sorted)*95/100):length(sorted)));
depthGray = (depthGray - minVal);
sorted = sort(reshape(depthGray,[],1), 'descend');
maxVal = mean(sorted(1:round(length(sorted)*5/100)));
depthGray = 1 - depthGray/ maxVal;
meanVal = mean(mean(depthGray));
depthGrayO = depthGray;
% depthGray(depthGray>1) = 1;
depthGray1 = depthGray.^1.5;
depthGray = remapInterpolation(depthGray, (meanVal*10-5)*0.7, 0.7);



% depthGray(depthGray>1) = 1;
figure;
subplot(1,3,1);
imshow(depthGrayO);
subplot(1,3,2);
imshow(depthGray1);
subplot(1,3,3);
imshow(depthGray);



% imgGray3 = imfilter(imgGray1,H2,'replicate');
% imgGray4 = imfilter(imgGray2,H2,'replicate');
% depthGray2 = (imgGray4 - imgGray3);
% % depthGray2 = depthGray2/(max(max(depthGray2)));
% 
% sorted = sort(reshape(depthGray2,[],1), 'descend');
% minVal = mean(sorted(round(length(sorted)*90/100):length(sorted)));
% depthGray2 = (depthGray2 - minVal);
% sorted = sort(reshape(depthGray2,[],1), 'descend');
% maxVal = mean(sorted(1:round(length(sorted)*10/100)));
% depthGray2 = 1 - depthGray2/ maxVal;
% depthGray2(depthGray2>1) = 1;

% figure;
% subplot(1,3,1);
% imshow(depthGray);
% subplot(1,3,2);
% imshow(depthGray2);
% subplot(1,3,3);
% imshow((depthGray2+depthGray)/2);

% figure;
% subplot(1,3,1);
% imshow(depthGrad);
% subplot(1,3,2);
% imshow(depthGray);
% subplot(1,3,3);
% imshowpair(depthGrad,depthGray,'falsecolor');
% if (gray == 1)
depth = repmat(depthGray, [1,1,3]);
% else
% depth = repmat(depthGray2, [1,1,3]);

% end

end

