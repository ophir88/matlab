% Load images:
% -----------
img1 = im2double(imread('./photos/largeDiff/lior1/1.jpg'));
img2 = im2double(imread('./photos/largeDiff/lior1/2.jpg'));
img3 = im2double(imread('./photos/largeDiff/lior1/3.jpg'));

% Resize:
% -------

img1 = imresize(img1,0.4);
img2 = imresize(img2,0.4);
img3 = imresize(img3,0.4);

[r,c,d] = size(img1);

% Allignment:
% -----------
imgs = {};
imgs{1} = img1;
imgs{2} = img2;
imgs{3} = img3;

imgsTransformed = sift_estimate_transformation(imgs);
[img2, SUPPORT] = iat_inverse_warping(img2, imgsTransformed{2}.T, 'homography', 1:c, 1:r);
[img3, SUPPORT] = iat_inverse_warping(img3, imgsTransformed{3}.T, 'homography', 1:c, 1:r);

% Depth map:
% ----------
depthMap3 = depthForTripleFocus(img1, img2, img3);

% Blur background:
% ---------------
% get background.
background = (1-depthMap3).*img1;
% add highlight:
background = highlight(background, 1.4);
% blur.
backgroundTop = pyramidBlur(background);
backgroundTop = pyramidBlur(backgroundTop);
% fix black (hole) diffusion.
backgroundBottom = pyramidBlur(1-depthMap3);
background = backgroundTop./backgroundBottom;
background = imresize(background , [r c]);
background = background.*(1-depthMap3);

% Increase foreground details:
% ---------------------------
foreGround = depthMap3.*img1;
foreGround = imresize(foreGround , [r c]);

% Reattach foreground:
% --------------------
finalImage = background + foreGround;
finalImage = pyrDetails(finalImage, 1.3);


figure;
ax1=subplot(1,2,1);
imshow(img1);
ax2=subplot(1,2,2);
imshow(finalImage);
linkaxes([ax1 ax2],'xy')
imwrite(img1,'dogOriginal.jpg')
% 
imwrite(finalImage,'dogResult.jpg')

's';