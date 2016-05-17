


% Load images:
% % -----------
img1 = im2double(imread('./photos/fruit/1.jpg'));
img2 = im2double(imread('./photos/fruit/2.jpg'));
% img3 = im2double(imread('./photos/fromOwl/owl/3.jpg'));

% Resize:
% -------

% img1 = imresize(Iwarped(:,:,:,1) ,0.4);
% img2 = imresize(Iwarped(:,:,:,2),0.4);
% img3 = imresize(Iwarped(:,:,:,3),0.4);

img1 = imresize(img1 ,0.2);
img2 = imresize(img2,0.2);
% img3 = imresize(img3,0.2);
[r,c,d] = size(img1);

% Allignment:
% -----------
imgs = {};
imgs{1} = img1;
imgs{2} = img2;
% imgs{3} = img3;
%
imgsTransformed = sift_estimate_transformation(imgs);
[img2, SUPPORT] = iat_inverse_warping(img2, imgsTransformed{2}.T, 'homography', 1:c, 1:r);

% [img3, SUPPORT] = iat_inverse_warping(img3, imgsTransformed{3}.T, 'homography', 1:c, 1:r);
img1 = img1(10:r-10, 10: c-10, :);
img2 = img2(10:r-10, 10: c-10, :);
% img3 = img3(10:r-10, 10: c-10, :);

%% Depth map:
% ----------
depthMap3 = depthForTripleFocus(img1, img2, img3);


%%
depthMap3 = segmentedImg;
finalImageCombined = zeros(size(img1));
for i = 0: 0.2: 0.8
    currentImageIndx = depthMap3(:,:,1) > i & depthMap3(:,:,1) <= i+0.2;
    currentImageIndx = repmat(currentImageIndx, [1,1,3]);
    currentImage = img1;
    currentImage(~currentImageIndx) = 0;
    background = (1-depthMap3).*currentImage;
    background = highlight(background, 2 - i);
    backgroundTop = background;
    backgroundBottom = 1-depthMap3;

    for j = i : 0.2 : 1
        backgroundTop = pyramidBlur(backgroundTop);
        backgroundBottom = pyramidBlur(backgroundBottom);
        
    end
        
    background = backgroundTop./backgroundBottom;
    background = imresize(background , [r c]);
    background = background.*(1-depthMap3);
    
    % Increase foreground details:
    % ---------------------------
    foreGround = depthMap3.*currentImage;
    foreGround = imresize(foreGround , [r c]);
    
    % Reattach foreground:
    % --------------------
    finalImage = background + foreGround;
    finalImageCombined = finalImageCombined + finalImage;
    figure(1); imshow(finalImageCombined);
    input('');
    
end
%%
depthMap3 = depth3;
[r,c,d] = size(img1);

% figure; imshow(depth);
background = (1-depthMap3).*img1;

% add highlight:
% background = highlight(background, 1.1);
% blur.


backgroundTop = pyramidBlur(background);
% backgroundTop = pyramidBlur(backgroundTop);

% fix black (hole) diffusion.

backgroundBottom = pyramidBlur(1-depthMap3);
% backgroundBottom = pyramidBlur(backgroundBottom);

background = backgroundTop./backgroundBottom;
background = imresize(background , [r c]);
background = background.*(1-depthMap3);
background(isnan(background))=0;
% Increase foreground details:
% ---------------------------
foreGround = depthMap3.*img1;
foreGround = imresize(foreGround , [r c]);

% Reattach foreground:
% --------------------
finalImage = background + foreGround;
% finalImage = pyrDetails(finalImage, 1.3);

%%
amount = 1;
figure;
ax1=subplot(1,2,1);
imshow(img1);
ax2=subplot(1,2,2);
imshow(finalImage.*amount + img1.*(1-amount));
% ax3=subplot(1,3,3);
% imshow(result);
linkaxes([ax1 ax2],'xy')
% imwrite(img1,'dogOriginal.jpg')
%
% imwrite(finalImage,'dogResult.jpg')

's';