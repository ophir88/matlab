


% Load images:
% % -----------
img1 = im2double(imread('./photos/mate2/1.jpg'));
img2 = im2double(imread('./photos/mate2/2.jpg'));
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

% finalImageCombined2 = zeros(size(img1));

for i = 0: 0.1: 0.9
    i
    currentImageIndx = depthMap3(:,:,1) > i & depthMap3(:,:,1) <= i+0.1;
    currentImageIndx = repmat(currentImageIndx, [1,1,3]);
    mapSoFar = mapSoFar + currentImageIndx;
    
    currentImage = img1;
    currentImage(~currentImageIndx) = 0;
    
%     kernel = (1-(i+0.2))*15
    %     input('');
    if (i >= 0.9)
        currentLayerResult = currentImage;
    else
%         H = fspecial('disk',kernel);
            window = 15 - i*10
                Hgauss = fspecial('gaussian',floor(15 - i*10) , (1-(i+0.1))*10);

        %         H2 = fspecial('disk',kernel*1.3);
        
        blurred = imfilter(currentImage,Hgauss,'replicate');
        backGroundBlurred = double(currentImageIndx);
        
        backGroundBlurred1 = imfilter(backGroundBlurred,Hgauss,'replicate');
        %         backGroundBlurred2 = imfilter(backGroundBlurred,H2,'replicate');
        
        currentLayerResult = blurred./backGroundBlurred1;
        %         currentLayerResult2 = blurred./backGroundBlurred2;
        
    end
    currentLayerResult(~currentImageIndx) = 0;
    currentLayerResult(isnan(currentLayerResult)) = 0;
    
    %     figure(1);
    %     ax1=subplot(1,3,1);
    %     imshow(finalImageCombined);
    %     ax2=subplot(1,3,2);
    %     imshow(currentLayerResult);
    %     ax3=subplot(1,3,3);
    %     imshow(currentLayerResult+finalImageCombined);
    %     linkaxes([ax1 ax2 ax3],'xy')
    %   currentLayerResult(~currentImageIndx) = 0;
    %     figure(2); imshow(currentLayerResult);
    %     input('');
    %     currentLayerResult(isnan(currentLayerResult)) = 0;
    %     currentLayerResult(~currentImageIndx) = 0;
    %     currentLayerResult2(isnan(currentLayerResult2)) = 0;
    %     intersection = logical(finalImageCombined.*currentLayerResult);
    finalImageCombined = finalImageCombined + currentLayerResult;
    
    %     intersectionImg = finalImageCombined.*intersection./2;
    %     H2 = fspecial('average',1);
    
    %     intersectionImg = imfilter(intersectionImg,H2,'replicate');
    %     intersectionImgBack = imfilter(double(intersection),H2,'replicate');
    %     intersectionImgFinal = intersectionImg./intersectionImgBack;
    %     intersectionImgFinal(isnan(intersectionImgFinal))=0;
    %     intersectionImgFinal(~intersection) = 0;
    %     finalImageCombined(intersection) = 0;
    %     finalImageCombined = finalImageCombined + intersectionImgFinal;
    %     finalImageCombined2 = finalImageCombined2 + currentLayerResult2;
    %         input('');
    H2 = fspecial('disk',1.5);
    Hgauss2 = fspecial('gaussian',3, 3);
    if (i < 0.9)
        finalImageBackground = imfilter(mapSoFar,Hgauss2,'replicate');
        finalImageCombinedBlurred = imfilter(finalImageCombined,Hgauss2,'replicate');
        
        finalImageCombined = finalImageCombinedBlurred./finalImageBackground;
        finalImageCombined(~mapSoFar) = 0;
            finalImageCombined(isnan(finalImageCombined)) = 0;

    else

%         finalImageCombined = finalImageCombined;
    end
    
    
    figure(6);
    ax1=subplot(1,2,1);
    imshow(finalImageCombined);
    ax2=subplot(1,2,2);
    imshow(double(currentImageIndx));
    linkaxes([ax1 ax2],'xy')
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