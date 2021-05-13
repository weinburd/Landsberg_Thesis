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
number = 13;
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
  focalMat =  data_final{m,2};
  [indData1,indData2,indData3,indData4,indData5] = trackInfo(focalMat);
  totalData = cat(1,totalData,indData5(:));
end
mean(totalData,'omitnan')
median(totalData,'omitnan')
std(totalData,'omitnan')
histogram(totalData,200);
pd = fitdist(totalData(totalData>2),'Normal');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Labels %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'FontSize', ticklabelsize)
xlabel('Speed (cm/s)','FontSize',axislabelsize)
ylabel('Counts','FontSize',axislabelsize)
xlim([0, 25])
%ylim([10^3, 10^6])
title("Histogram of Track-Averaged Speeds (cm/s)",'FontSize',titlesize)

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
%%% Functions %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [trackVel, trackDisp, trackDist, tmFramed, trackSpeed] = trackInfo(M)
    xpos = M(:,1,:);
    ypos = M(:,2,:);
    ypos = ypos*-1;
    [~,~,xvel] = gradient(xpos);
    [~,~,yvel] = gradient(ypos);
    xvel = xvel*25;
    yvel = yvel*25;
    tVelx = mean(xvel,3,'omitnan');
    tVely = mean(yvel,3,'omitnan');
    tVelx = tVelx(:);
    tVely = tVely(:);
    trackVel = (tVelx.^2 +tVely.^2).^.5;
    spd = (xvel.^2+yvel.^2).^.5;
    trackSpeed = mean(spd,3,'omitnan');
    tmFramed = ~isnan(xpos);
    tmFramed = sum(tmFramed,3,'omitnan');
    tmFramed = tmFramed(:);
    tmFramed = tmFramed*(1/25);
    trackDisp = tmFramed.*trackVel;
    trackDist = tmFramed.*trackSpeed;
end


