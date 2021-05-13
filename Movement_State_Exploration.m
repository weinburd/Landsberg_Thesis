%%this function is used to explore how local standard deviations and
%%locally-averaged velocities relate to heading directions, etc. Generally
%%used to explore how movement states can be inferred from velocity data.


function [localStdins, localVelocity, Heading] = Movement_State_Exploration(matNums, winSize, datfile)
localStdins =[]; %local-std instantaneous speed
instantVel = []; %instantaenous speed
localVelins = []; %local-average instantaneous speed
localVelocity = []; %Here we will compute a local-average of velocity not speed
Heading = []; %this is just heading direction
for m = matNums
M=(datfile{m,2});
    
l = winSize; %this is the window size for local velocity (the total window size is symmetrical about and includes the point of focus)
k = l; %this is window size for standard deviation

%m = 9 corresponds to the manual video, with a different scale
%factor
if m == 9
M(:,1,:)=M(:,1,:).*9.54;   
M(:,2,:)=M(:,2,:).*9.54; 
M(:,4,:)=M(:,4,:).*9.54; 
end

%%creating instant vel
xpos = M(:,1,:);
ypos = M(:,2,:);
ypos = ypos*-1;
%flag = M(:,3, :);
[~,~,xvel] = gradient(xpos);
[~,~,yvel] = gradient(ypos);
xvel = xvel*25; %convert to cm/s
yvel = yvel*25; %convert to cm/s


iv = (xvel.^2 + yvel.^2).^.5; %non-smoothed velocity



%%Here we compute a moving average and moving standard deviation of the velocities

%first we will do velocity not speed
localxVelocity = movmean(xvel,l,3,'omitNaN');
localyVelocity = movmean(yvel,l,3,'omitNaN');
localVelo = (localxVelocity.^2 + localyVelocity.^2).^.5;

%now we'll do local averages/standard deviations for speeds
localVel1 = movmean(iv,l,3,'omitNaN'); 
localStd1 = movstd(iv,k,0,3,'omitNaN'); 
flag = isnan(iv); %flag to make sure we don't assign time coordinates to points where we have no actual data
localVel1(flag) = NaN; %use flag to make sure we don't get average velocities where there is no data
localStd1(flag) = NaN;
localVelo(flag) = NaN;


h = M(:,5,:); %this is where we have already stored heading directions

%here we just convert to a column vector
localStd1 = localStd1(:);
localVelo = localVelo(:);
h = h(:);

%now we concatenate each matrix with the pre-existing values
localStdins = cat(1, localStdins,localStd1);
localVelocity = cat(1,localVelocity, localVelo);
Heading = cat(1,Heading,h);

end

end

