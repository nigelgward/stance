function [segStarts, segEnds, segUrls] = segmentLocs(annotDir)
  %% Nigel Ward, UTEP, June 2017

  [~, ~, segStarts, segEnds, segUrls, ~] = readStanceAnnotations([annotDir '/']);
end


%% to test
%%  cd ppm/testeng
%%  [a b c]  = segmentLocs('annotations/')
