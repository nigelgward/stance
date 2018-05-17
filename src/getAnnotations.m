%% Nigel Ward, UTEP, June 2017
%% propertyValues is a cell array, one cell per news segment
%%  where each cell is a struct, including: propvec, start, broadcast
%% this function essentially just reformats flat arrays into an array of structs

function [propertyValues, propertyNames] = getAnnotations(audioDir, annotDir)

  csvfiles = filesWithExtension(annotDir, 'csv');
  if (length(csvfiles) > 0)
    %% then it's UTEP format 
    [vals, ~, segStarts, ~, segUrls, propertyNames] = readStanceAnnotations([annotDir '/']);
    nsegments = size(segStarts,2);
    segStructs = cell(nsegments,1);
    
    for i = 1:nsegments
      segStructs{i}.props = vals(i,:);
      segStructs{i}.starts = segStarts(i);
      segStructs{i}.broadcast = segUrls(i);
    end
  else
    [presence, propertyNames] = readSFannotations(annotDir);
    [starts, ends, aufilenames] = getSegInfo(audioDir, annotDir);
    nsegments = size(presence, 1);
    if nsegments ~= size(starts, 2);
      error('getAnnotations, size mismatch: %d %d', nsegments, size(starts, 1));
    end
    segStructs = cell(nsegments,1);
    for i = 1:nsegments
      segStructs{i}.props = presence(i,:);
      segStructs{i}.starts = starts(i);
      filenameWithExtension = aufilenames{i};  % prepare to strip off .au
      segStructs{i}.broadcast = filenameWithExtension(1:end-3); % not sure where used
    end
  end
  propertyValues = segStructs;  
end

%% to test
%%   cd stance/testeng
%%   regressionTest()
%% or
%%   cd sframes;
%%   getAnnotations('annot-testdir');



