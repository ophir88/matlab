function [ finalImg ] = pyramidBlur( img, depthMaps )
%PYRAMIDBLUE Summary of this function goes here
%   Detailed explanation goes here

pyr = genPyr(img,'laplace',4);
pyrFinal = {};
pyrFinal{length(pyr)} = pyr{length(pyr)};
% [r,c,d] = size(pyr2{3});
for pyrNum = 1 : length(pyr)-1
    pyrFinal{pyrNum} = real(pyr{pyrNum}.*depthMaps{pyrNum});
end
finalImg = pyrReconstruct(pyrFinal);

end

