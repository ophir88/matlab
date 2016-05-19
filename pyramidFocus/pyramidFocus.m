


% Load images:
% % -----------
img1 = im2double(imread('./photos/penHolder/1.jpg'));
img2 = im2double(imread('./photos/penHolder/3.jpg'));
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
depthMap3 = depth3;

finalImageCombined = zeros(size(img1));
mapSoFar = zeros(size(img1));
% imgLum = rgb2ycbcr(img1);
% imgLum = imgLum(:,:,1);
% imgLum = repmat(imgLum, [1,1,3]);
pentKernel = imread('pentKernel.jpg');

pentKernel = pentKernel(:,:,1);
pentKernel = imresize(pentKernel,[15 15]);
% finalImageCombined2 = zeros(size(img1));

for i = 0: 0.1: 0.9
    currentImageIndx = depthMap3(:,:,1) > i & depthMap3(:,:,1) <= i+0.1;
    currentImageIndx = repmat(currentImageIndx, [1,1,3]);
    mapSoFar = mapSoFar + currentImageIndx;
    
    currentImage = img1;
    currentImage(~currentImageIndx) = 0;
%     currentLum = imgLum;
%     currentLum(~currentImageIndx) = 0;

    currentKernel = double(imresize(pentKernel,1-i-0.1));
    if (i >= 0.9)
        currentLayerResult = currentImage;
    else
        backGroundBlurred = double(currentImageIndx);

        luminanceArea = currentImage;
%         currentImage(currentLum>=0.8) = currentImage(currentLum>=0.8).*2;
        
        %         reguler blur:
        %         ------------
%         Hgauss = fspecial('gaussian',floor(15 - i*10) , (1-(i+0.1))*10);
%         blurred = imfilter(currentImage,Hgauss,'replicate');
%         
%         backGroundBlurred1 = imfilter(backGroundBlurred,Hgauss,'replicate');
%         currentLayerResult = blurred./backGroundBlurred1;
        %         conv blur:
        %         ------------
        
%          luminanceArea(:,:,1) = conv2(luminanceArea(:,:,1),currentKernel,'same');
%         luminanceArea(:,:,2) = conv2(luminanceArea(:,:,2),currentKernel,'same');
%         luminanceArea(:,:,3) = conv2(luminanceArea(:,:,3),currentKernel,'same');
%         luminanceMask = double(luminanceArea>0);
%         luminanceMask(:,:,1) = conv2(luminanceMask(:,:,1),currentKernel,'same');
%         luminanceMask(:,:,2) = conv2(luminanceMask(:,:,2),currentKernel,'same');
%         luminanceMask(:,:,3) = conv2(luminanceMask(:,:,3),currentKernel,'same');
%         luminanceArea = luminanceArea./luminanceMask;
%         luminanceArea(isnan(luminanceArea)) = 0;

        currentImage(:,:,1) = conv2(currentImage(:,:,1),currentKernel,'same');
        currentImage(:,:,2) = conv2(currentImage(:,:,2),currentKernel,'same');
        currentImage(:,:,3) = conv2(currentImage(:,:,3),currentKernel,'same');

        backGroundBlurred(:,:,1) = conv2(backGroundBlurred(:,:,1),currentKernel,'same');
        backGroundBlurred(:,:,2) = conv2(backGroundBlurred(:,:,2),currentKernel,'same');
        backGroundBlurred(:,:,3) = conv2(backGroundBlurred(:,:,3),currentKernel,'same');
        currentLayerResult = currentImage./backGroundBlurred;
        
%         currentLayerResult = currentLayerResult + luminanceArea.*0.1;
       
    end
    currentLayerResult(~currentImageIndx) = 0;
    currentLayerResult(isnan(currentLayerResult)) = 0;
    finalImageCombined = finalImageCombined + currentLayerResult;
    
    H2 = fspecial('disk',1.5);
    Hgauss2 = fspecial('gaussian',3, 3);
    if (i < 0.9)
%             currentKernel = double(imresize(pentKernel,(1-i)/2));
% 
%         finalImageCombinedBlurred = zeros(size(mapSoFar));
%         finalImageBackground = zeros(size(mapSoFar));
%         finalImageCombinedBlurred(:,:,1) = conv2(finalImageCombined(:,:,1),currentKernel,'same');
%         finalImageCombinedBlurred(:,:,2) = conv2(finalImageCombined(:,:,2),currentKernel,'same');
%         finalImageCombinedBlurred(:,:,3) = conv2(finalImageCombined(:,:,3),currentKernel,'same');
% 
%         finalImageBackground(:,:,1) = conv2(mapSoFar(:,:,1),currentKernel,'same');
%         finalImageBackground(:,:,2) = conv2(mapSoFar(:,:,2),currentKernel,'same');
%         finalImageBackground(:,:,3) = conv2(mapSoFar(:,:,3),currentKernel,'same');
        
        finalImageBackground = imfilter(mapSoFar,Hgauss2,'replicate');
        finalImageCombinedBlurred = imfilter(finalImageCombined,Hgauss2,'replicate');
        
        finalImageCombined = finalImageCombinedBlurred./finalImageBackground;
        finalImageCombined(~mapSoFar) = 0;
        finalImageCombined(isnan(finalImageCombined)) = 0;
        
    end
        
    
    
    figure(6);
    ax1=subplot(1,2,1);
    imshow(finalImageCombined);
    ax2=subplot(1,2,2);
    imshow(double(currentImageIndx));
    linkaxes([ax1 ax2],'xy')
%     input('');
    
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