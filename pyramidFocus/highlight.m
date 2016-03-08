function [ output ] = highlight( input, amount )
%HIGHLIGHT Summary of this function goes here
%   Detailed explanation goes here

imgNTSC = rgb2ntsc(input);
imgNTSCY = imgNTSC(:,:,1);
lightIdx = imgNTSCY > 0.8;
imgNTSCY(lightIdx) = imgNTSCY(lightIdx)*amount;
imgNTSC(:,:,1) = imgNTSCY;
output = ntsc2rgb(imgNTSC);

end

