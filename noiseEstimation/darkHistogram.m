function [ stds ] = darkHistogram( imgs )
%DARKHISTOGRAM Summary of this function goes here
%   Detailed explanation goes here

% histograms = {};
% histograms = {};
stds = zeros(length(imgs), 3);
for i = 1 : length(imgs)
    img = imgs{i};
    [r, c, d] = size(img);
    
    imgSegmented = double(segmentImg(img) + 1)/10;
    imgSegmented = imresize(imgSegmented, [r c]);
    
    indx = imgSegmented==0.1;
    %     imgG = img;
    %     imgG = imgradient(rgb2gray(imgG));
    %     imgG(~indx)=0;
    imgHSV = rgb2hsv(img);
    imgH = imgHSV(:,:,1);
    imgS = imgHSV(:,:,2);
    imgV = imgHSV(:,:,3);
    
    valuesH = imgH(indx);
    valuesS = imgS(indx);
    valuesV = imgV(indx);
%     histogram = zeros(200,3);
%     histogram(:,1) = hist(valuesH, 200);
%     histogram(:,2) = hist(valuesS, 200);
%     histogram(:,3) = hist(valuesV, 200);
%     histograms{i} = histogram;
    %     h = histogram(values);
    %     histograms{i} = h;
    %     %     meanF = mean(values(:));
        stds(i,1) = var(valuesH);
        stds(i,2) = var(valuesS);
        stds(i,3) = var(valuesV);
%         stds(i,4) = (stds(i,1)+stds(i,2))/stds(i,3);
    %     if(stds(i,4)>7)
    %         's';
    %     end
    
end

end

