% % 
% % % Load images:
% % % -----------
% % img1 = im2double(imread('./photos/largeDiff/brain/1.jpg'));
% % img2 = im2double(imread('./photos/largeDiff/brain/2.jpg'));
% % img3 = im2double(imread('./photos/largeDiff/brain/3.jpg'));
% % 
% % % Resize:
% % % -------
% % 
% % img1 = imresize(img1,0.4);
% % img2 = imresize(img2,0.4);
% % img3 = imresize(img3,0.4);
% % 
% % [r,c,d] = size(img1);
% 
% % Allignment:
% % % -----------
% % Ioriginal = {};
% % Ioriginal{1} = img1;
% % Ioriginal{2} = img2;
% % Ioriginal{3} = img3;
% 
% %% set parameters
% feature_method='sift';
% estimate_method='RANSAC';
% projection_type='homography'; % 'translation','euclidean','affine','homography'
% fusion_method='mean';
% minimal_sharpness = 0.9;
% single_bracket_name='brain';
% saveStuff = false;
% plotStuff = true;
% %% load data info
% stack_folder='./photos/largeDiff';
% [bracket_names]=read_subfolders(stack_folder);
% bracketName=find(~cellfun('isempty',strfind(bracket_names,single_bracket_name)));
% Ioriginal = read_focus_bracket(stack_folder, bracket_names{bracketName(1)});
% [row, col, color, Nimages] = size(Ioriginal);
% %take only part of the images
% % pickIndex=[4 2 3 5 6];
% % pickIndex=[4 3 5];
% pickIndex=1:Nimages;
% Ioriginal=Ioriginal(:,:,:,pickIndex);
% Nimages = size(Ioriginal,4);
% 
% %% align images - single alignment
% % [sharpIndex, indexByRankOfSharpness, relativeSharpness] = choose_sharpest_image(Ioriginal);
% Nimages = size(Ioriginal,4);
% Igray = imarray2gray(Ioriginal);
% %transform estimation
% if strcmpi(feature_method,'sift')
%   [featureData]=sift_extract_features(Igray);
%   if strcmpi(estimate_method,'ransac')
%     [projectionMatrices, featureData]= ...
%       ransac_estimate_transformation_sequential(featureData, projection_type, 1);
%   else
%     error('not implemented')
%   end
% elseif strcmpi(feature_method,'latch')
%   [featureData]=latch_extract_features(Igray);
%   if strcmpi(estimate_method,'ransac')
%     [projectionMatrices, featureData]= ...
%       ransac_estimate_transformation_sequential(featureData, projection_type, sharpIndex);
%   else
%     error('not implemented')
%   end
% elseif strcmpi(feature_method,'ecc')
%   projectionMatrices=ecc_estimate_transformation(Igray, projection_type);
% else
%   error('not implemented')
% end
% %backwarp
% [Iwarped, supportPixels] = ...
%   backwarp_to_ref_iat(Ioriginal, projectionMatrices, projection_type, 1);
% % Icropped = crop_full_support(Iwarped, supportPixels);
% 
% 


% Load images:
% % -----------
img1 = im2double(imread('./photos/largeDiff/dog/1.jpg'));
img2 = im2double(imread('./photos/largeDiff/dog/2.jpg'));
img3 = im2double(imread('./photos/largeDiff/dog/3.jpg'));

% Resize:
% -------

% img1 = imresize(Iwarped(:,:,:,1) ,0.4);
% img2 = imresize(Iwarped(:,:,:,2),0.4);
% img3 = imresize(Iwarped(:,:,:,3),0.4);

img1 = imresize(img1 ,0.2);
img2 = imresize(img2,0.2);
img3 = imresize(img3,0.2);
[r,c,d] = size(img1);

% Allignment:
% -----------
imgs = {};
imgs{1} = img1;
imgs{2} = img2;
imgs{3} = img3;
% 
imgsTransformed = sift_estimate_transformation(imgs);
[img2, SUPPORT] = iat_inverse_warping(img2, imgsTransformed{2}.T, 'homography', 1:c, 1:r);
[img3, SUPPORT] = iat_inverse_warping(img3, imgsTransformed{3}.T, 'homography', 1:c, 1:r);

%% Depth map:
% ----------
depthMap3 = depthForTripleFocus(img1, img2, img3);

% Blur background:
% ---------------
% get background.
background = (1-depthMap3).*img1;
% add highlight:
background = highlight(background, 1.1);
% blur.


backgroundTop = pyramidBlur(background);
backgroundTop = pyramidBlur(backgroundTop);
% fix black (hole) diffusion.

backgroundBottom = pyramidBlur(1-depthMap3);
backgroundBottom = pyramidBlur(backgroundBottom);

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
% imwrite(img1,'dogOriginal.jpg')
% 
% imwrite(finalImage,'dogResult.jpg')

's';