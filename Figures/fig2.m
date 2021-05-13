close all
addpath('../Dependencies/CircStat2012a')
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
%%% Figure 2 %%%
number = 2;
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
%%Here we assemble the data (this is speed data)
totalData = [];
for m = matNums
   focalmat = data_final{m,2};
   individualData = focalmat(:,5,:);
   individualData = individualData(:);
   totalData = cat(1,totalData,individualData);
end
totalData = totalData(:);
totalData(isnan(totalData)) = [];
hst = polarhistogram(totalData(:),100)
hct = hst.BinCounts;
hbe = hst.BinEdges;
hb2 = hbe(1:end-1) + diff(hbe) / 2;

pax = gca;
pax.ThetaAxisUnits = 'radians';

%%computing some circular statistics
sts = circ_stats(totalData(:));
circm = circ_mean(totalData(:))
%bootstrapping the mean angle and polarization to find its standard deviation
bootmean = bootstrp(100,@circ_mean,totalData(:));
cr = circ_r(totalData(:),[],[],1)
bootpolar = bootstrp(100,@circ_r,totalData(:));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Labels %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'FontSize', ticklabelsize)
%xlabel('Speed (cm/s)','FontSize',axislabelsize)
%ylabel('Counts','FontSize',axislabelsize)
%xlim([0, 40])
%ylim([100, 10^6])
title("Polarhistogram of Locusts' Heading Direction",'FontSize',titlesize)

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
