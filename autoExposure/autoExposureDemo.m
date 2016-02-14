imgs = loadImages('./photos');

close all;
for i = 1 : length(imgs)
    img = imgs{i};
    imHistResult = autoCurve(img);
    imgResultQuick = autoExpose2(img);
    
    imgResult = autoExpos(img);
    fig = figure;
    subplot(2,2,1);
    imshow(img);
    title('Original');
    subplot(2,2,3);
    imshow(imgResult);
    title('Result');
    subplot(2,2,2);
    imshow(imHistResult);
    title('hist equalization');
    subplot(2,2,4);
    imshow(imgResultQuick);
    title('quick result');
    %     name = ['result' num2str(i)];
    %
    %     print(fig,name,'-dpng')
    
end
's';