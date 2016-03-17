function [ImageArray]=read_focus_bracket(basefolder, subfolderName, filetype)
% assumes given subfolder contains a burst sequence of variable length

if ~exist('filetype','var')
    filetype='jpg';
end

files = dir(fullfile(basefolder, subfolderName, ['*.' filetype]));
Nimages = length(files);
if ~Nimages
  error('There are no images in the folder %s', ...
    fullfile(basefolder, subfolderName));
end
iminfo = imfinfo(fullfile(basefolder, subfolderName, files(1).name));
if isfield(iminfo, 'Orientation') && iminfo.Orientation > 4
  ImageArray = nan(iminfo.Width, iminfo.Height, ...
    iminfo.NumberOfSamples,Nimages);
else
  ImageArray = nan(iminfo.Height, iminfo.Width, ...
    iminfo.NumberOfSamples,Nimages);
end
for j = 1:Nimages
  ImageArray(:,:,:,j) = ...
    imreadAutoRot(fullfile(basefolder, subfolderName, files(j).name));
end

end