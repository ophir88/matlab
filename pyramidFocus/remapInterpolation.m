function [ y ] = remapInterpolation( inputImg , addedShift, slant )
%REMAPINTERPOLATION Summary of this function goes here
%   Detailed explanation goes here


if ~exist('addedShift','var')
    addedShift = 0;
end
if ~exist('slant','var')
    slant = 1.8;
end
% shift = x- 0.5;
% transition = 1 - ((transition+0.01)/1.01)^0.15;
% y = shift ./ (transition + abs(shift)) ./ (0.5 / (transition + 0.5)) * 0.5 + 0.5;
[N , M , D] =size(inputImg);
sorted = sort(inputImg);
medianVal = median(median(sorted(floor(N*0.2):floor(N*0.8), floor(M*(0.2):floor(M*0.8)))));
medianVal = medianVal*10;
shiftValue = (5-medianVal);

inputImg = inputImg.*10 -5;
y = 1./(1+exp(-(1.5*(shiftValue+addedShift)+slant.*(inputImg))));

end

