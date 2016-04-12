function [ imgs ] = loadImages( foldername , imgType )
%LOADIMAGES Summary of this function goes here
%   Detailed explanation goes here

Imgs = dir([foldername '/']);
    NumImgs = size(Imgs,1);
    image = double(imreadAutoRot([foldername '/' Imgs(4).name]));
    X = zeros([NumImgs size(image)]);
    for i=4:NumImgs,
      image = im2double(imreadAutoRot([foldername '/' Imgs(i).name]));
      [R,C,d] = size(image);
    maxSize = max(R,C);
    aspect = maxSize / 500;
    image = imresize(image, 1/ aspect);
      imgs{i-3}=image;
    end
end

    