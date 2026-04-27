%% Sara and Nicole Final Project

% Load Data

filenames = ["tide_station_2014.csv", "tide_station_2015.csv", "tide_station_2016.csv", "tide_station_2017.csv", "tide_station_2018.csv", "tide_station_2019.csv", "tide_station_2020.csv", "tide_station_2021.csv", "tide_station_2022.csv", "tide_station_2023.csv", "tide_station_2024.csv"];
allData = table();

for i = 1:length(filenames)
    filename = filenames(i);
    t = readtable(filename);
    allData = [allData; t];
end
water_lvl=table2array(allData(:,5));

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
%%baseline_index = find(dates_full == 736696);
%%baseline_three_year = mean(water_lvl(1:baseline_index));

%% Correcting Hurricane Dates

Hurricane_data_for_dates=readmatrix('Storm Track Data.xlsx'); %date, lat
Hurricane_data_for_names=readtable('Storm Track Data.xlsx');

dates_hurricane= Hurricane_data_for_dates(:,1)+datenum('01-00-1900');
names_hurricane = string(table2array(Hurricane_data_for_names(:,8)));

%% 
figure (1); clf
title('water level')
plot(dates_full, water_lvl, ".")
datetick('x','mmm yyyy')

pred_water_lvl = table2array(allData(:,3));
anomaly = water_lvl - pred_water_lvl;
smoothed_anom = movmean(anomaly, 6);

figure (2); clf
title('Water Level Anomaly')
for i = 1:length(dates_hurricane)
    %xline(dates_hurricane(i), lineWidth=2, Color = [0.8, 0.8, 0.8])
    xline(dates_hurricane(i), '-', names_hurricane(i), lineWidth=2, Color = [0.8, 0.8, 0.8])
end
hold on
plot(dates_full, smoothed_anom, ".")
ylabel("Water Level Anomaly (ft)")
datetick('x','mmm yyyy')
legend({'Hurricanes', '', '', '', '', '', '', '', 'Water Level'}, Location = "southwest")
hold off

%% Question 2

hurricane_max = NaN(8,1);

for i = 1:length(dates_hurricane)
    min_date = dates_hurricane(i) - 0.5;
    max_date = dates_hurricane(i) + 0.5;
    min_index = find(abs(dates_full-min_date) < 0.001);
    %use a tolerance of 0.001 to find the index of min_date and max_date
    %since the actual values are not exactly equal
    max_index = find(abs(dates_full-max_date) < 0.001);
    hurricane_range = water_lvl(min_index:max_index,:);
    hurricane_max(i,1) = max(hurricane_range);
end

figure (3); clf
b = bar(flip(names_hurricane), flip(hurricane_max));
title("Max water level anomaly from each hurricane")
xtips = b.XEndPoints;
ytips = b.YEndPoints;
labels = string(flip(hurricane_max));
text(xtips, ytips, labels, 'HorizontalAlignment', 'center','VerticalAlignment', 'bottom');
xlabel("Hurricanes (oldest to most recent)")
ylabel("Water Level Anomaly (ft)")

%% Question 3

strength_cats = Hurricane_data_for_dates(:,7);
lats_hurricane = Hurricane_data_for_dates(:,2);
lons_hurricane = -1.*Hurricane_data_for_dates(:,3);

gi_lat = 29.2633;
gi_lon = -89.9566;

dists = NaN(8,1);
dist_cats = NaN(8,1);

for i = 1:length(lats_hurricane)
    arclen = distance(gi_lat, gi_lon, lats_hurricane(i), lons_hurricane(i));
    dist = deg2km(arclen);
    dists(i) = dist;
    if dist <= 23
        dist_cats(i) = 5;
    elseif (dist > 23)&&(dist <= 45)
        dist_cats(i) = 4;
    elseif (dist > 45)&&(dist <= 67)
        dist_cats(i) = 3;
    elseif (dist > 67)&&(dist <= 89)
        dist_cats(i) = 2;
    elseif dist > 89
        dist_cats(i) = 1;
    end
end

intensity = dist_cats .* strength_cats;

instant_water_level = NaN(8,1);
for i = 1:8
    instant_index = find(abs(dates_full-dates_hurricane(i)) < 0.001);
    instant_water_level(i) = water_lvl(instant_index);
end

figure(4); clf
subplot(3,1,1)
plot(strength_cats, hurricane_max, ".", MarkerSize = 15)
text(strength_cats, hurricane_max, names_hurricane,'VerticalAlignment','baseline','HorizontalAlignment','left','FontSize',8, 'Color', [0, 0.4470, 0.7410])
hold on
p1 = polyfit(strength_cats, hurricane_max, 1); 
x1 = linspace(0,6,100);
y1 = polyval(p1, x1);
plot(x1, y1, "--",'LineWidth', 2)
slope1 = p1(1);
text(0.25, 2, sprintf('Slope = %.2f', slope1))
xlim([0,6])
xlabel("Strength Category")
ylim([0,4])
ylabel("Max Storm Surge (ft)")
title("Storm Strength Category vs Water Level")
hold off

subplot(3,1,2)
plot(dist_cats, hurricane_max, ".", MarkerSize = 15)
text(dist_cats, hurricane_max, names_hurricane, 'VerticalAlignment', 'top', 'HorizontalAlignment','left','FontSize',8, 'Color', [0, 0.4470, 0.7410])
hold on
p2 = polyfit(dist_cats, hurricane_max, 1); 
x2 = linspace(0,6,100);
y2 = polyval(p2, x2);
plot(x2, y2, "--",'LineWidth', 2)
slope2 = p2(1);
text(0.1, 2, sprintf('Slope = %.2f', slope2))
xlim([0,6])
xlabel("Distance Category")
ylim([0,4])
ylabel("Max Storm Surge (ft)")
title("Storm Distance Category vs Water Level")
hold off

subplot(3,1,3)
plot(intensity, hurricane_max, ".", MarkerSize = 15)
text(intensity, hurricane_max, names_hurricane,'VerticalAlignment','bottom','HorizontalAlignment','center','FontSize',8, 'Color', [0, 0.4470, 0.7410])
hold on
p3 = polyfit(intensity, hurricane_max, 1); 
x3 = linspace(0,21,100);
y3 = polyval(p3, x3);
plot(x3, y3, "--",'LineWidth', 2)
slope3 = p3(1);
text(16, 3, sprintf('Slope = %.2f', slope3))
xlim([0,21])
xlabel("Intensity Category (Strength * Distance)")
ylim([0,4])
ylabel("Max Storm Surge (ft)")
title("Storm Aggregate Intensity Category vs Water Level")
hold off