
%% compute how much space to allocate, then allocate it all at once, to save time
function nTotalPatches = computeNtotalPatches(segInfo, exclude)
  nTotalPatches = 0;
  for i = 1:length(segInfo)
    if i == exclude
      continue
    end
    segment = segInfo{i};
    pfeatures = segment.features;
    nPatchesInSegment = size(pfeatures,1);
    nTotalPatches = nTotalPatches + nPatchesInSegment;
  end
  %%fprintf('for leave-one-out on segment %d, nTotalPatches is %d\n', exclude, nTotalPatches);
end
