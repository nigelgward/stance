%% returns a cell array of filenames
function filenames = filesWithExtension(dirname, extension)
  filenames = {};
  files = dir(dirname);
  for i = 1:length(files);
    filename = files(i).name;
    if strfind(filename, extension)
      filenames{end+1} = filename;
    end
  end
end
