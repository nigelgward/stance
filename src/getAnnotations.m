function [propertyValues, propertyNames] = getAnnotations(annotationDir)

  %% Nigel Ward, UTEP, June 2017
  %% propertyValues is a cell array, one cell per news segment
  %%  where each cell is a struct, including: propvec, start, broadcast
  %% this function essentiall just reformats flat arrays into an array of structs

  if isUtepAnnotationDir(annotationDir)
  [vals, ~, segStarts, ~, segUrls, propertyNames] = readStanceAnnotations([annotationDir '/']);
    nsegments = size(segStarts,2);
    segStructs = cell(nsegments,1);

    for i = 1:nsegments
      segStructs{i}.properties = vals(i,:);
      segStructs{i}.starts = segStarts(i);
      segStructs{i}.broadcast = segUrls(i);
    end
    propertyValues = segStructs;
  else 
    error('LDC corpus workflow not yet implemented\n');
  end
end


%%------------------------------------------------------------------
function result = isUtepAnnotationDir(audioDir)
  result = length(csvfilesInToplevelDirectory(audioDir)) > 0;
end

%------------------------------------------------------------------
function filenames = csvfilesInToplevelDirectory(dirname)
  filenames = {};
  files = dir(dirname);
  for i = 1:length(files);
    filename = files(i).name;
    if strfind(filename, 'csv')
      filenames{end+1} = filename;
    end
  end
end
