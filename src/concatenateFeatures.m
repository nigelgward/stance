function allpatches = concatenateFeatures(segInfo, exclude)
  nPatchesSoFar = 0;

  for i = 1:length(segInfo)
    if i == exclude
      continue
    end
    segment = segInfo{i};
    pfeatures = segment.features;
    nPatchesInSegment = size(pfeatures,1);
    firstRow = nPatchesSoFar + 1;
    lastRow = nPatchesSoFar + nPatchesInSegment;
    allpatches(firstRow:lastRow, :) = pfeatures;
    nPatchesSoFar = lastRow;
  end
end
    
