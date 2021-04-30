clc;
clear all;
 
%read file from RKI Server Vaccination Data
file = urlwrite("https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Impfquotenmonitoring.xlsx?__blob=publicationFile", "tempvac.xlsx");
vacdata = xlsread("tempvac.xlsx", "Impfungen_proTag");
idxvac = min(find(isnan(vacdata))) -1 ; %length of relevant list items
vacdata = vacdata(1:(idxvac),:); %last two lines are useless
ndays = length(vacdata); %number of days since first vaccination

%read file from RKI Server 7 day Incidence data
file2 = urlwrite("https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Daten/Altersverteilung.xlsx?__blob=publicationFile", "tempin.xlsx");
indata = xlsread("tempin.xlsx", "7-Tages-Inzidenz");
idxin = length(indata); %length of relevant data
w1 = datetime(2020,3,8); %week 1 of data
wrange = w1 + days(1:7:(idxin*7));

[deldates, delsums] = getDeliveryData();

%date range
t1 = datetime(2020,12,27); %first day of vaccinations
drange = t1 + days(1:ndays);

%remarkable dates
remDates(1) = datetime(2021,03,23);
remName(1) = "Astrazenca used again";

remDates(end+1) = datetime(2021,03,11);
remName(end+1) = "J&J approval";

remDates(end+1) = datetime(2021,03,6);
remName(end+1) = "First Testkits sold";

remDates(end+1) = datetime(2021,03,19);
remName(end+1) = "Astrazenca used halted";

remDates(end+1) = datetime(2021,03,30);
remName(end+1) = "AZ use halted for under 60y/o";

%remDates(end+1) = datetime(2021,04,04);
%remName(end+1) = "Easter Sunday";
remDates(end+1) = datetime(2021,04,06);
remName(end+1) = "GPs start to vaccinate";

remDates(end+1) = datetime(2021,04,20);
remName(end+1) = "EMA confirms J&J usage";

% lin reg
favg = fitlm(1:100, vacdata(1:100,3));
favg2 = fitlm(100:ndays, vacdata(100:end,3));
drange2 = drange(100:end);
linrange = drange(1:100);
%poly regreation
p = polyfit(1:ndays,vacdata(:,3)',15);
pfit = polyval(p, 1:ndays);

%moving average
mm = movmean(vacdata(:,3), 7);

%plot data
figure;
hold on
grid on
title("Verabreichte Impfdosen pro Tag");
plot(drange, vacdata(:,3));
plot(linrange, favg.Fitted);
plot(drange2, favg2.Fitted);
%plot(drange, pfit);
plot(drange, mm);
for i=1:length(remDates)
    xl(i) = xline(remDates(i), ':' ,remName(i));
    xl(i).LabelVerticalAlignment = 'bottom';
    xl(i).LabelHorizontalAlignment = 'center';
end
legend("raw", "lin fit pre GP Vaccing", "linfit after GP Vaccing", "Moving Average", "Location", "northwest");
xlabel("Datum");
ylabel("Verabreichte Impfdosen");
hold off

%cumulate and find quadratic fit 60 days
rdays = 1:ndays;
sum = cumtrapz(vacdata(:,3)');
p = polyfit(rdays,sum,3);
extrapolate = polyval(p, 1:(ndays+90));

%cumulate and find quadratic fit excluding last 14 days
rdays = 1:(ndays-14);
sum14 = cumtrapz(vacdata(1:(end-14),3)');
p = polyfit(rdays,sum14,3);
extrapolate14 = polyval(p, 1:(ndays+90));


%plot
figure;
hold on
grid on
axis tight
title("Kumulierte Impfungen (mit 30 Tage Prognose)");
plot(t1 + days(1:ndays+90),extrapolate, "--"); 
plot(t1 + days(1:ndays+90),extrapolate14, "--"); 
plot(drange, sum, "color", "black");
stairs(deldates, delsums, "color", "red");
xlabel("Datum");
ylabel("Verabreichte Impfdosen");
for i=1:length(remDates)
    xl(i) = xline(remDates(i), ':' ,remName(i));
    xl(i).LabelVerticalAlignment = 'bottom';
    xl(i).LabelHorizontalAlignment = 'center';
end
legend("quadratic fit + extrapolation","quadratic fit + extrapolation (minus last two weeks)", "raw", "Vaccines in stock", "Location", "northwest");
hold off

%% plot
figure;
hold on
axis tight
title("7 Tage Inzidenz nach Altergruppe ab 50 Jahre");
plot(wrange,indata(2:10,:)); 
xlabel("Datum");
ylabel("Verabreichte Impfdosen");
for i=1:length(remDates)
    xl(i) = xline(remDates(i), ':' ,remName(i));
    xl(i).LabelVerticalAlignment = 'bottom';
    xl(i).LabelHorizontalAlignment = 'center';
end
legend("90+", "85-89", "84-80", "79-75", "74-70", "69-65", "64-60", "59-55", "54-50", "Location", "northwest");
hold off

%plot
figure;
hold on
axis tight
title("7 Tage Inzidenz nach Altergruppe bis 50 Jahre");
plot(wrange,indata(11:20,:)); 
xlabel("Datum");
ylabel("Inzidenz");
for i=1:length(remDates)
    xl(i) = xline(remDates(i), ':' ,remName(i));
    xl(i).LabelVerticalAlignment = 'bottom';
    xl(i).LabelHorizontalAlignment = 'center';
end
legend("49-45", "44-40", "39-35", "34-30", "29-25", "24-20", "19-15", "14-10", "9-5", "4-0", "Location", "northwest");
hold off

oldin = mean(indata(2:5,:));
youngin = mean(indata(6:20,:));

figure;
hold on
axis tight
title("7 Tage Inzidenz Jung gegen Alt");
plot(wrange,[oldin; youngin]'); 
xlabel("Datum");
ylabel("Inzidenz");
for i=1:length(remDates)
    xl(i) = xline(remDates(i), ':' ,remName(i));
    xl(i).LabelVerticalAlignment = 'bottom';
    xl(i).LabelHorizontalAlignment = 'center';
end
legend("+70y average", "69y-0y average", "Location", "northwest");
hold off
%%


%find poly fit for inzidence
p = polyfit((idxin-10):idxin,indata(1,(end-10):end),3);
extrapolate_inzidence = polyval(p, (idxin-10):idxin+4);
extwrange = w1 + days(((idxin-11)*7):7:((idxin+3)*7));

figure;
hold on
axis tight
title("7 Tage Inzidenz Gesamt");
plot(wrange,indata(1,:)); 
plot(extwrange,extrapolate_inzidence); 
xlabel("Datum");
ylabel("Inzidenz");
for i=1:length(remDates)
    xl(i) = xline(remDates(i), ':' ,remName(i));
    xl(i).LabelVerticalAlignment = 'bottom';
    xl(i).LabelHorizontalAlignment = 'center';
end
legend("Incidence", "Inciedence Poly Fit", "Location", "northwest");
hold off

