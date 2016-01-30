function [ shadow, highlight ] = shadowAndHighlight( img, segmentedImg, numOfZones , newE )
%SCURVE Summary of this function goes here
%   Detailed explanation goes here

% E' = E + sh * fd = > sum(I')/s = sum(I)/s + sh*sum(fd(I)) =>
% sum(I')/s - sum(I)/s = sh*sum(fd(I))/s
% (E'-E)*S / sum(fd(I)) = sh

[rows,cols,d] = size(img);
imgSize = rows * cols;
shadow = zeros(numOfZones,1);
highlight = zeros(numOfZones,1);

for i = 1 : numOfZones
    region = img(find(segmentedImg == i - 1));
    regionSize = sum(sum(segmentedImg == i - 1));

    meanPre = sum(region)/regionSize;
    meanPost = sum(region * 2^(newE(i)/10))/regionSize;
    eDiff = meanPost - meanPre;
    fdValuesShadow = fd(img(find(segmentedImg == i - 1)));
    fdValuesHighlight = fd(1 - img(find(segmentedImg == i - 1)));
    shadow(i) = eDiff * regionSize / sum(fdValuesShadow);
    highlight(i) = eDiff * regionSize / sum( fdValuesHighlight);
end
shadow = sum(shadow(1:6))/4;
highlight = sum(highlight(7:11))/5;
end


function [incremented] = fd(values)
k1 = 5;
k2 = 14;
k3 = 1.6;
incremented = k1 .* values .* exp (-k2 .*( values .^ k3));
end