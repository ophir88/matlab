function [names]=read_subfolders(folder)
% assumes given folders has subfolders, each containing a set of images

subfolders = dir(folder);
index = 1;
for j = 1:length(subfolders)
  if ~subfolders(j).isdir || subfolders(j).name(1) == '.'
    continue
  end
  names{index,1} = subfolders(j).name;
  index = index + 1;
end

end