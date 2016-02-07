imgs = loadImages('./photos');

close all;
for i = 1 : length(imgs)
   img = imgs{i};
   imgResult = autoExpos(img);
   imgExposed = img * 2 ^(0.3);
    fig = figure;
    subplot(1,3,1);
    imshow(img);
    title('Original');
    subplot(1,3,3);
    imshow(imgResult);
    title('Result');
        subplot(1,3,2);

     imshow(imgExposed);
    title('Naive exposure');
%     name = ['result' num2str(i)];
% 
%     print(fig,name,'-dpng')

end
's';