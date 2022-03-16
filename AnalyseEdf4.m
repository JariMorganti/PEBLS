%% Setup
clear all; % Clear old variables
close all; % Close all windows
clc; % Clear Command Window

%% Setup
FileCell = cell(24, 10); % Cell to hold all participant data in
FileList = cell(240, 1); % cell to list all data in

MeanFixDurStructure = zeros(24, 10); % Pre-creating a structure for the MeanFixDurStructure (step 1)
FixationDurations = zeros(10, 3); % Pre-creating a structure for the fixationDurations (step 2)

MeanSaccDurStructure = zeros(24, 10); % Pre-creating a structure for the MeanSaccDurStructure (step 1)
SaccadeDurations = zeros(10, 3); % Pre-creating a structure for the SaccadeDurations (step 2)

InitialSpatialSpreadStructure = zeros(24, 10); % Pre-creating a structure for the InitialSpatialSpreadStructure (step 1)
SpatialSpreads = zeros(10,3); % Pre-creating a structure for the SpatialSpreads (step 2)

InitialSaccFrequencyStructure = zeros(24, 10); % Pre-creating a structure for the InitialSaccFrequencyStructure (step 1)
SaccadeFrequencies = zeros(10,3); % Pre-creating a structure for the SaccadeFrequencies (step 2)

InitialFixFrequencyStructure = zeros(24, 10); % Pre-creating a structure for the InitialFixFrequencyStructure (step 1)
FixationFrequencies = zeros(10,3); % Pre-creating a structure for the FixationFrequencies (step 2)

ParticipantCodeList = [07 09 11 02 10 03 01 04 08 12]'; % Re-ordering the data, so it is assigned to the correct participant
ParticipantCodes = repmat(ParticipantCodeList,3,1); % Repeating the list 3 times so that the data is in the correct form

ConditionCodeList = [0 1 2]'; % Conditions
ConditionCodes = repelem(ConditionCodeList, 10); % Creating list of conditions in correct order

%% Data Creation

for i = 1:240; % for loop for each file
    
    %% Conditioning 
    
    data = Edf2Mat(num2str(i, '%01d')); % Data variable to locate into cells - with each iteration, data goes up a file
    FileCell{i} = data; % Allocating a position for data within the file cell
    FileList{i} = data; % Allocating a position for data within the file list
 
    %% Fixation Duration
    
    FixDur = data.Events.Efix.duration; % Creating a variable called 'FixDur' which finds the duration variable within the data variable, per file, and extracts it
    
    MeanFixDurStructure(i) = Remove_Outliers(FixDur); % Calling the Remove_Outliers function in relation to FixDur and assigning the value inside the MeanFixDurStructure
    
    % 2nd stage - creating new variables (per condition per participant) to
    % remove outliers from 
    
    for j = 1:3
        for k = 1:10
            temp_fix_data = MeanFixDurStructure(j*8-7:(j*8),k);
            FixationDurations(k, j) = Remove_Outliers(temp_fix_data);
        end
    end
    
    FDs = reshape(FixationDurations, [30, 1]); % Reshape for later formatting
 
    
    %% Saccade Duration
    
    SaccDur = data.Events.Esacc.duration; % Determines saccade duration for a given file
    
    MeanSaccDurStructure(i) = Remove_Outliers(SaccDur); 
    
    for j = 1:3
        for k = 1:10
            temp_sacc_data = MeanSaccDurStructure(j*8-7:(j*8),k);
            SaccadeDurations(k, j) = Remove_Outliers(temp_sacc_data);
        end
    end
    
    SDs = reshape(SaccadeDurations, [30, 1]); % Reshape for later formatting
  
    %% Spatial Spread
    
    InitialSpread = data.Samples.posX; % Creates a variable for the initial spread
    InitialSpread_OutliersRemoved = rmoutliers(InitialSpread,'mean'); % Removes outliers of initial spread
    MaxX = max(InitialSpread_OutliersRemoved); % Highest value
    MinX = min(InitialSpread_OutliersRemoved); % Lowest value
    SpatialSpread = (MaxX-MinX); % Difference (spread)
    InitialSpatialSpreadStructure(i) = (SpatialSpread')'; % Places spatial spread inside cell
    
    for j = 1:3
        for k = 1:10
            temp_spatial_data = InitialSpatialSpreadStructure(j*8-7:(j*8),k);
            SpatialSpreads(k, j) = Remove_Outliers(temp_spatial_data);
        end
    end
    
    SS = reshape(SpatialSpreads, [30,1]); % Reshape for later formatting
   
    %% Saccade Frequency
    Saccs = data.Events.Esacc.start; % Creating a sacc variable
    SaccsTime_OutliersRemoved = rmoutliers(Saccs, 'mean'); % Removing outliers
    NoOfSacc = numel(SaccsTime_OutliersRemoved); % Counts the number of saccades per file
    MaxSaccTime = max(SaccsTime_OutliersRemoved); % Works out highest saccade start time
    MinSaccTime = min(SaccsTime_OutliersRemoved); % Works out lowest saccade start time
    SaccTimeDifference = (MaxSaccTime - MinSaccTime); % Works out total saccade time
    SaccFrequencyMS = (NoOfSacc/SaccTimeDifference); % Works out saccade frequency in MS
    SaccFrequencyS = SaccFrequencyMS * 1000; % Turns into Seconds
    InitialSaccFrequencyStructure(i) = (SaccFrequencyS')'; % Places the data into a structure
   
    % Outlier removal pt 2
    
    for j = 1:3
        for k = 1:10
            temp_saccFq_data = InitialSaccFrequencyStructure(j*8-7:(j*8),k);
            SaccadeFrequencies(k, j) = Remove_Outliers(temp_saccFq_data);
        end
    end
    
    SFs = reshape(SaccadeFrequencies,[30,1]); % Reshape for later formatting
    
    %% Fixation Frequency
    Fixes = data.Events.Efix.start; % Creating a Fix variable
    FixesTime_OutliersRemoved = rmoutliers(Fixes,'mean'); % Removing outliers
    NoOfFix = numel(FixesTime_OutliersRemoved); % Counts the number of fixations per file
    MaxFixTime = max(FixesTime_OutliersRemoved); % Works out highest fixation start time
    MinFixTime = min(FixesTime_OutliersRemoved); % Works out lowest fixation start time
    FixesTimeDifference = (MaxFixTime - MinFixTime); % Works out total fixation time
    %Remove corrupt data
     if size(FixesTimeDifference) == [0 0] 
       continue
     end
    FixFrequencyMS = (NoOfFix/FixesTimeDifference);  % Works out fixation frequency in MS
    FixFrequencyS = FixFrequencyMS * 1000; % Turns into Seconds
    InitialFixFrequencyStructure(i) = (FixFrequencyS')'; % Places the data into a structure
    
        % Outlier removal pt 2
    
    for j = 1:3
        for k = 1:10
            temp_FixFq_data = InitialFixFrequencyStructure(j*8-7:(j*8),k);
            FixationFrequencies(k, j) = Remove_Outliers(temp_FixFq_data);
        end
    end 
  
FixationFrequencies(~isfinite(FixationFrequencies)) = NaN; % Making infinite values NaN for use later

   FFs = reshape(FixationFrequencies,[30,1]);% Reshape for later formatting
     
end

%% MANOVA Setup

clc;

% Conditioning
DataForMANOVA = [ParticipantCodes, ConditionCodes, FDs, FFs, SDs, SFs, SS]; %Structure data
TableForMANOVA = table(ParticipantCodes, ConditionCodes, FDs, FFs, SDs, SFs, SS); % Place data into table

DataForMANOVA(sum(isnan(DataForMANOVA), 2) == 1, :) = [];
DataForMANOVANew = DataForMANOVA(DataForMANOVA(:, 5) <= 250, :);

% TableForMANOVANEW = table(DataForMANOVANew)

x = [DataForMANOVANew(:,3), DataForMANOVANew(:,4), DataForMANOVANew(:,5), DataForMANOVANew(:,6), DataForMANOVANew(:,7)]; % Create x variavle to plot

[rCorr, pCorr] = corrcoef(x)

gplotmatrix(x,[],DataForMANOVANew(:, 2),[],'+xo', []) % Plot for report
figure
corrplot(x,'type','Spearman','testR','on') % Plot for report w/ Spearman for colinearity

%%% EXPORT OUTPUTS INTO SPSS FOR FINAL ANALYSIS