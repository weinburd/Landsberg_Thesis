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
number = 12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Up %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numNeighbors = 1;
state = 1;
if state == 0
    st = 'Stopped'
elseif state == 1
    st = 'Crawling'
elseif state == 2
    st = 'Hopping'
end


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
   focalmat1 = data_final{m,2};
   focalmat2 = data_final{m,3};
   individualData = neighborOrganizer(focalmat1,focalmat2,numNeighbors,state);
   totalData = cat(1,totalData,individualData);
end
% 
% distanced = (totalData(:,1).^2 + totalData(:,2).^2).^.5;
% DDistance = cat(2,DDistance,distanced);
% mean(distanced,'omitnan')
% median(distanced,'omitnan')
% std(distanced,'omitnan')



hist3(totalData,'Edges',{-6.5:0.8125:6.5 -6.5:0.8125:6.5},'CdataMode','auto');
pbaspect([1 1 1])
colorbar
%caxis([0,33])
view(2)
annotation('arrow',[.4355,.4355],[.461,.55],'color','red','LineWidth',3)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Labels %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'FontSize', ticklabelsize)
xlabel('$\Delta$ x (cm)','FontSize',axislabelsize)
ylabel('$\Delta$ y (cm)','FontSize',axislabelsize)
%xlim([0, 40])
%ylim([100, 10^6])
title([sprintf("%d Nearest Neighbor Locations for",numNeighbors), (sprintf("%s Locusts",st))],'FontSize',titlesize)

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

filename = sprintf('fig%d_%d_neighbors_%s',number,numNeighbors,st);
print(h,[filename, '.eps'],'-depsc')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Associated Function %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = neighborOrganizer(M,Mneigh,numNeighbors,state)
    d = [NaN,NaN];
    for n = 1:numNeighbors
        deltaX = Mneigh(:,n,:);
        deltaX(M(:,6,:)~= state) = NaN;
        deltaX = deltaX(:);
        deltaY = Mneigh(:,n+10,:); %plus 10 since we store 10 nearest neighbors
        deltaY(M(:,6,:)~= state) = NaN;
        deltaY = deltaY(:);
        d = cat(1,d,[deltaX,deltaY]);
    end
end