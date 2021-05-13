addpath("Data")
%%The matrix that stores all the data will called data_final
%matNums = [1:8];%the matrices you wish to infer data and nearest neighbors for
%note we drop matrix 2 for actual figures/computations, since it is a subset of matrix 7 in data_final
matNums = [1];
load('data_clean.mat')
%load('data_final.mat') %uncomment this to add to an existing data set
data_final(matNums,1) = data_clean(matNums,1);



%%Here we add the inferred data (sans nearest neighbor) to the second
%%column of the cell array, data_final. Columns represent: xpos, ypos,flag,
%%speed, heading direction, stopped/walking/hopping, acceleration parallel to
%%direction of motion, acceleration perpendicular to direction of motion.
%%Columns 1-3 are directly copied from data_clean.mat, columns 4-8 are new,
%%inferred data.

%%We also add the k nearest neighbors' x an y distances from the focal
%%locust. They are placed in the third column of the cell array. Each row
%%represents a locust, each column holds x1, x2, ...xk, y1, y2, ...yk. The
%%matrix is number of frames deep.

%Here we compute inferred data
for m = matNums
    cmat = dataForm(data_clean{m,2},1);
    data_final{m,2} = cmat;
    
end

%here we compute nearest niehgbors:
k = 10; %number of nearest neighbors' positions you want to find
for m = matNums
   cmat = NearNeighbors(data_clean{m,2},k);
   data_final{m,3} = cmat;
end

%%saving as data_final.mat
datafile = 'Data\data_final.mat';
save(datafile, 'data_final', '-v7.3');

%M is your output matrix. 
%%Put smoothFlag = 1 if you want to smooth your data when computing velocity/acceleration
%% Put 0 if you do not want to use smoothed data to compute velocity and acceleration
function M = dataForm(Mfinal3D,smoothFlag)
M = Mfinal3D; %%set M equal to your imported and cleaned 3D matrix
s = size(M);
    
%%separating xpos, ypos, and creating xvel yvel and total velocity
%Add a speed and direction (rad) column to M
if smoothFlag
    KeepNaN = double(~isnan(M(:,1,:)));
    KeepNaN(KeepNaN==0) = NaN;
    xsmooth = smoothdata(M(:,1,:),3,"gaussian",8,'omitnan');
    ysmooth = smoothdata(M(:,2,:),3,"gaussian",8,'omitnan');
    xsmooth = xsmooth.*KeepNaN;
    ysmooth = ysmooth.*KeepNaN;
    xpos = xsmooth;
    ypos = ysmooth*-1;%just to flip the axis so up is positive
    
else
    %%switch to use smoothed positions (must run Smoothing.m first)
    xpos = M(:,1,:);
    ypos = M(:,2,:);
    ypos = ypos*-1;
end
%flag = M(:,3, :);
[~,~,xvel] = gradient(xpos);
[~,~,yvel] = gradient(ypos);
xvel = xvel*25; %convert to cm/s
yvel = yvel*25; %convert to cm/s


%Now we'll look at the central difference to get acceleration
xacc = zeros(size(xpos,1),1,size(xpos,3));
for j = 2:size(xpos,3)-1
    xacc(:,1,j) = (xpos(:,1,j+1)-2*xpos(:,1,j)+xpos(:,1,j-1));    
end
xacc(:,1,1) = xpos(:,1,2)-xpos(:,1,1);
xacc(:,1,size(xpos,3)) = xpos(:,1,size(xpos,3))-xpos(:,1,size(xpos,3)-1);

yacc = zeros(size(ypos,1),1,size(ypos,3));
for j = 2:size(ypos,3)-1
    yacc(:,1,j) = (ypos(:,1,j+1)-2*ypos(:,1,j)+ypos(:,1,j-1));    
end
yacc(:,1,1) = ypos(:,1,2)-ypos(:,1,1);
yacc(:,1,size(ypos,3)) = ypos(:,1,size(ypos,3))-ypos(:,1,size(ypos,3)-1);


vel = (xvel.^2 + yvel.^2).^.5; %speed of locust in cm/frm
direct = atan2(yvel,xvel); %direction locst is moving (rad)
vvec = [cos(direct),sin(direct)];
xacc = xacc*25*25;%swithc to cm/s^2
xacc = xacc*25*25;%swithc to cm/s^2

avec = cat(2,xacc,yacc);

zcord = zeros(size(avec,1),1,size(avec,3));
avec = cat(2,avec,zcord);
vvec = cat(2,vvec,zcord);
apar = dot(avec,vvec,2);
aperp = cross(avec,vvec,2);
aperp = aperp(:,3,:);
aforce = cat(2,apar,aperp);


direct(vel==0) = NaN; %get rid of 0,0 velocities
z = (vel>.01); %logical matrix that keeps represents only non-zero velocities
trackVel = mean(vel,3,'omitnan');
M = cat(2,M,vel);
M = cat(2,M,direct);


l = 7; %this is the window size for local velocity (the total window size is symmetrical about and includes the point of focus)
k = l; %this is window size for standard deviation
%using unsmoothed data
[~,~,xvelns] = gradient(M(:,1,:));%creating non-smoothed velocity data
[~,~,yvelns] = gradient(M(:,2,:));
xvelns = xvelns*25;%convert to cm/s
yvelns = yvelns*25;
nsv = (xvelns.^2 + yvelns.^2).^.5; %non-smoothed speed
localxVelocity = movmean(xvelns,l,3,'omitNaN');
localyVelocity = movmean(yvelns,l,3,'omitNaN');
localxVelocity = localxVelocity*25;
localyVelocity = localyVelocity*25;
localVel = (localxVelocity.^2 + localyVelocity.^2).^.5;%local mean non-smoothed velocity
localStd = movstd(nsv,k,0,3,'omitNaN'); 
flag = isnan(vel); %flag to make sure we don't assign time coordinates to points where we have no actual data
localVel(flag) = NaN; %use flag to make sure we don't get average velocities where there is no data
localStd(flag) = NaN;



%%Using locally-averaged instantaneous velocities to determine if a locust is stopped,
%%walking, or hopping. Outputs a num locusts x 2 x num frames matrix, where
%%the first column is 0 = stopped, 1 = walking, or 2 = hopping and the
%%second column is the time
go = .0533;%% locusts with low standard deviations (less than dev) and locally-averaged velocities greater than this (in cm/s) are considered walking
dev = 6;%%locally-averaged standard deviations greater than this (in cm/s) are considered hopping
moving = zeros(s(1),1,s(3));
moving(localStd>dev) = 2;%set the hoppers
moving(localVel>go & localStd<=dev) = 1;%set the walkers
moving(isnan(vel))= NaN; %set the NaNs
moving(moving==10)=NaN;
placeHold = NaN(size(moving,1),1,size(moving,3));
moving = cat(2,moving, placeHold);
for tm = 0:size(moving,3)-1
    appendable = tm*ones(s(1),1);
    moving(:,2,tm+1) = appendable;
end
ph = moving(:,2,:);
ph(flag) = NaN;
moving(:,2,:)= ph;


%%Here we calculate the intervals over which a locust is in each one of
%%these states. This outputs a variable row # x 3 column matrix. The first
%%column corresponds to stopping, the second walking, and the third
%%hopping. If a row was, for example [NaN 14 NaN], this means a locust
%%walked for 14 frames. Each row should have 2 NaN entries and 1 positive
%%integer entry.
siz = size(moving);
Durat = [NaN NaN NaN];
for loc = 1:s(1)
    state = moving(loc,1,1);
    leng = 1;
    for t = 2:siz(3)
        if isnan(state) && t ~= siz(3)
            continue
        end
        if moving(loc,1,t) == state
            leng = leng + 1;
        elseif state == 0
            Durat = [Durat; [leng NaN NaN]];
            leng = 1;
            state = moving(loc,1,t);
        elseif state == 1
            Durat = [Durat; [NaN leng NaN]];
            leng = 1;
            state = moving(loc,1,t);
        elseif state == 2
            Durat = [Durat; [NaN NaN leng]];
            leng = 1;
            state = moving(loc,1,t);
        end
    end
            
end
Durat(1,:)=[];
mean(Durat, 'omitnan')

sch = moving(:,1,:); %this is a num locusts x 1 x num frames matrix. Each value corresponds to stop (0), walk(1), or hop(2) for a locust at a given frame
Durat = Durat; %this is a variable size matrix. It has 3 columns, however. The first column's values are the length of stop, the second column's values are the length of walks, and the third columns values are the length of hopping (in frames).
M = cat(2,M,sch);%appending sch to M

%%Interpolating Heading Direction

%starts as 0 tag, go until non zero tag
s = size(M);
for locust = 1:s(1)
    for timestep = 1:s(3)
        if M(locust, 6, timestep) == 0 
            ahead = sum(M(locust, 6, timestep:end), 'all','omitnan')>0;
            behind = sum(M(locust, 6, 1:timestep), 'all','omitnan')>0;
            %if ~ahead && ~behind %if never moving, eliminate
                %M(locust,:,:) = [];
           if ahead && ~behind %if only future position data, set initial angles to that future angle
            	k = find(M(locust,6,timestep+1:end),1,'first');
                M(locust, 5, timestep) = M(locust,5,timestep+k);
            elseif ~ahead && behind %if only previous data, set angle to past angle
                M(locust, 5, timestep) = M(locust, 5, timestep-1);
            elseif ahead && behind %if previous and future data, interpolate 
                disp("alert")
                k = find(M(locust,6,timestep+1:end),1,'first');
                b = find(M(locust,6,1:timestep),1,'last');
                disp(timestep)
                disp(k)
                disp(b)
                M(locust, 5, timestep) = M(locust,5,timestep-1)+(M(locust,5,timestep+k)-M(locust,5,b))/(k+timestep-b); 
            end
        end
    end
end

M = cat(2,M,aforce);


end

function NN = NearNeighbors(Mfinal3D,numNeighbors)
radius = 7.5; %radius you want to search use to search for neighbors (cm) and for the rectangle bit
scalefactor = 18.43;
dimensions = [1824,1026]/scalefactor;
innerAr = Mfinal3D(:,1,:) > radius & Mfinal3D(:,1,:) < dimensions(1)-radius & Mfinal3D(:,2,:) > radius & Mfinal3D(:,2,:) < dimensions(2)-radius;
innerAr = double(cat(2, innerAr, innerAr, innerAr));
innerAr(innerAr==0)=NaN;
innerNeigh = Mfinal3D(:,1:3,:);
innerNeigh = innerNeigh.*innerAr;
s = size(Mfinal3D);

%for fixed number of nearest neighbors
NearestDist = [];
for j = 1:s(3)
    Far = [];
    for i = 1:s(1)
        comparison = Mfinal3D(:,1:2,j);
        comparison(i,:)=[];%%comparing to all other points at the given time
        current = innerNeigh(i,1:2,j); 
        ID = knnsearch(comparison,current, 'K', numNeighbors,'Distance','euclidean');
        block = [];
        for n = 1:numNeighbors
            currN = comparison(ID(n),:);
            displx = currN(1) - current(1);
            disply = currN(2) - current(2);
            dist = (disply.^2+displx.^2).^.5;
            angl = atan2(-disply,displx);
            block = [block dist angl];
        end
        Far = [Far; block];
    end
    NearestDist = [NearestDist Far];
end

placeHold = zeros(s(1),numNeighbors*2,s(3));
Mfinal3D = cat(2,Mfinal3D,placeHold);

for frm = 1:s(3)
    Mfinal3D(:,s(2)+1:size(Mfinal3D,2),frm) = NearestDist(:,1+(frm-1)*numNeighbors*2:+frm*numNeighbors*2);
end


%%Here we make a 2d histogram of where locusts' nearest neighbors are
%First we have to find the difference between neighbor angle and angle
%locust is facing, then shift it by pi/2
strt = size(Mfinal3D,2)-(numNeighbors*2)+1;
NeighAngles = Mfinal3D(:,strt+1:2:end,:); %angle from locust to its neighbor
xpos = Mfinal3D(:,1, :);
ypos = Mfinal3D(:,2, :);
[~,~,xvel] = gradient(xpos);
[~,~,yvel] = gradient(ypos);
vel = (xvel.^2 + yvel.^2).^.5; %speed of locust
HeadAngles = atan2(-yvel,xvel); %direction locst is moving (rad)
z = (vel<-.01); % NEW: get rid of this since we have interpolation logical matrix that keeps represents only non-zero velocities
HeadAngles(z) = mean(HeadAngles(~z),'all','omitnan');
%This is to make sure we duplicate the heading angles for the number of
%nearest neighbor angles we have
HAngles = [];
for n = 1:numNeighbors
    HAngles = cat(2,HAngles,HeadAngles);
end
ShiftAngles = pi()/2 + HAngles - NeighAngles;
R = Mfinal3D(:,strt:2:end,:);
% NNx = R.*cos(Mfinal3D(:,strt+1:2:end,:));
% NNy = R.*sin(Mfinal3D(:,strt+1:2:end,:));
NNx = R.*cos(ShiftAngles);
NNy = R.*sin(ShiftAngles);
%NNx = NNx(:);
%NNy = NNy(:);
NN = [NNx NNy];
%NN = NN(~isnan(NN)); %remove NaN values
end

