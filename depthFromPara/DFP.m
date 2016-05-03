%%Load and align:
img1 = im2double(imread('./photos/mouse/1.jpg'));
img2 = im2double(imread('./photos/mouse/2.jpg'));
img3 = im2double(imread('./photos/mouse/3.jpg'));

% Resize:
% -------

% img1 = imresize(Iwarped(:,:,:,1) ,0.4);
% img2 = imresize(Iwarped(:,:,:,2),0.4);
% img3 = imresize(Iwarped(:,:,:,3),0.4);

img1 = imresize(img1 ,0.3);
img2 = imresize(img2,0.3);
img3 = imresize(img3,0.3);
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
img1G = rgb2gray(img1);
img2G = rgb2gray(img2);
img3G = rgb2gray(img3);

combined = (img1 + img2 + img3)./3;
combinedG = (img1G + img2G + img3G)./3;
%%
minusImg1 = abs(img2G-img1G);
minusImgGrad1 = imgradient(minusImg1);
minusImg2 = abs(img3G-img1G);
minusImgGrad2 = imgradient(minusImg2);
figure(1); imshow(minusImgGrad1);
figure(2); imshow(minusImgGrad2);
figure(3); imshow(minusImgGrad1.*minusImgGrad2);

%%
final = zeros(r,c);
for i = 19 : 9 : r-9
    for j = 19 : 9 : c - 9
        roi1 = img1(i-9:i, j-9:j);
        error = 1000;
        shiftRow = 0;
        shiftCol = 0;
        for l = -9 : 1 : 9
            for m = - 9 : 1 :9
                roi2 = img2(i-9+l : i+l, j-9+m : j+m);
                D = abs(roi1-roi2).^2;
                MSE = sum(D(:))/numel(roi1);
                if (MSE < error)
                    error = MSE;
                    shiftRow = l;
                    shiftCol = m;
                end
            end
        end
        final(i-9:i, j-9:j) = (2*shiftRow^2 + shiftCol^2).^(1/2);
    end
end