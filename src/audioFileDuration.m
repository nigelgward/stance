function duration = audioFileDuration(filename)
  %% Nigel Ward, UTEP, June 2017
  %% It would be nice to avoid reading the file, e.g. with sox -n stat
  %%  but I can't figure out how to make it work 

  [rate, signal] = readtracks(filename);
  duration = length(signal) / rate;
end

%% test with audioFileDuration('testset/audio/ChevLocalNewsJuly3.au');
