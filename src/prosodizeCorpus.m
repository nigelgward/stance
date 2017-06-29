function prosodized = prosodizeCorpus(audioDir, annotDir, featurespec, stride)

  %% Nigel Ward, UTEP, June 2017
  %% creates a nice data structure representing the prosodic information etc.
  %% This data structure is the 
  %% inputs: audioDir, varies in format, UTEP or LDC
  %%         annotDir, ditto.  here only used to get the news-segment
  %%           boundaries, and only for the UTEP-format audio data
  %%         featurespec
  %%         stride: time between patches, in milliseconds
  %% output: prosodized is cell array of structures
  %%       this is segmentData format, see ../doc/UTEP-prosody-overview.docx
  %%       Except that there is no props (no annotation info); 
  %%        since that is  added later if needed.
  %%       Notice also that the output is not z-normalized; that's done later
  %% test with x = prosodizeCorpus('testAudio', 'testAnnotations', ...
  %%      getfeaturespec('src/mono4.fss');
  %%   and then examine x{1}, x{2}, etc.

  if isUtepFormat(audioDir)
    prosodized = prosodizeUtepCorpus(audioDir, annotDir, featurespec, stride);
  else 
    prosodized = prosodizeLdcCorpus(audioDir, featurespec, stride);
  end
end

%%------------------------------------------------------------------
function result = isUtepFormat(audioDir)
  result = length(aufilesInToplevelDirectory(audioDir)) > 0;
end

%%------------------------------------------------------------------
function prosodized = prosodizeUtepCorpus(audioDir, annotDir, featurespec, stride)
  [starts, ends, aufiles] = segmentLocs(annotDir);
  nsegments = length(starts);
  segData = cell(nsegments,1);
  for i = 1:nsegments
    segfeatures = featuresForSegment(aufiles{i}, starts(i), ends(i), ...
				     featurespec, audioDir, stride);
    segData{i}.features = addTemporalFeatures(segfeatures, stride);  
    segData{i}.startTime = starts(i);
    segData{i}.endtTime = ends(i);
    segData{i}.broadcastName = aufiles{i};
    segData{i}.properties = [];    % empty, possibly added later
  end
  prosodized = segData;
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
  if endFrame == 0
    endFrame = size(monster,1);
    if endFrame > startFrame + (200 * 100)    % 200 seconds is probably excessive
      fprintf('!!warning very long for %s: frames %f to %f!?\n', ...
	      aufile, startFrame, endFrame);
    end
  end
  %%fprintf('startFrame %d, endFrame %d, size(monster) %d, %d\n', ...
  %%  startFrame, endFrame, size(monster));
  segmentFrames = monster(startFrame:endFrame,:);
  downsamplingRate = stride / 10;
  features = segmentFrames(1:downsamplingRate:end, :);          
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


%------------------------------------------------------------------
function filenames = aufilesInToplevelDirectory(dirname)
  filenames = filesWithExtension(dirname, '.au');
end
 

%==================================================================

%% Universally our task involves news segments within broadcasts,
%%  but there are two formats for this 
%% LDC/Appen delivers each segment as a file, with broadcast provenance
%%  indicated by the directory structure and filenames
%% UTEP has each broadcast in a file, with
%%  segment start/end times indicated by a csv file 
%% In the past for LDC/Appen data, we've processed each file individually,
%%  but this loses information, particularly the normalization parameters
%%  and valid prosodic features at segment start/end.
%%  So we need a better solution.  

%% (There's a similar issue in the diversity of annotation formats: SoS, vs
%%  Appen, and within Appen, stance vs situation frames, but that's another
%%  function)

%% typical LDC/Appen path: IL3_EVAL_AUDIO/001/audio/IL3_EVAL_001_001.flac 
%% so we need to
%% sox  %% 001/audio/*flac -r 8000 001/001concat.au
%% and so on for 002 etc.
%% Best done by ls > shellscript then editing, then running, outside matlab


function prosodized = prosodizeLdcCorpus(audioDir, featurespec, stride)
  segData = cell(1,1);
  broadcastDirs = dir(audioDir);  
  for b = 3:length(broadcastDirs)       % skip . and ..
    broadcastdirStruct = broadcastDirs(b)  % a directory like 001, 002 ...
    broadcastdir = broadcastdirStruct.name
    trackspec = makeTrackspec('l', 'concatenated.au', [broadcastdir '/']);
    [~, monster] = makeTrackMonster(trackspec, featurespec);

    downsamplingRate = stride / 10;
    allfeatures = monster(1:downsamplingRate:end, :);          

    [starts, ends] = ldcSegmentsInfo(broadcastdir)
    nsegments = length(starts);
    for s = 1:nsegments
      segData{s}.startTime = starts(s);
      segData{s}.endTime = ends(s)
      segData{s}.broadcastName = broadcastdir;
      segData{s}.properties = [];
      startPatch = starts(s) * 1000 / stride
      endPatch = ends(s) * 1000 / stride
      segfeatures = allfeatures(startPatch:endPatch, :);
      segData{s}.features = addTemporalFeatures(segfeatures, stride);  
    end
  end
end


%% test with
%% cd ppm/testeng   or testtur etc. 
%%   prosodizeCorpus('audio', 'annotations', getfeaturespec('../src/mono4.fss'), 100);


%%------------------------------------------------------------------
function [starts, ends] = ldcSegmentsInfo(broadcastdir)
  allocatedSoFar = 0;
  segmentFiles = dir([broadcastdir, '/AUDIO']);
  for s = 1:length(segmentFiles)
    segfile = segmentFiles(s);
    dur = audioFileDuration(segfile);  % in seconds
    starts(s) = allocatedSoFar;
    allocatedSoFar = allocatedSoFar + duration;
    ends(s) = allocatedSoFar;
  end
end

%%------------------------------------------------------------------
