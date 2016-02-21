img1 = im2double( imread('./photos/fruit/IMG_5882.jpg'));
img2 = im2double(imread('./photos/fruit/IMG_5884.jpg'));
img1 = imresize(img1,0.4);
img2 = imresize(img2,0.4);
[r,c,d] = size(img2);
% close all;
imgs = {};
% figure; imshow(img1);
% imwrite(img1,'mouseOriginal.jpg')

% imgZeroPadded = zeros(size(img1));
% imgZeroPadded(360:670,1:370,:) = img1(360:670,1:370,:);
% figure; imshow(imgZeroPadded);

imgs{1} = img1;
imgs{2} = img2;
imgsTransformed = sift_estimate_transformation(imgs);
% figure; imshow(img2);
[WIMAGE, SUPPORT] = iat_inverse_warping(img2, imgsTransformed{2}.T, 'homography', 1:c, 1:r);

% pyr1 = genPyr(img1,'laplace',5);
% pyr2 = genPyr(WIMAGE,'laplace',5);
% pyrFinal1 = {};
% pyrFinal1{length(pyr1)} = pyr1{length(pyr1)};
% [r,c,d] = size(pyr2{3});
% for pyrNum = 1 : length(pyr1)-1
% %     depthMap = depthForCoupleFocus(pyr1{pyrNum}, pyr2{pyrNum}, 0);
% %     imgSmall = 0;
%     pyrFinal1{pyrNum} = 0;
%     
% end
% finalImg = pyrReconstruct(pyrFinal);

pyr1 = genPyr(img1,'laplace',4);
pyr2 = genPyr(WIMAGE,'laplace',4);
pyrFinal2 = {};
pyrFinal2{length(pyr1)} = pyr1{length(pyr1)};
[r,c,d] = size(pyr2{3});
for pyrNum = 1 : length(pyr1)-1
    depthMap = depthForCoupleFocus(pyr1{pyrNum}, pyr2{pyrNum}, 0);
    pyrFinal2{pyrNum} = real(pyr1{pyrNum}.*depthMap);
    
end
finalImg2 = pyrReconstruct(pyrFinal2);

pyr1 = genPyr(finalImg2,'laplace',4);
pyrFinal3 = pyr1;
[r,c,d] = size(pyr2{3});
for pyrNum = 1 : length(pyr1)-2
    pyrFinal3{pyrNum} = real(pyr1{pyrNum}.*2);
    
end
finalImg3 = pyrReconstruct(pyrFinal3);

figure;
ax1=subplot(1,2,1);
imshow(img1);
% ax2=subplot(1,2,2);
% imshow(finalImg2);
ax3=subplot(1,2,2);
imshow(finalImg3);
% imshowpair(finalImg,finalImg2,'diff');

linkaxes([ax1 ax2 ax3],'xy')
% figure; imshow(finalImg);

% imwrite(finalImg,'mouseResult.jpg')

's';