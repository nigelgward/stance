function segData = prosodizeCorpus(audioDir, annotDir, featurespec, stride)

  %% Nigel Ward, UTEP, June 2017
  %% creates a nice data structure representing the prosodic information etc.
  %% This data structure is the 
  %% inputs: audioDir, varies in format, UTEP or LDC
  %%         annotDir, ditto.  this function uses this only for 
  %%            the news-segment boundaries, and for UTEP-format audio 
  %%         featurespec
  %%         stride: time between patches, in milliseconds
  %% output: prosodized is cell array of structures
  %%       this is segmentData format, see ../doc/UTEP-prosody-overview.docx
  %%       This function does not add props (annotation info); 
  % %        since that is added later if needed.
  %%       Notice also that the output is not z-normalized; that's done later
  %% test with x = prosodizeCorpus('testAudio', 'testAnnotations', ...
  %%      getfeaturespec('src/mono4.fss');
  %%   and then examine x{1}, x{2}, etc.

  [starts, ends, aufiles] = getSegInfo(audioDir, annotDir);

  nsegments = length(starts);
  segData = cell(nsegments,1);
  for i = 1:nsegments
    segfeatures = featuresForSegment(aufiles{i}, starts(i), ends(i), ...
				     featurespec, audioDir, stride);
    %% Converting to single saves diskspace for ppmfiles, maybe time too,
    %%   and gives the same answers, but it causes annoying warnings
    %%   when running knnsearch, so for now we don't do it
    %% segfeatures = single(segfeatures);    
    segData{i}.features = addTemporalFeatures(segfeatures, stride);  
    segData{i}.startTime = starts(i);
    segData{i}.endtTime = ends(i);
    segData{i}.broadcastName = aufiles{i};
    segData{i}.properties = [];    % empty, possibly added later
  end
end
  

%----------------------------------------------------------------------------
%% input: matrix of features, one every 100 ms
%% output: same, plus two new columns for temporal features
%% this function replaces Jason's addTimeFeatures
function augmentedFeatures = addTemporalFeatures(features, stride)
  timeBetweenPatches = .001 * stride;   % seconds
  npatches = size(features, 1);
  segmentDuration = npatches * timeBetweenPatches;
  timesSinceStart = (-.050 + (1:npatches) * timeBetweenPatches)';
  timesUntilEnd = segmentDuration - timesSinceStart;
  augmentedFeatures = [features log(timesSinceStart) log(timesUntilEnd)];
end


%------------------------------------------------------------------
function features = featuresForSegment(aufile, startTime, endTime, ...
				       featurespec, audioDir, stride)
  aufile = char(aufile);
  monster = findTrackMonster(aufile, audioDir, featurespec);
  framesPerSecond = 100;    % what makeTrackMonster returns 
  startFrame = max(1, floor(startTime * framesPerSecond));
  endFrame = floor(endTime * framesPerSecond);
  endFrame = twiddleEndFrame(aufile, startFrame, endFrame, size(monster,1));
			     
  %%fprintf('startFrame %d, endFrame %d, size(monster) %d, %d\n', ...
  %%  startFrame, endFrame, size(monster));
  segmentFrames = monster(startFrame:endFrame,:);
  downsamplingRate = stride / 10;
  features = segmentFrames(1:downsamplingRate:end, :);          
end


%%------------------------------------------------------------------
function newEndFrame = twiddleEndFrame(aufile, segStartFrame, segEndFrame, monsterEndFrame)
  newEndFrame = segEndFrame;     % the normal case
  if segEndFrame == 0
    newEndFrame = monsterEndFrame;
    if newEndFrame > segStartFrame + (200 * 100)    % 200 seconds
      fprintf('!!warning very long for %s: frames %f to %f!?\n', ...
	      aufile, segStartFrame, segEndFrame);
    end
  end
  if segEndFrame > monsterEndFrame
	 newEndFrame = monsterEndFrame;
	 if segEndFrame > monsterEndFrame + (0.5 * 100)  % half a second
	   fprintf('!!warning too short for %s: frames %f to %f!?\n', ...
		   aufile, startFrame, endFrame);
    end
  end
end


%------------------------------------------------------------------
%% lookup saved prosodic features in cache or compute them
function monster = findTrackMonster(base, dir, featurespec)
  persistent savedMonsters;   
  persistent nSavedMonsters;

  file = [base, '.au'];

  if length(nSavedMonsters) == 0   % then it's the first call 
    nSavedMonsters = 0;
    savedMonsters = struct('file', {}, 'monster',{});
  end
  
  for i = 1:nSavedMonsters
    saved = savedMonsters(i);
    if strcmp(file, saved.file);
      %% should test that the saved monster was created with same
      %% featurespec fprintf ('using cached features for %s\n', file);
      monster = saved.monster;
      return;
    end
  end
  trackspec = makeTrackspec('l', file, [dir '/']);
  %% might instead use Ivan's slimmed version of makeTrackMonster or
  %% evalc
  if isnumeric(featurespec) && featurespec == 0
    newMonster = frameLevelFeatures(trackspec);
  else
    [~, newMonster] = makeTrackMonster(trackspec, featurespec);
  end
  nSavedMonsters = nSavedMonsters + 1;
  savedMonsters(nSavedMonsters).monster = newMonster;
  savedMonsters(nSavedMonsters).file = file;
  monster = newMonster;
end


%% test with
%% cd ppm/testeng   or small-turkish etc. 
%%   prosodizeCorpus('audio', 'annotations', getfeaturespec('../src/mono4.fss'), 100);


