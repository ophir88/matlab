function [ stds, histograms ] = stdOfDarkAreas( imgs )
%STDOFDARKAREAS Summary of this function goes here
%   Detailed explanation goes here

stds = zeros(length(imgs),1);
% histograms = {};
for i = 1 : length(imgs)
    img = imgs{i};
    [r, c, d] = size(img);
    
    imgSegmented = double(segmentImg(img) + 1)/10;
    imgSegmented = imresize(imgSegmented, [r c]);
    
    indx = imgSegmented<0.6;
    imgHSV = rgb2hsv(img);
    imgH = imgHSV(:,:,1);
    values = imgH(indx);
%     h = histogram(values);
%     histograms{i} = h;
%     meanF = mean(values(:));
    stds(i,1) = AjaNE(values,500);
end

end

