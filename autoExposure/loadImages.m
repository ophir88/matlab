function [ imgs ] = loadImages( foldername , imgType )
%LOADIMAGES Summary of this function goes here
%   Detailed explanation goes here

Imgs = dir([foldername '/']);
    NumImgs = size(Imgs,1);
    image = double(imreadAutoRot([foldername '/' Imgs(4).name]));
    X = zeros([NumImgs size(image)]);
    for i=4:NumImgs,
      image = im2double(imreadAutoRot([foldername '/' Imgs(i).name]));
      imgs{i-3}=image;
    end
end

    