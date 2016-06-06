function [ depth ] = depthForTripleFocus( img1,img2)
%DEPTHFORCOUPLEFOCUS Summary of this function goes here
%   Detailed explanation goes here

% %% segmentation
% ratio = 1;
% kernelsize = 3;
% maxdist = 8;
% [Iseg, lables] = vl_quickseg(img1, ratio, kernelsize, maxdist);
% [Iseg2, lables2] = vl_quickseg(img2, ratio, kernelsize, maxdist);

%% Modified Laplacian maps.
[r,c,d] = size(img1);

h = [-1 2 -1];

img1Gray = rgb2gray(img1);
img2Gray = rgb2gray(img2);

img1Laplace = abs(imfilter(img1Gray,h,'replicate'))+abs(imfilter(img1Gray,h','replicate'));
img2Laplace = abs(imfilter(img2Gray,h,'replicate'))+abs(imfilter(img2Gray,h','replicate'));
% %% Laplacian map mean for each segment
% maxLabel1 = max(max(lables));
% maxLabel2 = max(max(lables2));
% % For each lable group, we find the mean luminance, and set the whole
% % segment to it's matching LUT value.
% mean1 = zeros(r,c);
% mean2 = zeros(r,c);
% for i = 0: maxLabel1
%     indexs = (lables == i);
%     numOfInd = sum(sum(indexs));
%     if(numOfInd > 0 )
%         mean1(indexs) = mean(mean(img1Laplace(indexs)));
%     end
% end
% for i = 0: maxLabel2
%     indexs = (lables2 == i);
%     numOfInd = sum(sum(indexs));
%     if(numOfInd > 0 )
%         mean2(indexs) = mean(mean(img2Laplace(indexs)));
% 
%     
%     end
% end

% % %% WLS for the segmented means, according to the reference segmentation
% % depth1W = wlsFilter(mean1, 1.5, 1.2, rgb2gray(Iseg));
% % depth2W = wlsFilter(mean2, 1.5, 1.2, rgb2gray(Iseg));
% % depth = depth1W./depth2W;
% 
% %% Normalize and run through sigmoid
% normalizedDepth = normalize(depth);
% normalizedDepth = remapInterpolation(normalizedDepth,2 , 1.4);
% figure; imshow(normalizedDepth);
% depth3 = repmat(normalizedDepth, [1,1,3]);

%% WLS for the segmented means, according to the reference segmentation
depth3W = wlsFilter(img1Laplace, 2, 1.3, rgb2gray(img1));
depth4W = wlsFilter(img2Laplace, 2, 1.3, rgb2gray(img1));
depth = depth3W./depth4W;

%% Normalize and run through sigmoid
normalizedDepth2 = normalize(depth);
normalizedDepth2 = remapInterpolation(normalizedDepth2,2 , 1);
figure; imshow(normalizedDepth2);
depth = repmat(normalizedDepth2, [1,1,3]);

end

