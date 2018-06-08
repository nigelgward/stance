

function outputDummySFs()
  %% mostly as a test of the JSON format 
  %% output about 100 frames
  %% all have current-urgent-insufficient
  %% all have location = nullstring or the top-level location
  %% all have confidence = 0.99
  %% all have documentID = dummy
  %% type varies


  %% to run, addpath h:/nigel/lorelei/uyghur-sftype-december/jsonlab-1.2

  %% Customize these two based on the situation description
  typeCountDeltas = [0, -1, 0, 0, 0, 0, 0, 0, -9, -7, -6];  % for earthquake
  topLevelLocation = 'Sichuan province';

  %% have varying numbers of each type, based on the frequency of occurance
  %%  across the six training languages
  %%    evac 5;  food 4;   infra 8;   med 9;   search 4;   shelter 8;
  %%    utils 4;   water 3;   regimechange 12 ;  crimeviolence 9;   terrorism 8
  typeCounts = [5, 4, 8, 9, 4, 8, 4, 3, 12, 9, 8];

  %% dummy 1: all locations are the empty string
  answerObjectsNil = createSFs('', typeCounts);
  savejson('', answerObjectsNil, struct('FileName','nilLocDefaultTypes.json','ParseLogical', 1));

  %% dummy 2: add a set with locations being the top-level geographic entity
  answerObjectsLoc = createSFs(topLevelLocation, typeCounts);
  allAnswerObjects = [answerObjectsNil answerObjectsLoc];
  savejson('', allAnswerObjects, struct('FileName', 'varLocDefaultTypes.json', 'ParseLogical', 1));

  %% dummy 3: ditto, plus type likelihoods adjusted
  newTypeCounts = typeCounts + typeCountDeltas;
  answerObjectsNil = createSFs('', newTypeCounts);
  answerObjectsLoc = createSFs(topLevelLocation, newTypeCounts);
  allAnswerObjects = [answerObjectsNil answerObjectsLoc];
  savejson('', answerObjectsNil, struct('FileName', 'varLocTweakedTypes.json', 'ParseLogical', 1));
end



function answerObjects = createSFs(location, typeCounts)
  nSFs = sum(typeCounts);
  [~, typeStdNames] = sfNamings();
  answerObjectsNil = cell(1, nSFs);   % allocate storage 
  acounter = 1;
  for type = 1:length(typeCounts)
    for count = 1:typeCounts(type)
      ansObj.DocumentID = 'dummyID';
      ansObj.Type = typeStdNames(type);
      ansObj.Place_KB_ID = location;
      ansObj.Resolution = 'insufficient';
      ansObj.Status = 'current';
      ansObj.Confidence = 0.99;
      ansObj.Urgent = true;
      ansObj.Justification_ID = 'dummy justification';
      answerObjects{acounter} = ansObj;
      acounter = acounter + 1;
    end
  end
end

  
%% after outputting things, do a format check using jsonschemavalidator.net
%% where the schema is LoReHLT18_system-output-schema.json,
%%   locally renamed to LoReHLT18schema.json
