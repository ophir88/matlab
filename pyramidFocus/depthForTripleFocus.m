function [ depth ] = depthForTripleFocus( img1,img2 , img3)
%DEPTHFORCOUPLEFOCUS Summary of this function goes here
%   Detailed explanation goes here


[r,c,d] = size(img1);
kernelSize = max(r,c)/40;
kernelSize = round(kernelSize);
H = fspecial('average',kernelSize);
Hdepth = fspecial('average',round(kernelSize/5));

imgGray1 = rgb2gray(img1);
imgGray2 = rgb2gray(img2);
imgGray3 = rgb2gray(img3);


imgGray1 = imfilter(imgGray1,H,'replicate');
imgGray2 = imfilter(imgGray2,H,'replicate');
imgGray3 = imfilter(imgGray3,H,'replicate');
imgs ={};
imgs{1} = imgGray1;
imgs{2} = imgGray2;
imgs{3} = imgGray3;
% depth = 3*imgs{1}./(imgs{3} + imgs{2} + imgs{1});
% depth = normalize(depth);
% depth = depth.^2;

depth = zeros(r,c);
idx1 = imgGray1 > imgGray2 & imgGray1 > imgGray3;
idx2 = imgGray2 > imgGray1 & imgGray2 > imgGray3;
idx3 = imgGray3 > imgGray1 & imgGray3 > imgGray2;
depth(idx1) = 1;
depth(idx2) = 0.5;
depth(idx3) = 0;

% depth = 1 - depth;
% for i = 1 : r
%     for j = 1 : c
%         maxVal = 0;
%         index = 0;
%         for k = 1 : 3
%             if (img1{k}(i,j)>maxVal)
%                 maxVal = img1{k}(i,j);
%                 index = k - 1;                
%             end
%         end
%         depth(i,j) = index/2;
%     end
% end
% depth = 1 - depth;
% depth = imfilter(depth,Hdepth,'replicate');

% figure; imshow(depth);
% depthGray = (imgGray3 - imgGray2 - imgGray1);
% sorted = sort(reshape(depthGray,[],1), 'descend');
% minVal = mean(sorted(round(length(sorted)*95/100):length(sorted)));
% depthGray = (depthGray - minVal);
% sorted = sort(reshape(depthGray,[],1), 'descend');
% maxVal = mean(sorted(1:round(length(sorted)*5/100)));
% depthGray = 1 - depthGray/ maxVal;
% meanVal = mean(mean(depthGray));
% depthGrayO = depthGray;
% % depthGray(depthGray>1) = 1;
% depthGray1 = depthGray.^1.5;
% depthGray = remapInterpolation(depthGray, (meanVal*10-5), 0.7);



% depthGray(depthGray>1) = 1;
% figure;
% subplot(1,3,1);
% imshow(depthGrayO);
% subplot(1,3,2);
% imshow(depthGray1);
% subplot(1,3,3);
% imshow(depthGray);



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
depth = repmat(depth, [1,1,3]);
% else
% depth = repmat(depthGray2, [1,1,3]);

% end

end

