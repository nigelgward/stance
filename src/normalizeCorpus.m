%% Nigel Ward, UTEP, June 2017

%% for each segment in the corpus, z-normalize each prosodic feature

function corpus = normalizeCorpus(corpus, means, stddevs)
  for i = 1:length(corpus)
    segment = corpus{i};
    segment.features = normalizeSegmentPatches(segment.features, means, stddevs);
  end
end

function normalized = normalizeSegmentPatches(features, means, stddevs)
  npatches = size(features,1);
  nfeatures = size(features, 2);
  normalized = zeros(npatches, nfeatures);
  for f = 1:nfeatures
    normalized(:, f) = ((features(:,f) - means(f) ) / std(f) );
  end
end

  
