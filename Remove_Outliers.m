function [Cond_Data] = Remove_Outliers(Raw_data)
    %    hist(Raw_data); % Histogram to understand all of the data
    Means = nanmean(Raw_data); % Create a mean of all data
    StdDevs = nanstd(Raw_data); % Create a std dev of all data
    CutOff = 2; % Cut off of std dev's I am happy for data to be at
    Bad = Raw_data > Means+(CutOff .* StdDevs) | Raw_data < Means - (CutOff .* StdDevs);
    Cond_Data = nanmean(Raw_data(Bad == 0))'; % Populate the mean fixation duration structure without the bad trials
end      