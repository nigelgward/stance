%% build predictor and predictee sets for the subset of langNames specified by langIDs
%% Nigel Ward, UTEP, June 2018

function[setX1, setX2, setX3, setY] =  buildSfSets(langIDs, langNames, getTruth)
  naudios = 3;     % likely min number of audios
  setX1 = zeros(naudios, 3);    % 3 predictors
  setX2 = zeros(naudios, 16);   % 3+13 predictors
  setX3 = zeros(naudios, 29);   % 3+13*2 predictors
  setY = zeros(naudios, 17);    % 17 predictees
  instancesSoFar = 0;
  for i=1:length(langIDs)
    langID = langIDs(i);
    fprintf('   buildSets for %s, ', langNames(langID));
    baseDir = 'h:/nigel/lorelei/ldc-from/'; 
    audir = [baseDir langNames(langID) '/aufiles'];
    andir = [baseDir langNames(langID) '/anfiles'];
    thisLangX1 = getAudioMetadata(audir);   
    
    pfAvgsStds = findPFaverages(audir);
    thisLangX2 = [thisLangX1 pfAvgsStds(:,1:13)]; 

    thisLangX3 = [thisLangX1 pfAvgsStds];
    if getTruth
      thisLangY = readSFannotations(andir);
    else
      thisLangY = 0;
    end
    
    instancesForLang = size(thisLangX1,1);
    setX1(instancesSoFar+1:instancesSoFar+instancesForLang,:) = thisLangX1;
    setX2(instancesSoFar+1:instancesSoFar+instancesForLang,:) = thisLangX2;
    setX3(instancesSoFar+1:instancesSoFar+instancesForLang,:) = thisLangX3;
    setY(instancesSoFar+1:instancesSoFar+instancesForLang,:) = thisLangY;
    instancesSoFar = instancesSoFar+instancesForLang;
  end
  fprintf('\n');
end



%% cache for future reuse, to prevent heavy, repetitive computation and file i/o
function pfa = findPFaverages(audir)
  persistent PFAcache;
  persistent nEntries;

  if length(PFAcache) == 0  % first call so initialize the cache
    nEntries = 0;
    PFAcache = struct('dir', {}, 'values', {});
  end

  for i = 1:nEntries
    entry = PFAcache(i);
    if strcmp(audir, entry.dir)
      pfa = entry.values;
      return
    end
  end

  pfa = getProsodicFeatureAvgStds(audir);
  nEntries = nEntries + 1;
  PFAcache(nEntries).values = pfa;
  PFAcache(nEntries).dir = audir;
end

