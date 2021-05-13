%%%Data Cleaning (JBL July 14, 2020)
addpath("Data")
%set matNums equal to the indices of the matrices you wish to clean. These
%matrices will be placed into data_clean, with the first column
%corresponding the matrices' names and the second the actual clean
%matrices. The cleaned matrices have the format number of locusts X 3 X
%number of frames. The 3 columns are x, y , and a flag for missing data to
%be interpolated (2), data from when a locust is present (1), and 
%absent data because locust is not in frame (0).

load('data_rough.mat')
%matNums = [1:8];%matrices you wish to clean 
matNums = [1];
%note we drop matrix 2 for actual figures/computations, since it is a subset of matrix 7 in data_final
%load('data_clean.mat') %uncomment this to add to an existing data set
data_clean{matNums,1} = data_rough{matNums,1};

%%the function dataCleantakes a matrix with each row corresponding to a locust
%%and going in order time step, x pos, y pos, time step, xpos, ypos...

for m = matNums
    cmat = dataClean(data_rough{m,2});
    data_clean{m,2} = cmat;
end


% data_clean_radstudy = cell(size(data_rough_rad,1),size(data_rough_rad,2));
% data_clean_radstudy(:,1) = data_rough_rad(:,1);
% data_clean_radstudy(:,3) = data_rough_rad(:,3);

% for g = 1:size(data_rough_rad,1)
%     fmat = data_rough_rad{g,2};
%     for rw = 1:size(fmat,1)
%         if (fmat(rw,end)==0 && fmat(rw,end-1)==0 && fmat(rw,end-2)==0)
%            fmat(rw,end-2:end) = NaN(1,3); 
%         end
%     end
%     data_clean_radstudy{g,2} = dataClean(fmat);
% end


%saving as data_clean.mat
datafile = 'Data\data_clean.mat';
save(datafile, 'data_clean');

%%this part uses a matrix with each row corresponding to a locust
%%and going in order time step, x pos, y pos, time step, xpos, ypos...

function Mfinal3D = dataClean(Import)
Minit = Import; %%set Minit to the name of your imported csv file (imported as numerical matrix)
Minit(:,2:3:end)= (1/18.4).*Minit(:,2:3:end);
Minit(:,3:3:end)= (1/18.4).*Minit(:,3:3:end);
%convert to seconds, move centimeter conversion 
if isnan(mean(Minit(1,:),'all','omitnan'))%%delete first row if it is empty
    Minit(1,:) = [];
end
s = size(Minit);
Minit = Minit(:,1:floor((s(2)/3))*3); %cutting off extra columns that hold no data
s = size(Minit);
finT = (max(Minit(:,1:3:end),[],'all')+1)*3; %finding the max time and then the number of cols that dictates
AddOn = NaN(s(1),finT-s(2)); %adding in some placeholders
Minit = [Minit AddOn];

%%%Here we add in NaN values for locusts that don't appear in the initial
%%%frame and assemble the new matrix Mmid

Mmid = [];%make this NaN values of size whatever total will be, using tester not Minit
for r = 1:s(1)
    initTime = (Minit(r,1))*3;
    currRow = Minit(r,:);
    newRow = [NaN(1,initTime) currRow];
    newRow = newRow(:,1:finT);
    Mmid(r,:) = newRow;
    %Mmid(r,(Minit(r,1)*3+1):(length(Minit(r,1))+Minit(r,1)*3+1)) = Minit(r,:);
    %Mmid(r,:) = newRow(:,1:s(2));
end
%Mmid = Mmid(:,1:floor((s(2)/3))*3);
s = size(Mmid);

%%Now we can assemlbe the matrix, Mnext, which adds in NaN values where there
%%are missing frames, thus aligning all positions for locusts in time. This
%%code block could be changed to assign flags or do a linear approximation
%%of where the locusts are at all times.
Mnext = [];
for rw = 1:s(1)
    disp(rw)
    currRow = Mmid(rw,:);
    count = 1;
    while count <= s(2)-5
        gap = ((currRow(1,count+3)-currRow(1,count))-1)*3;
        if isnan(gap)
            count = count + 3;
        else
            currRow = [currRow(:,1:count+2) NaN(1,gap) currRow(:,count+3:length(currRow))];
            count = count + 3 + gap;
        end
    end
    Mnext(rw,:) = currRow(1,1:s(2));
end


%%At this point we can add in flags for the different types of data points.
%%I will use 0 to indicate out of frame, 1 to indicate a tracked, in-frame
%%data point, and 2 to indicate a skipped frame, while the locust is still
%%present. Even if we end up using a linear interprotation of these skipped
%%frames, I would do that after this step is complete, as this flagging
%%relies on the above code which enters "NaN" for skipped frames.

%%First let's add in columns of NaNs after the y coordinates where the
%%flags will be

placeHold = NaN(s(1),1);
M = [];
for i = 0:s(2)/3-1
    M = [M Mnext(:,3*i+1) Mnext(:,3*i+2) Mnext(:,3*i+3) placeHold];
end

sz = size(M);


for rw = 1:sz(1)
    Enters = 0;
    cl = 2;
    Remains = 1;
    %inter = 0;
    while cl < sz(2)
        if isnan(M(rw, cl)) && Enters == 0 %if the locust has not entered the frame ever but has no true coordinates--indicates locust has not yet entered frame
            M(rw, cl+2) = 0;
            cl = cl + 4;
        elseif ~isnan(M(rw, cl)) %if the locust has coordinates--indicated in frame
            Enters = 1;
            Remains = ~isnan(mean((M(rw,cl+4:sz(2)))','omitnan'));
            M(rw, cl+2) = 1;
            cl = cl +4;
        elseif isnan(M(rw, cl)) && Enters == 1 && Remains %if the locust doesn't have coordinates, but has entered the frame and still has points later on--indicates skipped frame
            Remains = ~isnan(mean((M(rw,cl+4:sz(2)))','omitnan'));
            M(rw, cl+2) = 2;
            cl = cl +4;
        elseif isnan(M(rw, cl)) && Enters == 1 && Remains == 0 %if the locust has no coordinates and no coordinates in the future--indicates left frame
            M(rw, cl+2) = 0;
            cl = cl + 4;
        end
    end
end

%This section of code is optional and replaces the time columns of missing
%(i.e. NaN data) with actual times.
for t = 0:sz(2)/4-1
    timeVec = ones(s(1),1).*t;
    M(:,4*t+1) = timeVec;
end
%%
%%Here we recast M as a 4D matrix of size 1 x number of data types (xpos, ypos, flag) x number of locusts x frames
%%For locust 5 at frame = 2, i.e. M(:,:,5,2), there will be one row with
%%the first column being xpos, the second being ypos, and the third being
%%the data type flag.

Mfinal = [];
x = M(:,2:4:sz(2));
y = M(:,3:4:sz(2));
flg = M(:,4:4:sz(2));
for frm = 1:sz(2)/4
    for locust = 1:s(1)
        Mfinal(:,:,locust,frm) = M(locust,frm*4-2:frm*4);
    end
end

%%Mfinal3D is a matrix that is 3 dimensional rather than 4. It is number of
%%locusts x number of data points (e.g. xpos, ypos, flag) x number of
%%frames.

Mfinal3D = [];
x = M(:,2:4:sz(2));
y = M(:,3:4:sz(2));
flg = M(:,4:4:sz(2));
for frm = 1:sz(2)/4
    Mfinal3D(:,:,frm) = M(:,frm*4-2:frm*4);
end


%%Here I will do linear interpolation for flag type = 2. Only works for frame gap of 2.
for rw = 1:sz(1)
    for timestep = 1:size(Mfinal3D,3)
        if Mfinal3D(rw,3,timestep) == 2
            Mfinal3D(rw,1:2,timestep) = (Mfinal3D(rw,1:2,timestep-1) + (Mfinal3D(rw,1:2,timestep+1)-Mfinal3D(rw,1:2,timestep-1))/2);
        end
    end
end
end