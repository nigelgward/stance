function [starts, ends, aufiles] = getSegInfo(audioDir, annotDir)
  %% Nigel Ward, UTEP, June 2017
  %% deals with two different ways of organizing a directory

  [~, ~, starts, ends, aufiles, ~] = readStanceAnnotations([annotDir '/']);
  if ~isUtepFormat(audioDir)
    for i = 1:length(aufiles)
      aufiles{i} = ['concat' char(aufiles{i})];
    end
  end
end


%%------------------------------------------------------------------
%% no longer used
function result = isUtepFormat(audioDir)
  % utep directories are flat; ldc directories have subdirectories
  result = true;
  contents = dir(audioDir);
  for i = 3:length(contents)
    file = contents(i);
    if ~file.isdir
      continue
    end
    if strfind(file.name, 'pitchCache');
      continue
    end
    result = false;
  end
end


%==================================================================
%% !! This is no longer used,
%%     since we now get this information from the annotation files.
%% The strategy is to look in the audioDir, but only to get the segment info.
function [starts, ends, aufiles] = segInfoLdc(audioDir)
  starts = [];
  ends = [];
  aufiles = {};
  segmentsSoFar = 0;
  alldirs =  dir(audioDir);
  broadcastDirs = alldirs(3:end);      % skip . and ..

  for b = 1:length(broadcastDirs)      % a directory like 001, 002 ...
    timeIntoBroadcastSoFar = 0;
    broadcastdirStruct = broadcastDirs(b);
    broadcastdir = broadcastdirStruct.name;
    audiosubdir = [audioDir '/' broadcastdir '/' 'AUDIO'];
    audioclips = filesWithExtension(audiosubdir, 'au');

    for c = 1:length(audioclips)
      clipfile = char(audioclips(c));
      dur = audioFileDuration([audiosubdir, '/', clipfile]);
      segmentsSoFar = segmentsSoFar + 1;
      starts(segmentsSoFar) = timeIntoBroadcastSoFar;
      timeIntoBroadcastSoFar = timeIntoBroadcastSoFar + dur;
      ends(segmentsSoFar) = timeIntoBroadcastSoFar;
      % assemble a base name like concat001
      aufiles{segmentsSoFar} = ['concat' broadcastdir];
    end
  end
end


%==================================================================
%% to test
%%  cd ppm/testeng
%%  [a b c]  = segInfoUtep('annotations/')
