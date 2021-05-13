close all

addpath('../Dependencies/CircStat2012a')

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
number = 16;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set Up %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numNeighbors = 3;
state = 2;
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

angled = atan2(totalData(:,2), totalData(:,1));
angled(isnan(angled)) = [];

nn = length(angled);
n =     1;
phi = (-pi:.001:pi);
% angled1 = circ_vmrnd(pi/4, 1, nn);
%  angled2 = circ_vmrnd(5*pi/4, 1, nn);
%  angled = cat(1,angled1,angled2);
% polarhistogram(angled)

Ic1 = trigInt(angled,"c",n);
Is1 =  trigInt(angled,"s",n);
magI = (Ic1^2 + Is1^2)^.5;
phi0 = (1/n)*atan2(Is1,Ic1)

Itot = cos(n*phi)*Ic1 + sin(n*phi)*Is1;
plot(phi,Itot)

% bootTotal = bootstrp(100, @(samples) [trigComputeMag(samples,n),trigComputePhi(samples,n)], angled);
% disp("MagI")
% mean(bootTotal(:,1))
% std(bootTotal(:,1))
% disp("Phi0")
% mean(bootTotal(:,2))
% std(bootTotal(:,2))



% [pval,~] = circ_otest(angled)
% hp = polarhistogram(angled,50);
% minbin = min(hp.BinCounts);
% polarhistogram(angled,50);
% pax = gca;
% pax.ThetaAxisUnits = 'radians';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Labels %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gca, 'FontSize', ticklabelsize)
%xlabel('$\Delta$ x (cm)','FontSize',axislabelsize)
%ylabel('$\Delta$ y (cm)','FontSize',axislabelsize)
%xlim([0, 40])
%ylim([100, 10^6])
title([sprintf("%d Nearest Neighbor Angular Distribution",numNeighbors), (sprintf("for %s Locusts",st))],'FontSize',titlesize)

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

% filename = sprintf('fig%d_%d_neighbors_%s',number,numNeighbors,st);
% print(h,[filename, '.eps'],'-depsc')

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

function magI = trigComputeMag(angled,n)
Ic1 = trigInt(angled,"c",n);
Is1 =  trigInt(angled,"s",n);
magI = (Ic1^2 + Is1^2)^.5;
%phi0 = (1/n)*atan2(Is1,Ic1);
end

function phi0 = trigComputePhi(angled,n)
Ic1 = trigInt(angled,"c",n);
Is1 =  trigInt(angled,"s",n);
%magI = (Ic1^2 + Is1^2)^.5;
phi0 = (1/n)*atan2(Is1,Ic1);
end

function I = trigInt(angles, trigFlag, mode)
    N = length(angles);
    if trigFlag == "s"
        I = (1/N)*sum(sin(mode*angles));
    elseif trigFlag == "c"
        I = (1/N)*sum(cos(mode*angles));
    else
        error("Enter c or s for cosine or sine function.")
    end
end