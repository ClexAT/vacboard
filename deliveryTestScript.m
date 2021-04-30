
x = deliveryParser("https://impfdashboard.de/static/data/germany_deliveries_timeseries_v2.tsv");

t1 = datetime(2020,12,26); %first day of vaccinations
tnow = datetime();
tnow.Hour = 0;
tnow.Second = 0;
tnow.Minute = 0;
%%

range = t1:tnow;
deldata = table();
vacdelindx = 1;

for t = range
    t
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



cum = cumtrapz(table2array(deldata(:,2)));

tab = [deldata(:,1),table(cum)];
plot(table2array(deldata(:,1)), cum);