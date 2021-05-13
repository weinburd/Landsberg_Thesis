close all

%addpath('functions','data')

set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex'); 

titlesize = 12;
axislabelsize = 10;
fontSize = axislabelsize;
ticklabelsize = 8;
subfiglabelsize = 12;

%linewidth
lwidth = 1.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Data to be Plotted %%%
matNums = [1,3,4,5,6,7,8];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Figure 1 %%%
number = 6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Up %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


h = figure(number);
set(h,'Units','Inches');
pos = get(h, 'Position');
set(h,'PaperPositionMode','Manual') % Setting this to 'manual' unlinks 'Position' (what gets displayed) and 'PaperPosition' (what gets printed)
set(h,'PaperPosition',[ 0 0 4 3]);
set(h,'Position',[ 0 0 4 3]);
get(h,'Position')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plotting %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Here we assemble the data (this is nearest neighbor distance data)
totalData = [];
for m = matNums
   focalmat = data_final{m,2};
   individualData = StateDrt(focalmat);
   totalData = cat(1,totalData,individualData);
end
a = totalData(:,1);
a(isnan(a))=[];
cdfplot(a)
[parmHat,parmCI] = wblfit(a)
[parmHat2,parmCI2] = lognfit(a)
[parmHat3,parmCI3] = gamfit(a)
xp = [0.04:.01:11.32];
wbp = cdf('Weibull',xp,parmHat(1),parmHat(2));
gp = cdf('Gamma',xp,parmHat3(1),parmHat3(2));
ln = cdf('Lognormal',xp,parmHat2(1),parmHat2(2));

test_cdf = makedist('Weibull','a',parmHat(1),'b',parmHat(2));
[~,pv1] = kstest(a,'CDF',test_cdf)
test_cdf = makedist('Lognormal','mu',parmHat2(1),'sigma',parmHat2(2));
[~,pv2] = kstest(a,'CDF',test_cdf)
test_cdf = makedist('Gamma','a',parmHat3(1),'b',parmHat3(2));
[~,pv3] = kstest(a,'CDF',test_cdf)


hold on
plot(xp,wbp,'--r','LineWidth',1)
plot(xp,gp,'--g','LineWidth',1)
plot(xp,ln,'--m','LineWidth',1)
legend("Stop Duration CDF","Weibull","Gamma","Lognormal")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Labels %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'FontSize', ticklabelsize)
xlabel('Duration (s)','FontSize',axislabelsize)
ylabel('Fraction of Data','FontSize',axislabelsize)
xlim([0, 5])
%ylim([100, 10^6])
title('CDF of Durations of Locust Stops','FontSize',titlesize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Touch Up %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %remove whitespace
    ax = gca;
    outerpos = ax.OuterPosition;
    ti = ax.TightInset; 
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save Figure %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filename = sprintf('fig%d',number);
print(h,[filename, '.eps'],'-depsc')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Associated Function %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stateDurations = StateDrt(M)
stateDurations = NaN(size(M,1)*size(M,3),3);
states = M(:,6,:);
states = permute(states,[3,2,1]);
states = transpose(states(:));
for st = 0:2
    start1 = strfind([0,states==st],[0 1]);
    end1 = strfind([states==st,0],[1 0]);
    d = transpose(end1 - start1 + 1);
    d = d.*(1/25);
    stateDurations(1:size(d,1),st+1) = d;
end
end