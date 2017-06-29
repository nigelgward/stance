function [combinedVals, combinedTags, combinedStarts, combinedEnds, ...
	  combinedAuNames, stanceNames] = readStanceAnnotations(csvDirectory)

  %% reads all csv files in the current directory, extracts stance-annotation info
  %% NSstanceVals: a row for each news segment (NS), a column per stance
  %% NStags: a column vector of NS informal names, like 'intro' or 'pollution'
  %% To be linux-friendly, this code uses fileread etc. instead of xlsread
  
  %% Nigel Ward, 2016-2017 Kyoto University and UTEP, with Jason Carlson
  
  %% === first we read in all the segment info, from all annotators === 
  csvfiles = filesWithExtension(csvDirectory, 'csv');  
  NSstanceVals = [];
  NStags = {};
  NSaudioFiles = {};
  NSstartTimes = [];
  NSendTimes = [];
  segmentsSoFar = 0;
  
  stanceNames = []; 
  for filei = 1:length(csvfiles)  
    filenamec = csvfiles(filei);
    filename = filenamec{1};
    %%  fprintf('processing file %3d, %s\n', filei, filename);
    path = [csvDirectory filename];

    [vals, tags, starts, aufile, stNames] = readStanceSpreadsheet(path);

    nsegsInThisBroadcast = length(tags);
    for seg = 1:nsegsInThisBroadcast
      segIx = segmentsSoFar + seg;
      NSstanceVals(segIx,:) = vals(:,seg)';
      NStags(segIx) = tags(seg);
      NSaudioFiles{segIx} = aufile;
      NSstartTimes(segIx) = starts(seg);
      if seg > 1
	NSendTimes(segIx -1) = starts(seg); % end of previous is start of this
      end
    end
    segmentsSoFar = segmentsSoFar + nsegsInThisBroadcast;
    NSendTimes(segmentsSoFar) = 0;   % a flag
    
    %% probably should check that stanceNames are consistent across sheets
    if isempty(stanceNames) && ~isempty(stNames);
      stanceNames = stNames;
    end 
  end		    
  
  %% === second, we merge multiple annotators' views of the same segments ===
  nsegments = length(NSstartTimes);
  alreadyHandled = zeros(nsegments, 1);

  combinedVals = [];
  combinedTags = {};
  combinedAuNames = {};
  combinedStarts = [];
  nUniqueSegments = 0;

  for seg = 1:nsegments
    if alreadyHandled(seg)
      continue
    end
        nUniqueSegments = nUniqueSegments + 1;
    nAnnotationsForThisSegment = 1;
    sumOfAnnotations = NSstanceVals(seg,:);
    for possibleMatch = seg+1:nsegments
      if (NSstartTimes(seg) == NSstartTimes(possibleMatch) && ...
	  strcmp(NSaudioFiles(seg), NSaudioFiles(possibleMatch)) )
	%%fprintf('found match for %d at %d, size(NSstanceVals) is %d,%d\n', ...
	%% seg, possibleMatch, size(NSstanceVals));
	alreadyHandled(possibleMatch) = true;
	nAnnotationsForThisSegment = nAnnotationsForThisSegment + 1;
	sumOfAnnotations = sumOfAnnotations + NSstanceVals(possibleMatch,:);
      else
	%% no match, so we just skip it
      end
    end
    combinedVals(nUniqueSegments,:) = sumOfAnnotations / nAnnotationsForThisSegment;
    combinedStarts(nUniqueSegments) = NSstartTimes(seg);
    combinedEnds(nUniqueSegments) = NSendTimes(seg);
    combinedTags{nUniqueSegments} = NStags(seg);
    combinedAuNames{nUniqueSegments} = NSaudioFiles(seg);
  end

end


%% to test
%% cd ppm/testeng
%% readStanceAnnotations('annotations/')
