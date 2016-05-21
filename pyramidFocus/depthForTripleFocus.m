function [ depth ] = depthForTripleFocus( img1,img2, img3)
%DEPTHFORCOUPLEFOCUS Summary of this function goes here
%   Detailed explanation goes here

%% segmentation


ratio = 1;
kernelsize = 3;
maxdist = 8;
[Iseg, lables] = vl_quickseg(img1, ratio, kernelsize, maxdist);
[Iseg2, lables2] = vl_quickseg(img2, ratio, kernelsize, maxdist);

%% depth maps pyramids
[r,c,d] = size(img1);
% kernelSize = max(r,c)/250;
% kernelSize = round(kernelSize);
h = [-1 2 -1];
% result = conv2(image, mask);
img1Gray = rgb2gray(img1);
img2Gray = rgb2gray(img2);
% img3Gray = rgb2gray(img3);

H = fspecial('average',4);

img1Laplace = abs(imfilter(img1Gray,h,'replicate'))+abs(imfilter(img1Gray,h','replicate'));
%     img1Laplace = (imfilter(img1Laplace,H,'replicate'));
img2Laplace = abs(imfilter(img2Gray,h,'replicate'))+abs(imfilter(img2Gray,h','replicate'));

% img3Laplace = abs(imfilter(img3Gray,h,'replicate'))+abs(imfilter(img3Gray,h','replicate'));

%     img2Laplace = (imfilter(img2Laplace,H,'replicate'));

%% depth maps pyramids
img1Grad = imgradient(img1Gray);
img2Grad = imgradient(img2Gray);
%%
H = fspecial('average',4);
epsilon = 0.00001;
depths = zeros(r,c,5);
for i = 0 : 4
    img1r = imresize(imgGray1 ,1 / 2^(i));
    size(img1r)
    img2r = imresize(imgGray2 ,1 / 2^(i));
    img3r = imresize(imgGray3 ,1 / 2^(i));
    imgGrayG1 = imfilter(img1r,H,'replicate');
    imgGrayG2 = imfilter(img2r,H,'replicate');
    imgGrayG3 = imfilter(img3r,H,'replicate');
    depthMap = 2*imgGrayG1./(imgGrayG1 + imgGrayG2 + epsilon);
    depths(:,:,i+1) = imresize(depthMap ,[r c]);
end

%%
maxLabel1 = max(max(lables));
maxLabel2 = max(max(lables2));

% For each lable group, we find the mean luminance, and set the whole
% segment to it's matching LUT value.
segmentedImg = zeros(r,c);
mean1 = zeros(r,c);
mean2 = zeros(r,c);
mean3 = zeros(r,c);
numOfNonZero1 = zeros(r,c);
numOfNonZero2 = zeros(r,c);
for i = 0: maxLabel1
    indexs = (lables == i);
    numOfInd = sum(sum(indexs));
    if(numOfInd > 0 )
%         numOfNonZero1(indexs) = sum(img1Laplace(indexs) > 0.01)./numOfInd;
        power1 = mean(mean(img1Laplace(indexs)));
        mean1(indexs) = power1;
    end
end
for i = 0: maxLabel2
    indexs = (lables2 == i);
    numOfInd = sum(sum(indexs));
    if(numOfInd > 0 )
%         numOfNonZero2(indexs) = sum(img2Laplace(indexs) > 0.01)./numOfInd;
        power2 = mean(mean(img2Laplace(indexs)));
        mean2(indexs) = power2;
    end
end

% %%
% % segmentedImg(isnan(segmentedImg)) = 0;
% % segmentedImg(isinf(segmentedImg)) = 0;
% maxLabel1 = max(max(lables));
% maxLabel2 = max(max(lables2));
% segmentedImg = zeros(r,c);
% R1 = Iseg(:,:,1);
% G1 = Iseg(:,:,2);
% B1 = Iseg(:,:,3);
% R2 = Iseg2(:,:,1);
% G2 = Iseg2(:,:,2);
% B2 = Iseg2(:,:,3);
% for i = 0: maxLabel1
%     
%     indexs = (lables == i);
%     r1 = unique((R1(indexs)));
%     g1 = unique((G1(indexs)));
%     b1 = unique((B1(indexs)));
% 
% %     color(:)
%     numOfInd = sum(sum(indexs));
%     if(numOfInd > 0 )
%         foundLablesInSecondImg = lables2(indexs);
%         uniqeLabels = unique(foundLablesInSecondImg);
% %         numel(unique(foundLablesInSecondImg))
%         [a,b]=hist(foundLablesInSecondImg,max(uniqeLabels));
%         [amount, I] = sort(a,'descend' );
%         if numel(uniqeLabels) > 3
%             maxIndex = 3;
%             totalAmount = amount(1)+amount(2)+amount(3);
%         else
%             maxIndex = numel(uniqeLabels);
%             totalAmount = 0;
%             for j = 1 : numel(uniqeLabels)
%                 totalAmount = totalAmount + amount(j);
%             end
% 
%         end
% %                 percentage = totalAmount/numOfInd
% 
%         power2 = 0;
%         totalDistance =  0;
%         for sortedIndex = 1 : maxIndex
%             newLabel = I(sortedIndex);
%             strength = amount(sortedIndex)/totalAmount;
%             indexes = (lables2 == newLabel);
%             r2 = unique((R2(indexes)));
%             g2 = unique((G2(indexes)));
%             b2 = unique((B2(indexes)));
%             distance = sqrt((r1-r2)^2+(g1-g2)^2+(b1-b2)^2);
%             distancePower = exp(-(distance)/(2*0.1^2));
%             totalDistance = totalDistance + distancePower;
%             power2 = power2 + mean(mean(img2Laplace(indexes)))*strength*distancePower;
%         end
%         power2 = power2/totalDistance;
% %         mostFrequentLable = mode(foundLablesInSecondImg);
% %         indexs2 = (lables2 == mostFrequentLable);
% %         numOfInd2 = sum(sum(indexs2));
% %         numOfNonZero1(indexs) = sum(img1Laplace(indexs) > 0.01)./numOfInd;
% %         numOfNonZero2(indexs2) = sum(img2Laplace(indexs2) > 0.01)./numOfInd2;
%         power1 = mean(mean(img1Laplace(indexs)));
% %         power2
% %                             input('');
% 
% %         power2 = mean(mean(img2Laplace(indexs2)));
% %         numOfInd
% %         power1./power2
%         segmentedImg(indexs) = power1./power2;
% %         input('');
% %         mean1(indexs) = power1;
% %         mean2(indexs2) = power2;
%     end
% end
%%
segmentedImg2 = segmentedImg.*normalize(numOfNonZero1)./(normalize(numOfNonZero2));
%%
            segmentedImg(isnan(segmentedImg)) = 0;
            segmentedImg(isinf(segmentedImg)) = 0;

%%
mask = zeros(r,c);
index1 = mean1 > mean2 & mean1 > mean3;
index2 = mean2 > mean1 & mean2 > mean3;
index3 = mean3 > mean1 & mean3 > mean2;
mask(index1) = 1;
mask(index2) = 0.5;
mask(index3) = 0.1;

%%
se = strel('disk',3);
grad1Erode = imerode(img1Laplace,se);
grad2Erode = imerode(img2Laplace,se);

figure;
ax1=subplot(2,4,1);
imshow(normalize(mean1));
title('mean1');
% ax2=subplot(2,4,2);
% imshow(normalize(var1));
% title('var1');

ax3=subplot(2,4,3);
imshow((numOfNonZero1));
title('nonzero1');

% ax4=subplot(2,4,4);
% imshow(normalize(grad1Erode));
% title('grad1');

ax5=subplot(2,4,5);
imshow(normalize(mean2));
title('mean2');

% ax6=subplot(2,4,6);
% imshow(normalize(var2));
    % title('var2');

ax7=subplot(2,4,7);
imshow((numOfNonZero2));
title('nonzero1');
% 
% ax8=subplot(2,4,8);
% imshow(normalize(grad2Erode));
% title('grad1');
linkaxes([ax1  ax3  ax5  ax7 ],'xy')
%%
maskFilled = 1 - imfill(1 - segmentedImg);

%%
% depthTop = wlsFilter(segmentedImg, 1, 1.2, imgGray1);
% depthBottom = wlsFilter(1 - segmentedImg, 1, 1.2, imgGray1);
%%
% result = depthTop ./ depthBottom;
%%
% imgGrayG1 = imfilter(imgGray1,H,'replicate');
% imgGrayG2 = imfilter(imgGray2,H,'replicate');
% imgGrayG32 = imfilter(imgGray3,H,'replicate');

% figure;
%     ax1=subplot(1,3,1);
%     imshow(imgGray1);
%     ax2=subplot(1,3,2);
%     imshow(imgGray2);
%     ax3=subplot(1,3,3);
%     imshow(imgGray3);
%
% linkaxes([ax1 ax2 ax3],'xy')
% imgs ={};
% imgs{1} = imgGrayG1;
% imgs{2} = imgGrayG2;
% imgs{3} = imgGrayG3;
%
% epsilon = 0.00001;
% depth = 3*imgs{1}./(imgs{1} + imgs{2} + imgs{3}  + epsilon);

%%
% depth1 = normalize(mean1);
depth1W = wlsFilter(mean1, 1.5, 1.2, rgb2gray(Iseg));
% depth2 = normalize(mean2);
depth2W = wlsFilter(mean2, 1.5, 1.2, rgb2gray(Iseg));
depth = depth1W./depth2W;
%%
% figure; imshow(depth);
% depth = normalize(segmentedImg);
% meanVal = mean(mean(depth));
% % depth = remapInterpolation(depth, (meanVal*10-5), 1);
% figure; imshow(depth);
% 
% depthW = wlsFilter(depth, 1, 1.2, img1Gray);
% % depthWBottom = wlsFilter(1-depth, 1, 1.2, img1Gray);
% % depthWB = depthW./(epthWBottom + 0.00001);

%%
normalizedDepth = normalize(depth);
normalizedDepth = remapInterpolation(normalizedDepth,3 , 1);
figure; imshow(normalizedDepth);
depth3 = repmat(normalizedDepth, [1,1,3]);


end

