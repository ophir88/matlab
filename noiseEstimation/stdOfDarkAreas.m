function [ stds, histograms ] = stdOfDarkAreas( imgs )
%STDOFDARKAREAS Summary of this function goes here
%   Detailed explanation goes here

stds = zeros(length(imgs),4);
% histograms = {};
for i = 1 : length(imgs)
    img = imgs{i};
    [r, c, d] = size(img);
    
    imgSegmented = double(segmentImg(img) + 1)/10;
    imgSegmented = imresize(imgSegmented, [r c]);
    
    indx = imgSegmented<0.4;
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
    
    %     h = histogram(values);
    %     histograms{i} = h;
    %     meanF = mean(values(:));
    stds(i,1) = var(valuesH);
    stds(i,2) = var(valuesS);
    stds(i,3) = var(valuesV);
    stds(i,4) = (stds(i,1)+stds(i,2))/stds(i,3);
    if(stds(i,4)>7)
        's';
    end

end

end

