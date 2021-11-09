function palestra(filex)
close all
%filex='squat.csv' ;
T = readtable(filex);
 name_temp=strread(dir(filex).name,'%s','delimiter','.');
 name=string(name_temp(1));
 
 %Nome formattato correttamente 
 for k=1:strlength(name)
    if k==1 
        name{1}(k)=upper(name{1}(k));
    else
        name{1}(k)=lower(name{1}(k));
    end
 end

%formatta serie e rep
sxr=string(table2array(T(1:numel(T.Giorno),strmatch('SxR',T.Properties.VariableNames))));
SR=split(sxr,'x');
for i=1:numel(T.Giorno)
SET(i)=str2num(SR(i,1));
REP(i)=str2num(SR(i,2));
end

% writetable(T,'squat.csv')  
%A=table2array(T(2:5,2:3))
%boxplot(A)

%controlla le 'x'
%controlla che la lunghezza delle colonne sia uguale per tutte 

%impostiamo correttamente le date
for i=1:numel(T.Giorno)
%T.Date{i}=
datevec(i)=datetime(T.Giorno{i},'Format','dd-MM-uuuu');

%serie(i)=T(:,strmatch('Serie',T.Properties.VariableNames))
end
T.Date=datevec';

%rendere generalizzabile il codice
%cerco le colonne dove sono i dati numerici e le estraggo in una matrice
datigrezzi=table2array(T(1:numel(T.Giorno),strmatch('Serie',T.Properties.VariableNames)));
datigrezzi_2=split(datigrezzi,'x');
%---> convertire in numeri 
datigrezzirep=datigrezzi_2(:,:,1);
datigrezzirep(cellfun('isempty',datigrezzirep))={'NaN'};
datigrezzipeso=datigrezzi_2(:,:,2);
datigrezzipeso(cellfun('isempty',datigrezzipeso))={'NaN'};

for i=1:numel(datigrezzirep(:,1))
    for j=1:numel(datigrezzirep(1,:))
   datirep(i,j)=str2num(cell2mat(datigrezzirep(i,j)));
datipeso(i,j)=str2num(cell2mat(datigrezzipeso(i,j)));
    end
end


%rendere generalizzabile cercando T.nome

%eliminare gli zeri
figure()
boxplot(datipeso',datetime(datevec,'Format','dd-MM'),'MedianStyle','target')
%ylim([0 150]
%impostiamo il massimo centrando il grafico nella parte alta della figura
value=max(max(datipeso))-min(min(datipeso));
ylim([min(min(datipeso))-value max(max(datipeso))+value/2])
hold on
plot(nanmedian(datipeso'),'--r')
hold off
title(name)

figure()
plot(datevec,nanmean(datipeso'),'--b')
hold on 
plot(datevec,nanmean(datipeso'),'or')
ylim([min(min(datipeso))-value max(max(datipeso))+value/2])
title(name+' mean','from '+string(datevec(1))+' to '+string(datevec(length(datevec))))

figure()
%faccio la media pesando per le singole ripetizioni in ogni serie 
meanweigth=nansum((datipeso.*datirep)')./nansum(datirep');
plot(datevec,meanweigth,'--b')
hold on 
plot(datevec,meanweigth,'or')
ylim([min(min(datipeso))-value max(max(datipeso))+value/2])
title(name+' weigthted mean','from '+string(datevec(1))+' to '+string(datevec(length(datevec))))

figure()
plot(datevec,max(datipeso'),'--g')
hold on 
plot(datevec,max(datipeso'),'or')
ylim([min(min(datipeso))-value max(max(datipeso))+value/2])
title(name+' best of','from '+string(datevec(1))+' to '+string(datevec(length(datevec))))

figure()
plot(datevec,meanweigth,'or')
hold on 
plot(datevec,max(datipeso'),'^g')
plot(datevec,max(datipeso'),'--g')
plot(datevec,meanweigth,'--b')
ylim([min(min(datipeso))-value max(max(datipeso))+value/2])
title(name+' mean vs max','from '+string(datevec(1))+' to '+string(datevec(length(datevec))))
legend('Mean value', 'Max value')

%tonnellaggio%
%
for i=1:numel(datipeso(:,1))
ton(i)=nansum(datipeso(i,:).*datipeso(i,:));
end

figure()
plot(datevec,ton,'--k')
hold on 
plot(datevec,ton,'^r')
ylim([(min(ton)-(max(ton)-min(ton))/2) (max(ton)+(max(ton)-min(ton))/2)])
title(name+' ton')

%export file
writetable(T,strcat(name,'_edited','.csv'))  

%fit polinomiale 
for i=1:numel(datevec)
day_val(i)=days(datevec(i)-datevec(1));
end
f1=fit(day_val',meanweigth','poly1');
f1_max=fit(day_val',max(datipeso')','poly1');
f2=fit(day_val',meanweigth','poly2');
f2_max=fit(day_val',max(datipeso')','poly2');
figure()
subplot(2,1,1)
plot(linspace(min(day_val),max(day_val),100),f1(linspace(min(day_val),max(day_val),100)),'-r');
hold on
plot(linspace(min(day_val),max(day_val),100),f1_max(linspace(min(day_val),max(day_val),100)),'--g');
plot(day_val,meanweigth,'ob')
hold off
xlim([0 max(day_val)+10])
title(name+' linear growth model');
subplot(2,1,2)
plot(linspace(min(day_val),max(day_val),100),f2(linspace(min(day_val),max(day_val),100)),'-r');
hold on
plot(linspace(min(day_val),max(day_val),100),f2_max(linspace(min(day_val),max(day_val),100)),'--g');
plot(day_val,meanweigth,'ob')
xlabel('Days')
legend('Mean growth model','Max growth model','Mean value','Location','southeast')
xlim([0 max(day_val)+10])
title(name+' quadratic growth model');

degree=1; %grado del polinomio interpolante
fp=polyfit(day_val,meanweigth,degree);
plotfp = polyval(fp,linspace(min(day_val),max(day_val)*1.2,200));
figure()
plot(day_val,meanweigth,'or')
hold on
plot(linspace(min(day_val),max(day_val)*1.2,200),plotfp,'b')
%%TITOLO CON IL POLINOMIO
    poly=''
for i=1:degree+1   
    if i==degree+1
    poly=strcat(poly,'+',string(fp(i)));
   elseif i==1
     poly=strcat(string(fp(i)),'\cdot x^',string(degree+1-i));
    else
        poly=strcat(poly,'+',string(fp(i)),'\cdot x^',string(degree+1-i));
    end
end
poly=strrep(poly,'x^1','x'); %sisitemiamo il polinomio
polynom=strcat('$',poly,'$');
title(name+', '+ degree + ' degree poly growth model :=',polynom);
subtitle(polynom,'Interpreter','latex')

% 2D interp
for i=1:numel(datipeso(1,:))
D1(:,i)=[day_val'];
end

for i=1:numel(datipeso(:,1))
    R1(i,:)=1:1:numel(datipeso(1,:));
end

D=D1(:);
R=R1(:);
dati=datipeso(:);
dati(isnan(dati))=0;

f=fit([D, R],dati(:),'linearinterp');
figure()
plot(f,[D, R],dati(:))
hold on
ylabel('Repetition')
xlabel('Days')
zlabel('Weigth')
zlim([mean(dati(:))-(max(dati(:))/2) mean(dati(:))+(max(dati(:))/2)])
title(name+' days vs repetition');

%tasso di incremento
indice=1:4:numel(day_val); %aumenta di 4 considerando le sedute a distanza di 4 settimane (1 mese)
maxpeso=max(datipeso');
pesoincremento=maxpeso(indice);
meseincremento=datetime(datevec(indice),'Format','MMMM');
for i=1:(numel(pesoincremento)-1)
    incremento(i)=(pesoincremento(i+1)-pesoincremento(i))/pesoincremento(i);
    testoincremento(i)=strcat('increment between'," ",string(meseincremento(i)),' -'," ",string(meseincremento(i+1)),' ='," ",string(incremento(i)*100),'%');
end
testoincremento' 


%export fig
clear figHandles
clear input_file
input_file={};
figHandles = findobj(0,'Type','figure');

 for i = 1:(numel(figHandles))
     %i
    %export_fig(fn, '-pdf', figHandles(i), '-append')
     %print(figure(i),'-bestfit', '-append', '-dpdf','figure.pdf');
     %print(figure(i),'-bestfit', '-dpdf',strcat('figure',num2str(i),'.pdf'));
     name_file=strcat('figure',num2str(i),'.pdf');
     saveas(figure(i),name_file,'pdf');
     
     %saveas(figure(i),get(figure(i), 'Name' ),'fig');
     saveas(figure(i),strcat('fig/',name,'_','figure',num2str(i),get(figure(i), 'Name' )),'fig');
    input_file{i}=name_file;
 end
mergePdfs(input_file, strcat(name,'.pdf'));

for i = 1:(numel(figHandles))
    delete(input_file{i})
end

end
%tonnellaggio
