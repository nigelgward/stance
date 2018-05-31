%% show locations of nearest neighbors

%% call from inside prosprop, after prepForKnn is done 

function examineNeighbors(stride, reference)

  %% ideally could specify the filename the query is from, 
  %% for now this only works for the first file

  %% querying things that seem to mark urgent/ongoing/unresolved
  %% in the first audio, which is labeled urgent
  %% and recording what they match, ignoring points next to the query
  queryTimepoint = 6.2;  % seconds: pouring into our state
  %% matches "inability to manage our forests" ongoing situation
  %% also both have a dramatic rhythm
  queryTimepoint = 17;  % seconds: and is only 10% contained
  %% the view from Penguich Lake (nasal, complainy, lengthened, stressed)
  queryTimepoint = 3.5;  % seconds: largest wildfire and no end in sight
  %% matches 19.1, same file, more than 1900 fire crews
  %% dramatic pause, large magnitude 
  %% matches 216, which is 50 mins into audio 4:
  %% blame it on two things: the bark beetle*, and environmental groups
  queryTimepoint = 3.0;  % still no end in sight
  %% matches firefighters pouring into our state 
  %% this fire began, *and spread*, on no-federal land blaming, emphasizing
  queryTimepoint = 7.0;  % pouring into our state 
  %% flare ups, causing even more flames: dramatic
  %% when we turn the Forest Service, over to the bunny lovers; dramatic, blame

  %% conclusion 1: it seems to be working properly
  %% conclusion 2: the prosody of urgency/excitement is often misused
  %%   especially late in broadcasts, where it's recriminations and background,
  %%   not facts and current news
  %% conclusion 3: urgency is often not explicit but implied, e.g by magnitude


  queryIndex = floor(queryTimepoint * (1000. / stride));
  queryVec = reference(queryIndex,:);

  refStride = 100;  % hardcoded in makePPM.

  nNeighbors = 5;
  [neighbors, distances] = knnsearch(reference, queryVec, 'K', nNeighbors);
  fprintf('out of %d rows, the closest neighbors of row %d were:\n', ...
	  size(reference, 1), queryIndex);

  for i = 1:nNeighbors
    fprintf('   index %4d, offset %.2fs (distance %.2f)\n', ...
	     neighbors(i), neighbors(i) * 0.1, distances(i));
  end
  fprintf('\n');
  
end

 
