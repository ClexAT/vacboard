function [deliveryhistory] = deliveryParser(source)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
file = urlwrite(source, "vacdel.csv");
deliveries = readtable("vacdel.csv");
%first line is header, we dont need that
%define indizes for vaccine types, these should not exceed 10ish so
%hardcoding is ok
comirnaty = 1;
moderna = 2;
astra = 3;
jensen = 4;

% matrix to store data points = deliveryhistory
% 1 = date, 2 = vac, 3 = count (overall germany)
deliveries(1,:) = [];
dates = table2array(deliveries(:,1));
vacs = table2array(deliveries(:,2));
count = table2array(deliveries(:,4));

x = sum(count);


current_date = datetime("1970-01-01");
current_vac = "none";
curidx = 0;

for index = 1:length(dates)
    if((dates(index) == current_date) && (vacs(index) == current_vac))
        deliveryhistory(curidx,3) = table(table2array(deliveryhistory(curidx,3)) + count(index));
    else
        current_date =  dates(index);
        current_vac = string(vacs(index));
        curidx = curidx + 1;
        deliveryhistory(curidx,:) = table(current_date, current_vac, count(index));
    end
end
end

