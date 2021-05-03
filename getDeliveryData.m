function [dates, sums] = getDeliveryData()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

x = deliveryParser("https://impfdashboard.de/static/data/germany_deliveries_timeseries_v2.tsv");

t1 = datetime(2020,12,26); %first day of vaccinations
tnow = datetime();
tnow.Hour = 0;
tnow.Second = 0;
tnow.Minute = 0;
%%

x = sortrows(x,{'current_date','current_vac','Var3'},'ascend');

range = t1:tnow;
deldata = table();
vacdelindx = 1;

for t = range
   if(vacdelindx <= height(x) && t == table2array(x(vacdelindx,1)))
       % multiple manufacturers might deliver on the same day so we need to
       % loop
       vac = 0 ;
       
       while(t == table2array(x(vacdelindx,1)))

        vac = vac + table2array(x(vacdelindx,3));
        vacdelindx = vacdelindx + 1;
        
        if(vacdelindx > height(x))
            break;
        end
       end
       deldata = [deldata; table(t, vac)];
       
   else
       vac = 0;
       deldata = [deldata; table(t, vac)];
   end
end


% real addition
%sums = cumsum(table2array(deldata(:,2)));
% fancy Matlab stuff
sums = cumtrapz(table2array(deldata(:,2)));
dates = table2array(deldata(:,1));

end

