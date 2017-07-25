function [featuresForAllPatches, propsForAllPatches] = prepForKnn(segData, exclude, showStats)

  %% create two parallel matrices, of features and target values
  %%  for the first: concatenate all segments' patches then add temporals
  %%  for the second: repmat and conatenate properties for each segment
  %% exclude is the number of a segment to exclude, if any (for leave-one-out testing)
  %% similar to Jason's buildRegTrainingData
  %% Nigel Ward and Ivan Gris, UTEP, June 2017
  %% see ../doc/UTEP-prosody-overview.docx
  
  featuresForAllPatches = concatenateFeatures(segData, exclude);
  nPatchesSoFar = 0;  
  for i = 1:length(segData)
    if ismember(i, exclude)
      continue
    end
    segment = segData{i};
    pfeatures = segment.features;
    nPatchesInSegment = size(pfeatures,1);
    firstRow = nPatchesSoFar + 1;
    lastRow = nPatchesSoFar + nPatchesInSegment;
    repeatedProperties = repmat(segment.properties, nPatchesInSegment, 1);
    propsForAllPatches(firstRow:lastRow, :) = repeatedProperties;
    nPatchesSoFar = lastRow;
  end
  if showStats
    fprintf(' prepForKnn: %d segments, %d patches, %.1f seconds, %.1f minutes\n', ...
	    length(segData), nPatchesSoFar, nPatchesSoFar / 10, nPatchesSoFar / 600);
  end
end

