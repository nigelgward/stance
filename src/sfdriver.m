% Nigel Ward, April 2018 

%% nigel/sframes/sfdriver.m

%%  used for testing readSFAnnotations,
%%  and for computing correlations and other stats

%% testing
%%   cd sframes
%%   sfdriver('audio-testdir', 'annot-testdir');
%% running on real data
%%   cd lorelei/ldc-from/englishE50  (or another dir with urgency labels)
%%   sfdriver('aufiles', 'anfiles');

function sfdriver(audir, andir)
  [presence, ~] = readSFannotations(andir);
  props = getAudioMetadata(audir);
  sfCorrelationsPlus(props, presence);
end

  
