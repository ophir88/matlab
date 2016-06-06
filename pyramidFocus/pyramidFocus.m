


% Load images:
% % -----------
img1 = im2double(imread('./photos/cup/1.jpg'));
img2 = im2double(imread('./photos/cup/2.jpg'));
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
tic
depthMap3 = depthForTripleFocus(img1, img2);

        wtime = toc
        fprintf ( 1, '  MY_PROGRAM took %f seconds to run.\n', wtime );

%%
% depthMap3 = depth4;
tic
finalImageCombined = zeros(size(img1));
mapSoFar = zeros(size(img1));
imgLum = rgb2ycbcr(img1);
imgLum = imgLum(:,:,1);
imgLum = repmat(imgLum, [1,1,3]);
pentKernel = im2double(imread('pentKernel.jpg'));
pentKernelOriginal = pentKernel;
pentKernel = pentKernel(:,:,1);

pentKernel = imresize(pentKernel,[20 20]);

for i = 0: 0.1: 0.9
    
    currentImageIndx = depthMap3(:,:,1) > i & depthMap3(:,:,1) <= i+0.1;
    currentImageIndx = repmat(currentImageIndx, [1,1,3]);
    mapSoFar = mapSoFar + currentImageIndx;
    
    currentImage = img1;
    currentImage(~currentImageIndx) = 0;
    currentLum = imgLum;
    currentLum(~currentImageIndx) = 0;

    currentKernel = double(imresize(pentKernel,(1-i-0.1)));
    if (i >= 0.9)
        currentLayerResult = currentImage;
    else
        currentImage(:,:,1) = conv2(currentImage(:,:,1),currentKernel,'same');
        currentImage(:,:,2) = conv2(currentImage(:,:,2),currentKernel,'same');
        currentImage(:,:,3) = conv2(currentImage(:,:,3),currentKernel,'same');
        
        backGroundBlurred = double(currentImageIndx);
        backGroundBlurred(:,:,1) = conv2(backGroundBlurred(:,:,1),currentKernel,'same');
        backGroundBlurred(:,:,2) = conv2(backGroundBlurred(:,:,2),currentKernel,'same');
        backGroundBlurred(:,:,3) = conv2(backGroundBlurred(:,:,3),currentKernel,'same');
        
        currentLayerResult = currentImage./backGroundBlurred;
    end
    currentLayerResult(~currentImageIndx) = 0;
    currentLayerResult(isnan(currentLayerResult)) = 0;
    finalImageCombined = finalImageCombined + currentLayerResult;   
    
    
    if (i < 0.9)
        Hgauss2 = fspecial('gaussian',floor(10 - i*10), (10 - i*10)^2);
        finalImageBackground = imfilter(mapSoFar,Hgauss2,'replicate');
        finalImageCombinedBlurred = imfilter(finalImageCombined,Hgauss2,'replicate');  
        finalImageCombined = finalImageCombinedBlurred./finalImageBackground;
        finalImageCombined(~mapSoFar) = 0;
        finalImageCombined(isnan(finalImageCombined)) = 0;
        
    else
        for highLightIndex = 0.3 : 0.3 : 0.6
            lastIndex = depthMap3(:,:,1) > highLightIndex - 0.3 & depthMap3(:,:,1) < highLightIndex;
        lastIndex = repmat(lastIndex, [1,1,3]);
        currentImage = img1;
        currentImage(~lastIndex) = 0;
        
        currentLum = imgLum;
        currentLum(~lastIndex) = 0;
        luminanceArea = currentImage;
        luminanceArea(currentLum<=0.90) = 0;
        lumMask = medfilt2(imgradient(luminanceArea(:,:,1)));
        if (highLightIndex == 0.3)
            kernelSize = 15;
            highLightFactor = 0.95;
        else
            kernelSize = 10;
            highLightFactor = 0.95;
        end
        img1Squared = img1.*img1;
        pentKernelHigh = imresize(pentKernelOriginal,[kernelSize kernelSize]);
        pentKernelHigh = pentKernelHigh./(sum(sum(pentKernelHigh)));
        luminanceArea(:,:,1) = conv2(lumMask.*img1Squared(:,:,1),pentKernelHigh,'same');
        luminanceArea(:,:,2) = conv2(lumMask.*img1Squared(:,:,2),pentKernelHigh,'same');
        luminanceArea(:,:,3) = conv2(lumMask.*img1Squared(:,:,3),pentKernelHigh,'same');
        luminanceArea = luminanceArea.^(1/2);
        luminanceAdd = luminanceArea;
        luminanceAdd(isnan(luminanceAdd)) = 0;
        luminanceAdd(luminanceAdd>1) = 1;
%         luminanceAdd = luminanceAdd.*1.5;
        finalImageCombined = finalImageCombined -luminanceAdd.*finalImageCombined + luminanceAdd.*highLightFactor;
        end
        
    end
%     figure(7);
%     ax1=subplot(1,2,1);
%     imshow(finalImageCombined);
%     ax2=subplot(1,2,2);
%     imshow(img1);
%     linkaxes([ax1 ax2],'xy')
%     input('');
end
figure(7);
    ax1=subplot(1,2,1);
    imshow(finalImageCombined);
    ax2=subplot(1,2,2);
    imshow(img1);
    linkaxes([ax1 ax2],'xy')
%     input(''); 