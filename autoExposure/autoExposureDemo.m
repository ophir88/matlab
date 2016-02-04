imgs = loadImages('./photos');

close all;
for i = 1 : length(imgs)
   img = imgs{i};
   imgResult = autoExpos(img);
    figure;
    subplot(1,2,1);
    imshow(img);
    title('Original');
    subplot(1,2,2);
    imshow(imgResult);
    title('Result');
end
's';