%% Nigel Ward, UTEP, May 2018

%% for cross-language models of situation-frame prediction
%%   compute statistics 
%%   evaluate prediction quality 
%% takes about a minute to run

function sfxlangDriver()
  basename = 'h:/nigel/lorelei/ldc-from/';
  allprops = [];
  allpresence = [];
  
  for langcell = {'englishE50', 'bengali17', 'indonesianE91', 'tagalogE89', 'thaiE90', 'zuluE93'};
    language = langcell{1};
    fprintf('PROCESSING %s\n', language); 
    audir = [basename language '/aufiles/'];
    andir = [basename language '/anfiles/'];
    [presence, ~] = readSFannotations(andir);
    props = getAudioMetadata(audir);
    
    if length(allprops) == 0 
      allprops = props;
      allpresence = presence;
    else
      allprops = vertcat(allprops, props);
      allpresence = vertcat(allpresence, presence);
    end
  end
  fprintf('over all languages ...\n');
  size(allprops)
  sfCorrelationsPlus(allprops, allpresence);
end

    
