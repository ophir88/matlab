function [ depth ] = depthForTripleFocus( img1,img2)
%DEPTHFORCOUPLEFOCUS Summary of this function goes here
%   Detailed explanation goes here

% %% segmentation
% ratio = 1;
% kernelsize = 3;
% maxdist = 8;
% [Iseg, lables] = vl_quickseg(img1, ratio, kernelsize, maxdist);
% [Iseg2, lables2] = vl_quickseg(img2, ratio, kernelsize, maxdist);

%% Modified Laplacian maps.
[r,c,d] = size(img1);

h = [-1 2 -1];

img1Gray = rgb2gray(img1);
img2Gray = rgb2gray(img2);

img1Laplace = abs(imfilter(img1Gray,h,'replicate'))+abs(imfilter(img1Gray,h','replicate'));
img2Laplace = abs(imfilter(img2Gray,h,'replicate'))+abs(imfilter(img2Gray,h','replicate'));
% %% Laplacian map mean for each segment
% maxLabel1 = max(max(lables));
% maxLabel2 = max(max(lables2));
% % For each lable group, we find the mean luminance, and set the whole
% % segment to it's matching LUT value.
% mean1 = zeros(r,c);
% mean2 = zeros(r,c);
% for i = 0: maxLabel1
%     indexs = (lables == i);
%     numOfInd = sum(sum(indexs));
%     if(numOfInd > 0 )
%         mean1(indexs) = mean(mean(img1Laplace(indexs)));
%     end
% end
% for i = 0: maxLabel2
%     indexs = (lables2 == i);
%     numOfInd = sum(sum(indexs));
%     if(numOfInd > 0 )
%         mean2(indexs) = mean(mean(img2Laplace(indexs)));
%
%
%     end
% end

% % %% WLS for the segmented means, according to the reference segmentation
% % depth1W = wlsFilter(mean1, 1.5, 1.2, rgb2gray(Iseg));
% % depth2W = wlsFilter(mean2, 1.5, 1.2, rgb2gray(Iseg));
% % depth = depth1W./depth2W;
%
% %% Normalize and run through sigmoid
% normalizedDepth = normalize(depth);
% normalizedDepth = remapInterpolation(normalizedDepth,2 , 1.4);
% figure; imshow(normalizedDepth);
% depth3 = repmat(normalizedDepth, [1,1,3]);
%% BLF
dim = size(img1Laplace);
B1 = zeros(dim);
B2 = zeros(dim);

w = 3;
sigma_d = 2;
sigma_r = 0.05;
iterations = 130;
C = ((img1Gray));
[X,Y] = meshgrid(-w:w,-w:w);
G = exp(-(X.^2+Y.^2)/(2*sigma_d^2));
source1 = img1Laplace;
source2 = img2Laplace;

for iteration = 1 : iterations
    iteration
    for i  = 1 : r
        for j = 1 : c
            
            
            % Extract local region.
            iMin = max(i-w,1);
            iMax = min(i+w,dim(1));
            jMin = max(j-w,1);
            jMax = min(j+w,dim(2));
            I1 = source1(iMin:iMax,jMin:jMax);
            I2 = source2(iMin:iMax,jMin:jMax);
            
            % To compute weights from the color image
            J = C(iMin:iMax,jMin:jMax);
            
            % Compute Gaussian intensity weights according to the color image
            H = exp(-(J-C(i,j)).^2/(2*sigma_r^2));
            
            % Calculate bilateral filter response.
            F = H.*G((iMin:iMax)-i+w+1,(jMin:jMax)-j+w+1);
            B1(i,j) = sum(F(:).*I1(:))/sum(F(:));
            B2(i,j) = sum(F(:).*I2(:))/sum(F(:));
            
        end
    end
    source1 = B1;
    source2 = B2;
    
end


%% WLS for the segmented means, according to the reference segmentation
depth3W = wlsFilter(img1Laplace, 2, 1.3, rgb2gray(img1));
depth4W = wlsFilter(img2Laplace, 2, 1.3, rgb2gray(img1));
depth = depth3W./depth4W;

%% Normalize and run through sigmoid
normalizedDepth2 = normalize(depth);
normalizedDepth2 = remapInterpolation(normalizedDepth2,1 , 1.6);
figure; imshow(normalizedDepth2);
depth2 = repmat(normalizedDepth2, [1,1,3]);

end

