%% getSegInfo
%% Nigel Ward, UTEP, June 2017, revised May 2018 

%% starts, ends, and aufiles are parallel vectors,
%% starts and ends are in seconds
function [starts, ends, aufiles] = getSegInfo(audioDir, annotDir)

  %% deals with two different ways of organizing a directory
  %% if csv files exist then it's utep-format stance annotations and audios
  %%    where each audio file has multiple internal segments 
  %% otherwise it's ldc format, where each segment is in its own file

  csvfiles = filesWithExtension(annotDir, 'csv');  
  if (length(csvfiles) > 0)
    [~, ~, starts, ends, aufiles, ~] = readStanceAnnotations([annotDir '/']);
  else
    %% in this case we ignore annotDir
    aufiles = filesWithExtension(audioDir, 'au');
    starts = zeros(1,length(aufiles));
    ends = zeros(1,length(aufiles));   % just to allocate space
    for i = 1:length(aufiles)
      audiofile = aufiles{i};
      audioInfo = audioinfo([audioDir '/' audiofile]);
      ends(i) = audioInfo.Duration;
      aufiles{i} = audiofile(1:end-3);  % strip off .au; will be re-added later 
    end
  end
end

%% to test
%%   cd sframes
%%   getSegInfo('audio-testdir', 'annot-testdir');
