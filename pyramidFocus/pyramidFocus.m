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

pyr1 = genPyr(img1,'laplace',4);
pyr2 = genPyr(img2,'laplace',4);
pyr3 = genPyr(img3,'laplace',4);

pyrFinal2 = {};
pyrFinal2{length(pyr1)} = pyr1{length(pyr1)};
[r,c,d] = size(pyr2{3});
depthMaps = {};
for pyrNum = 1 : length(pyr1)-1
%     if (pyrNum < 2)
%     depthMap1 = depthForCoupleFocus(pyr1{pyrNum}, pyr2{pyrNum}, 0);
%     depthMap2 = depthForCoupleFocus(depthMap1, pyr3{pyrNum}, 0);
    depthMap3 = depthForTripleFocus(img1, img2, img3);
%     figure; imshow(depthMap3);
%     figure;
%     ax1=subplot(1,3,1);
%     imshow(depthMap1);
%     ax2=subplot(1,3,2);
%     imshow(depthMap2);
%     ax3=subplot(1,3,3);
%     imshow(depthMap3);
% 
% linkaxes([ax1 ax2 ax3],'xy')
% %     else
%         [r,c,d] = size(pyr2{pyrNum});
%         depthMap3 = imresize(depthMap3 , [r c]);
%     end
     [r,c,d] = size(pyr2{pyrNum});
        depthMap3 = imresize(depthMap3 , [r c]);
    depthMaps{pyrNum} = depthMap3;
    pyrFinal2{pyrNum} = real(pyr1{pyrNum}.*depthMap3);
    
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
pyrFinal5 = {};
pyrFinal5{length(pyr1)} = pyr1{length(pyr1)};
for pyrNum = 1 : length(pyr1)-1
    pyrFinal5{pyrNum} = real(pyr1{pyrNum}.*depthMaps{pyrNum});
end
finalImg5 = pyrReconstruct(pyrFinal5);

pyr1 = genPyr(finalImg5,'laplace',4);
pyrFinal4 = {};
pyrFinal4{length(pyr1)} = pyr1{length(pyr1)};
pyrFinal4{length(pyr1)-1} = pyr1{length(pyr1)-1};

for pyrNum = 1 : length(pyr1)-2
    pyrFinal4{pyrNum} = real(pyr1{pyrNum}.*1.5);
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
ax1=subplot(1,3,1);
imshow(img1);
% ax2=subplot(2,2,2);
% imshow(finalImg4);
ax3=subplot(1,3,2);
imshow(finalImg5);
ax4=subplot(1,3,3);
imshow(finalImg4);
% imshowpair(finalImg,finalImg2,'diff');

linkaxes([ax1 ax3 ax4],'xy')
% figure; imshow(finalImg);
imwrite(img1,'kodaOriginal.jpg')
% 
imwrite(finalImg4,'kodaResult3.jpg')

's';