function [ depth ] = depthForTripleFocus( img1,img2 , img3)
%DEPTHFORCOUPLEFOCUS Summary of this function goes here
%   Detailed explanation goes here

%% segmentation
ratio = 0.5;
kernelsize = 2;
maxdist = 10;
[Iseg, lables] = vl_quickseg(img1, ratio, kernelsize, maxdist);

%% depth maps pyramids
[r,c,d] = size(img1);
% kernelSize = max(r,c)/250;
% kernelSize = round(kernelSize);
imgGray1 = imgradient( rgb2gray(img1));
imgGray2 = imgradient(rgb2gray(img2));
imgGray3 = imgradient(rgb2gray(img3));
H = fspecial('disk',2);
epsilon = 0.00001;
depths = zeros(r,c,5);
for i = 0 : 4
    img1r = imresize(imgGray1 ,1 / 2^(i));
    img2r = imresize(imgGray2 ,1 / 2^(i));
    img3r = imresize(imgGray3 ,1 / 2^(i));
    imgGrayG1 = imfilter(img1r,H,'replicate');
    imgGrayG2 = imfilter(img2r,H,'replicate');
    imgGrayG3 = imfilter(img3r,H,'replicate');
    depthMap = 3*imgGrayG1./(imgGrayG1 + imgGrayG2 + imgGrayG3  + epsilon);
    depths(:,:,i+1) = imresize(depthMap ,[r c]);
end

%%
maxLabel = max(max(lables));
% For each lable group, we find the mean luminance, and set the whole
% segment to it's matching LUT value.
segmentedImg = zeros(r,c);

for i = 0: maxLabel
    i
    indexs = (lables == i);
    indexs5 = repmat(indexs,[1,1,5]);
    
    numOfInd = sum(sum(indexs));
    if(numOfInd > 0 )
        variance = var(depths(indexs5));
        if (variance < 0.2)
            meanVal = mean(depths(indexs5));
            segmentedImg(indexs) = meanVal;
        else
            segmentedImg(indexs) = 0;
        end
        %         value = ceil(mean(mean(imgY(indexs))));
        %         if (value == 0)
        %             value = 1;
        %         end
        %         segmentedImg(indexs) = lut(1,value);
    end
end
%%
imgGrayG1 = imfilter(imgGray1,H,'replicate');
imgGrayG2 = imfilter(imgGray2,H,'replicate');
imgGrayG32 = imfilter(imgGray3,H,'replicate');

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

