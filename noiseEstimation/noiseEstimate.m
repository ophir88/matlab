
% Load images
lowImgs = loadImages('./photos/low');
regImgs = loadImages('./photos/reg');

%% get standart derivation
lowStds = stdOfDarkAreas(lowImgs);
regStds = stdOfDarkAreas(regImgs);

%% do something with it