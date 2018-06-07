

function outputDummySFs()
  %% mostly as a test of the JSON format 
  %% output 100 frames
  %% all have current-urgent-insufficient
  %% all have location = nullstring
  %% all have confidence = 0.5
  %% all have documentID = dummy
  %% have varying numbers of each type, based on the frequency of occurance
  %%  across the six training languages

  %% to run, addpath h:/nigel/lorlei/uyghur-sftype-december/jsonlab-1.2



  %%    eval 5;  food 4;   infra 8;   med 9;   search 4;   shelter 8;
  %%    utils 4;   water 3;   regimechange 12 ;  crimeviolence 9;   terrorism 8
  typeCounts = [5, 4, 8, 9, 4, 8, 4, 3, 12, 9, 8];
  nSFs = sum(typeCounts);
  [~, typeStdNames] = sfNamings();
  answerObjects = cell(1, nSFs);   % allocate storage 
  acounter = 1;
  for type = 1:length(typeCounts)
    for count = 1:typeCounts(type)
      ansObj.DocumentID = 'dummyID';
      ansObj.Type = typeStdNames(type);
      ansObj.Place = '';
      ansObj.Relief = 'Insufficient';
      ansObj.Status = 'Current';
      ansObj.Confidence = 0.99;
      ansObj.Urgency = 'Urgent';
      ansObj.Justifiction = 'dummy justification';
      answerObjects{acounter} = ansObj;
      acounter = acounter + 1;
    end
  end
  fprintf('saving %d answer objects\n', nSFs);
  savejson('', answerObjects, 'dummySFs.json');
end

  
      
