%% Sara and Nicole Final Project

% Load Data

filenames = ["tide_station_2014.csv", "tide_station_2015.csv", "tide_station_2016.csv", "tide_station_2017.csv", "tide_station_2018.csv", "tide_station_2019.csv", "tide_station_2020.csv", "tide_station_2021.csv", "tide_station_2022.csv", "tide_station_2023.csv", "tide_station_2024.csv"];
allData = table();

for i = 1:length(filenames)
    filename = filenames(i);
    t = readtable(filename);
    allData = [allData; t];
end

%% Correct the Dates

date_day = allData(:,1);
date_day_array = table2array(date_day);
date_hour = allData(:,2);
date_hour_array = table2array(date_hour);
num_day = datetime(date_day_array, "InputFormat", "yyyy/MM/dd");
num_hour = datetime(date_hour_array, "InputFormat", "HH:mm");
hour = datenum("0000-00-00 01:00:00") - datenum("0000-00-00 00:00:00");
hours = NaN(24,1);
for i = 1:24
    hours(i,:) = hour*(i-1);
end

hours_extended = repmat(hours, (height(allData)/24), 1);

dates = (datenum(num_day) + hours_extended);
dates_full = NaN(length(dates), 1);
dates_full(:,1) = dates; %final time variable for water levels

%%
