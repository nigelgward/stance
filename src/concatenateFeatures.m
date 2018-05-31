function allpatches = concatenateFeatures(segInfo, exclude)

  firstSegment = segInfo{1};
  nfeatures = size(firstSegment.features,2);
  nTotalPatches = computeNtotalPatches(segInfo, exclude);
  %% pre-allocate what we need; important for speed in the leave-one-out case
  allpatches = zeros(nTotalPatches, nfeatures);   

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
    
