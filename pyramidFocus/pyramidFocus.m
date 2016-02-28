img1 = im2double(imread('./photos/largeDiff/dog/IMG_5975.jpg'));
img2 = im2double(imread('./photos/largeDiff/dog/IMG_5976.jpg'));
img3 = im2double(imread('./photos/largeDiff/dog/IMG_5977.jpg'));

img1 = imresize(img1,0.4);
img2 = imresize(img2,0.4);
img3 = imresize(img3,0.4);

[r,c,d] = size(img2);
% close all;
imgs = {};

imgs{1} = img1;
imgs{2} = img2;
imgs{3} = img3;

imgsTransformed = sift_estimate_transformation(imgs);
% figure; imshow(img2);
[img2, SUPPORT] = iat_inverse_warping(img2, imgsTransformed{2}.T, 'homography', 1:c, 1:r);
[img3, SUPPORT] = iat_inverse_warping(img3, imgsTransformed{3}.T, 'homography', 1:c, 1:r);
depthMap3 = depthForTripleFocus(img1, img2, img3);

partialImage = (1-depthMap3).*img1;
partialImage2 = pyramidBlur(partialImage);
[r,c,d] = size(img1);

partialImage2 = imresize(partialImage2 , [r c]);
partialImage3 = partialImage2 + depthMap3.*img1;
figure;
ax1=subplot(1,3,1);
imshow(partialImage);
% ax2=subplot(2,2,2);
% imshow(finalImg4);
ax3=subplot(1,3,2);
imshow(partialImage2);
ax4=subplot(1,3,3);
imshow(partialImage3);

linkaxes([ax1 ax3 ax4],'xy')

pyr1 = genPyr(img1,'laplace',4);
[r,c,d] = size(pyr1{length(pyr1)});
depthMapForLow = imresize(depthMap3 , [r c]);
depthMapForLow = depthMapForLow(:,:,1);
depthMapForLow = 1 - depthMapForLow;
depthLogical = depthMapForLow > 0.4;
imgSmallNTSC = rgb2ntsc(pyr1{length(pyr1)});
ultraExposed = imgSmallNTSC(:,:,1);
% figure; imshow(ultraExposed);
lightIdx = ultraExposed > 0.8;
finalIdx = logical(lightIdx .* depthLogical);
ultraExposed(finalIdx) = ultraExposed(finalIdx)*1.3;
imgSmallNTSC(:,:,1) = ultraExposed;
imgSmallRGB = ntsc2rgb(imgSmallNTSC);
% figure; imshow(imgSmallRGB);
pyrFinal2 = {};
pyrFinal2{length(pyr1)} = imgSmallRGB;
depthMaps = {};

for pyrNum = 1 : length(pyr1)-1
    [r,c,d] = size(pyr1{pyrNum});
    depthMap3 = imresize(depthMap3 , [r c]);
    depthMaps{pyrNum} = depthMap3;
    pyrFinal2{pyrNum} = real(pyr1{pyrNum}.*depthMap3); 
end

finalImg2 = pyrReconstruct(pyrFinal2);

finalImg3 = pyramidBlur(finalImg2, depthMaps);
finalImg5 = pyramidBlur(finalImg3, depthMaps);


pyr1 = genPyr(finalImg5,'laplace',5);
pyrFinal4 = {};
pyrFinal4{length(pyr1)} = pyr1{length(pyr1)};
pyrFinal4{length(pyr1)-1} = pyr1{length(pyr1)-1};

for pyrNum = 1 : length(pyr1)-2
    pyrFinal4{pyrNum} = real(pyr1{pyrNum}.*1.3);
end
finalImg4 = pyrReconstruct(pyrFinal4);

% pyr1 = genPyr(finalImg2,'laplace',4);
% pyrFinal3 = pyr1;
% [r,c,d] = size(pyr2{3});
% for pyrNum = 1 : length(pyr1)-2
%     pyrFinal3{pyrNum} = real(pyr1{pyrNum}.*2);
%     
% end
% finalImg3 = pyrReconstruct(pyrFinal3);

figure;
ax1=subplot(1,2,1);
imshow(img1);
% ax2=subplot(2,2,2);
% imshow(finalImg4);
% ax3=subplot(1,3,2);
% imshow(finalImg5);
ax4=subplot(1,2,2);
imshow(finalImg4);

linkaxes([ax1 ax4],'xy')
% figure; imshow(finalImg);
% imwrite(img1,'flowerOriginal.jpg')
% 
% imwrite(finalImg4,'flowerResult2.jpg')

's';