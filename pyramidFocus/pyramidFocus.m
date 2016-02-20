img1 = im2double( imread('./photos/flower/IMG_0319.jpg'));
img2 = im2double(imread('./photos/flower/IMG_0322.jpg'));
img1 = imresize(img1,0.4);
img2 = imresize(img2,0.4);
[r,c,d] = size(img2);
close all;
imgs = {};
figure; imshow(img1);
% imwrite(img1,'mouseOriginal.jpg')

% imgZeroPadded = zeros(size(img1));
% imgZeroPadded(360:670,1:370,:) = img1(360:670,1:370,:);
% figure; imshow(imgZeroPadded);

imgs{1} = img1;
imgs{2} = img2;
imgsTransformed = sift_estimate_transformation(imgs);
% figure; imshow(img2);
[WIMAGE, SUPPORT] = iat_inverse_warping(img2, imgsTransformed{2}.T, 'homography', 1:c, 1:r);
% figure; imshow(WIMAGE);
% 
% figure;imshowpair(WIMAGE,img2,'diff');
% figure; imshowpair(WIMAGE,img1,'diff');

% imshowpair(WIMAGE,img2);
% imshowpair(WIMAGE,img1);

pyr1 = genPyr(img1,'laplace',4);
% 
% figure; imshow(pyr1{1});
% figure; imshow(pyr1{4});

pyr2 = genPyr(WIMAGE,'laplace',4);
pyrFinal = {};
pyrFinal{4} = pyr1{4};
imgSmall1 = pyr1{3};
imgSmall2 = pyr2{3};

[r,c,d] = size(pyr2{3});
for pyrNum = 1 : 3
    [r,c,d] = size(pyr2{pyrNum});
    H = fspecial('disk',50/pyrNum);
    imgSmall = zeros(size(pyr2{pyrNum}));
    imgSmall1 = imgradient(rgb2gray( pyr1{pyrNum}));
     imgSmall2 = imgradient(rgb2gray(pyr2{pyrNum}));
         imgSmall1 = imfilter(imgSmall1,H,'replicate');
         imgSmall2 = imfilter(imgSmall2,H,'replicate');

%      figure; imshow(imgSmall1);
%     figure; imshow(imgSmall2);
%     imgSmallBinary2 = zeros(size(imgSmall1));
%     imgSmallBinary2(imgSmall2>imgSmall1)  = 1;
%     figure; imshow(imgSmallBinary2);
    imgSmallBinary = (imgSmall2 - imgSmall1);
    imgSmallBinary = imgSmallBinary - min(min(imgSmallBinary));
    imgSmallBinary = 1 - imgSmallBinary / (max(max(imgSmallBinary)));
    sorted = sort(reshape(imgSmallBinary,[],1), 'descend');
    minVal = mean(sorted(round(length(sorted)*90/100):length(sorted)));
%     imgSmallBinary
    imgSmallBinary = (imgSmallBinary - minVal);
     sorted = sort(reshape(imgSmallBinary,[],1), 'descend');
    maxVal = mean(sorted(1:round(length(sorted)*20/100)));
    imgSmallBinary = imgSmallBinary/ maxVal;

    
    imgSmallBinary(imgSmallBinary>1) = 1;
%      figure; imshow(imgSmallBinary);
     original = pyr1{pyrNum};
    for i = 1 : r
        for j = 1 : c
%             if (imgSmall2(i,j) > imgSmall1(i,j))
%                 imgSmall(i,j,:) = original(i,j,:)*(2/(1+exp(-((imgSmallBinary(i,j))-1)*6))) ;
                imgSmall(i,j,:) = original(i,j,:)*imgSmallBinary(i,j)^(4-pyrNum) ;
%                 imgSmall(i,j,:) = 0 ;


%             else
%                 imgSmall(i,j,:) = original(i,j,:);
%             end
        end
    end
    pyrFinal{pyrNum} = imgSmall;

end
%     pyrFinal{pyrNum+1} = pyr1{pyrNum+1};

%     pyrFinal{pyrNum+2} = pyr1{pyrNum+2};

finalImg = pyrReconstruct(pyrFinal);
figure; imshow(finalImg);

% imwrite(finalImg,'mouseResult.jpg')

's';