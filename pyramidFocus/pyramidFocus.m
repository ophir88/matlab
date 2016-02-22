img1 = im2double(imread('./photos/mouse/IMG_0552.jpg'));
img2 = im2double(imread('./photos/mouse/IMG_0553.jpg'));
img3 = im2double(imread('./photos/mouse/IMG_0554.jpg'));

img1 = imresize(img1,0.8);
img2 = imresize(img2,0.8);
img3 = imresize(img3,0.8);

[r,c,d] = size(img2);
close all;
imgs = {};
% figure; imshow(img1);
% imwrite(img1,'mouseOriginal.jpg')

% imgZeroPadded = zeros(size(img1));
% imgZeroPadded(360:670,1:370,:) = img1(360:670,1:370,:);
% figure; imshow(imgZeroPadded);

imgs{1} = img1;
imgs{2} = img2;
imgs{3} = img3;

imgsTransformed = sift_estimate_transformation(imgs);
% figure; imshow(img2);
[img2, SUPPORT] = iat_inverse_warping(img2, imgsTransformed{2}.T, 'homography', 1:c, 1:r);
[img3, SUPPORT] = iat_inverse_warping(img3, imgsTransformed{3}.T, 'homography', 1:c, 1:r);

% figure;
% imshowpair(WIMAGE,img1,'blend','Scaling','joint');

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
pyr2 = genPyr(img2,'laplace',4);
pyr3 = genPyr(img3,'laplace',4);

pyrFinal2 = {};
pyrFinal2{length(pyr1)} = pyr1{length(pyr1)};
[r,c,d] = size(pyr2{3});
depthMaps = {};
for pyrNum = 1 : length(pyr1)-1
    if (pyrNum < 2)
    depthMap1 = depthForCoupleFocus(pyr1{pyrNum}, pyr2{pyrNum}, 0);
    depthMap2 = depthForCoupleFocus(depthMap1, pyr3{pyrNum}, 0);
    figure;
    ax1=subplot(1,3,1);
    imshow(depthMap1);
    ax2=subplot(1,3,2);
    imshow(depthMap2);
% imshowpair(finalImg,finalImg2,'diff');

linkaxes([ax1 ax2],'xy')
    else
        [r,c,d] = size(pyr2{pyrNum});
        depthMap2 = imresize(depthMap2 , [r c]);
    end
    depthMaps{pyrNum} = depthMap2;
    pyrFinal2{pyrNum} = real(pyr1{pyrNum}.*depthMap2);
    
end
finalImg2 = pyrReconstruct(pyrFinal2);

pyr1 = genPyr(finalImg2,'laplace',4);
pyrFinal3 = {};
pyrFinal3{length(pyr1)} = pyr1{length(pyr1)};
for pyrNum = 1 : length(pyr1)-1
    pyrFinal3{pyrNum} = real(pyr1{pyrNum}.*depthMaps{pyrNum});
end
finalImg3 = pyrReconstruct(pyrFinal3);

pyr1 = genPyr(finalImg3,'laplace',4);
pyrFinal4 = {};
pyrFinal4{length(pyr1)} = pyr1{length(pyr1)};
pyrFinal4{length(pyr1)-1} = pyr1{length(pyr1)-1};

for pyrNum = 1 : length(pyr1)-2
    pyrFinal4{pyrNum} = real(pyr1{pyrNum}.*1.02);
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
ax1=subplot(2,2,1);
imshow(img1);
ax2=subplot(2,2,2);
imshow(finalImg2);
ax3=subplot(2,2,3);
imshow(finalImg3);
ax4=subplot(2,2,4);
imshow(finalImg4);
% imshowpair(finalImg,finalImg2,'diff');

linkaxes([ax1 ax2 ax3 ax4],'xy')
% figure; imshow(finalImg);
% imwrite(img1,'kitchenOriginal.jpg')

% imwrite(finalImg3,'kitchenResult.jpg')

's';