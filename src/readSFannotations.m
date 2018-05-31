% Nigel Ward, April 2018 

%% nigel/sframes/readSFannotations.m

%% Input: annoDir: directory containing all annotation file
%%  presumably having been moved there from LDC's deep file structure

%% Output: presence: a 2 dimensional array, of type SFcollection, namely
%%   a mostly-boolean array
%%   one row per file
%%   one column per annotation, namely 
%%     field 1 for currency 
%%     field 2 for insufficiency 
%%     field 3 for urgency 
%%     field 4 for located (i.e. a place name is specified) 
%%     field 5 for relevance (any of the types is present 
%%     field 6 for gravity (conjunction of the first 3)
%%     fields 7-17 for the types (11 types)
%%    17 fields in total

%% test with readSFannotations('annot-testdir');
%% actually run with readSFannotations('../lorelei/ldc-from/englishE50/anfiles');

%% This is intended to serve both statistics computation (called with driver2.m)
%% and incorporation into the full stance workflow
%%    (stance/src/prosprop.m, makePPM.m, predEval.m)

%% Sample Input File, from the English corpus (E50)
%%   TYPE: Shelter, Evacuation
%%   TIME: Current
%%   Resolution: Insufficient/Unknown
%%   PLACE: Brian Head, Panguitch, Southern Utah, Panguitch Lake, Utah
%%   URGENCY: Urgent
%%

%% Purposes of this code: 
%% - compute statistics, including base rates 
%%   and correlations between the various annotations
%% - locate files meeting various criteria, for later listening to
%% - later possible use in the actual workflow 

%% Notes and Issues:
%% 1. if TYPE is 'out-of-domain' all others are guaranteed to be 'n/a'
%%    since labelers are instructed to abort at that point
%%  This means that such files in the training data should not be
%%   included in the models used 
%%   for estimating status, relief, urgency, and place
%% 2. Grave is defined as current && insufficient && urgent
%%   but I may want to infer a training signal that is continuous
%%   rather than boolean

function [presence, propNames] = readSFannotations(annoDir)
  fieldNameIDs = containers.Map(...
      {'TIME:', 'Resolution:', 'URGENCY:', 'PLACE:', 'TYPE:'}, ...
      {1,2,3,4,5});
  [fieldStdNames, typeStdNames] = sfNamings();
  nNonTypeFields = length(fieldStdNames);
  nfields = length(fieldStdNames) + length(typeStdNames);
  propNames = horzcat(fieldStdNames.values, typeStdNames.values);
  filespec = sprintf('%s/*txt', annoDir);
  files = dir(filespec);
  if (size(files,1) == 0)
    error('no files in the specified directory, "%s"\n', annoDir);
  end
  nfiles = length(files);
  presence = zeros(nfiles, nfields);
  locCount = zeros(nfiles, 1);
  typeCount = zeros(nfiles, 1);
  for filei = 1:nfiles   
    file = files(filei);
    fieldSeen = zeros(nNonTypeFields,1);
    path = [annoDir '/' file.name];
    %%fprintf('processing %s\n', path);
    fid = fopen(path, 'r');

    while true
      thisline = fgetl(fid);
      if ~ischar(thisline) || strcmp(thisline,''); break; end  % end of file
      lineCells = strsplit(thisline);
      keycell = lineCells(1);
      fieldID = lookupFieldID(keycell{1}, fieldNameIDs, file.name);

      if fieldID < 99
	fieldSeen(fieldID) = 1;
      end
      [presence, locCount, typeCount] = recordPresence(filei, fieldID, ...
	       thisline, lineCells, file.name, presence, locCount, typeCount,nNonTypeFields); 
    end  % line of file 
    fclose(fid);
    if sum(fieldSeen) ~= 5  
      fieldSeen'
      fprintf('expected 5 fields; found %d, for %s\n', sum(fieldSeen), file.name);
    end  % if 
  end  % file 
  % grave if current, non-satisfied and urgent
  presence(:,6) = presence(:,1)==1 & presence(:,2)==1 & presence(:,3)==1;
  %%printSomeStatistics(presence, locCount, typeCount, nfiles, typeStdNames, nNonTypeFields);
end 


function [presence, locCount, typeCount] = recordPresence(filei, fieldID, lineString, lineCells, filename, presence, locCount, typeCount, nNonTypeFields)
  %% mapping from annotation strings to numeric values
  %%        these values are chosen so that 1 is what we need to find
  %%        and 0 is the opposite, 
  %%        possibly with intermediate values, to use for training, not test
  %% different corpora have different sets of annotation options;
  %%  for now, just handle what's there for the English corpus
  statusMapping = containers.Map( ...
      {'Current', 'Future', 'Past', 'n/a'}, ...
      [1, 0, 0, 0]);
      %%      {1, .2, .1, 0} );
  reliefMapping = containers.Map( ...
      {'n/a', 'Insufficient/Unknown', 'No_Known_Resolution', 'Sufficient'}, ...
      {1, 1, 1, 0} );
      %%       {.1, 1, .9, 0} );
  urgencyMapping = containers.Map( ...
      {'Urgent', 'Unknown', 'Not', 'n/a'}, ...
      {1, 0, 0, 0} );
      %%{1, 0.2, 0, 0} );
  %% hackish since type "Utilities, Energy, or Sanitation" has embedded commas
  typeIDs = containers.Map({'Evacuation', ...
			    'Food Supply', ...
			    'Infrastructure', ...
			    'Medical Assistance', ...
			    'Urgent Rescue', ...
			    'Shelter', ...
			    'Utilities', ...
			    'Water Supply', ...
			    'Elections and Politics', ... 
			    'Civil Unrest or Wide-spread Crime', ...
			    'Terrorism or other Extreme Violence', ...
			    'Energy', ...
			    'or Sanitation'}, ... 			   
			   {1,2,3,4,5,6,7,8,9,10, 11, 6, 6} );
  switch fieldID
    case 1
      presence(filei, fieldID) = lookupTarget(statusMapping, lineCells);
    case 2
      presence(filei, fieldID) = lookupTarget(reliefMapping, lineCells);
    case 3
      presence(filei, fieldID) = lookupTarget(urgencyMapping, lineCells);
    case 4
      firstPlaceCell = lineCells(2);
      placePrefix = strtrim(firstPlaceCell{1});
      if strcmp(placePrefix, 'n/a');
	%% the presence stays 0 
      else 
	presence(filei, fieldID) = 1;  
	nLocations = 1 + length(strfind(lineString, ','));
	
	locCount(filei) = nLocations;   
      end
    case 5                % situation type 
      firstTypeCell = lineCells(2);
      typePrefix = strtrim(firstTypeCell{1});
      if strcmp(typePrefix, 'out-of-domain');
	%% the presence stays 0 
      else 
	presence(filei, fieldID) = 1;  
	nTypes = 1 + length(strfind(lineString, ','));  % a lazy approximation
	typeCount(filei) = nTypes;   
	cells = strsplit(lineString, ':');
	tailcell = cells(2);
	typeList = strsplit(tailcell{1}, ',');
	for type = typeList
	  typeString = strtrim(type{1});
	  if ~typeIDs.isKey(typeString)
	    typeString
	    fprintf('unknown type %s! in %s\n', typeString, filename);
	  else 
	    typeID = typeIDs(typeString); 
	    presence(filei, nNonTypeFields + typeID) = true; % save in a column 7-17
	  end
	end 
      end
    otherwise
      fprintf('internal error: fieldID is %d\n', fieldID);
  end
end       



function printSomeStatistics(presence, locCount, typeCount, nfiles, typeStdNames, nNonTypeFields)

  fprintf(' current = %.1f%%\n', 100 * sum(presence(:,1)==1) / nfiles);
  fprintf(' insufficient = %.1f%%\n', 100 * sum(presence(:,2)==1) / nfiles);
  fprintf(' urgent = %.1f%%\n', 100 * sum(presence(:,3)==1) / nfiles);
  fprintf(' located (place ~= n/a) = %.1f%%\n', ...
	  100 * sum(presence(:,4)>0) / nfiles);
  fprintf(' has-type (type ~= out-of-domain) = %.1f%%\n', ...
	  100 * sum(presence(:,5)>0) / nfiles );
  fprintf('\n');
  fprintf(' urgent but not current = %.1f%%\n', ...
	  100 * sum(presence(:,3)==1 & presence(:,1)~=1) / nfiles );
  find(presence(:,3)==1 & presence(:,1)~=1)';    % indices of such 
  fprintf(' urgent but not insufficient = %.1f%%\n', ...
	  100 * sum(presence(:,3)==1 & presence(:,2)~=1) / nfiles );
  fprintf('\n');
  fprintf(' urgent but not located = %.1f%%\n', ...
	  100 * sum(presence(:,3)==1 & presence(:,4)~=1) / nfiles );
  fprintf(' urgent and located = %.1f%%\n', ...
	  100 * sum(presence(:,3)==1 & presence(:,4)==1) / nfiles );
  fprintf(' not urgent and located = %.1f%%\n', ...
	  100 * sum(presence(:,3)~=1 & presence(:,4)==1) / nfiles );
  fprintf(' not urgent and not located = %.1f%%\n', ...
	  100 * sum(presence(:,3)~=1 & presence(:,4)~=1) / nfiles );
  fprintf(' not urgent and in-domain = %.1f%%\n', ...
	  100 * sum(presence(:,3)~=1 & presence(:,5)==1) / nfiles );

  urgentIndices = (presence(:,3) == 1);
  fprintf('     Type: Frequency, %% Urgent\n');
  for i=1:length(typeStdNames)     % 11
    index = nNonTypeFields + i;
    countOfType = sum(presence(:,index));
    countOfTypeAndUrgent = sum(presence(urgentIndices,index));
    fprintf('%d %14s: %.2f, %.2f\n', ...
	    i, typeStdNames(i), countOfType/nfiles, ...
	    countOfTypeAndUrgent / countOfType);
  end
  showExtraStats(presence, locCount, typeCount);
end


function showExtraStats(presence, locCount, typeCount)
  inDomainUrgentIndices = presence(:,5)==1 & presence(:,3) == 1;
  inDomainNonUrgentIndices = presence(:,5) == 1 & presence(:,3) ~= 1;
  fprintf('when in-domain\n');
  fprintf('  avg places mentioned when urgent: %.2f, when not urgent: %.2f\n', ...
 	  sum(locCount(inDomainUrgentIndices)) / sum(inDomainUrgentIndices), ...
 	  sum(locCount(inDomainNonUrgentIndices)) / sum(inDomainNonUrgentIndices));
  fprintf('  avg number of types when urgent: %.2f, when not urgent: %.2f\n', ...
 	  sum(typeCount(inDomainUrgentIndices)) / sum(inDomainUrgentIndices), ...
 	  sum(typeCount(inDomainNonUrgentIndices)) / sum(inDomainNonUrgentIndices));
  
  %% may also want to compute:
  %% - correlation between each situation type and gravity 
  %% - correlation between number of situation types and gravity
  %% - whether the subtypes of not sufficient etc. are informative re urgency
  %%  (which may help in training from labeled corpora, but not for an IL)
end 


function fieldID = lookupFieldID(fieldString, inventory, filename)
  if ~inventory.isKey(fieldString)
    fprintf('unknown field name %s! in %s\n', fieldString, filename);
    fieldID = 99;
    return
  end
  fieldID = inventory(fieldString);
end


function value = lookupTarget(mapping, lineCells)
  keycell = lineCells(2);
  key = keycell{1};
  if ~mapping.isKey(key)
    fprintf('did not find a mapping for %s!\n', key);
    value = 0;
  end;
  value = mapping(key);
end





