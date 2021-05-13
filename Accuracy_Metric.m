%%The input here, data_clean_radstudy.mat is a 3 column, N row cell array
%%where the 1st column is just a matrix name, the 2nd column is the cleaned
%%matrix (i.e. a matrix run through Data_Cleaning.m), and the 3rd is the
%%radius
%JSC is your output matrix of, with the 1st column being diameter, not
%radius and the second column being the Landsberg Similarity Coefficent


addpath("Data")
%Here are different data loads, 
load data_clean_radstudy.mat
load JSC.mat %Here you load in JSC.mat, if you want a fresh one, simply redinfine JSC.mat as [].
load manual_clean%load the cleaned manually-tracked file
testman = manual_clean(:,1:2,1:249);% here we format the manual file, cutting off the last time point due to framing issues


%loop through input using accuracy function
for g = 1:size(data_clean_radstudy,1)
   fmat = data_clean_radstudy{g,2};
   fmat = fmat(:,1:2,:);
   fradius = data_clean_radstudy{g,3};
   JS = accuracy(fmat,fradius,testman);
   JSC = cat(1,JSC,JS); 
end


plot(JSC(:,1),JSC(:,2))
title("LSC vs. Spot Diamter")
xlabel("diameter in pixels")
ylabel("LSC")

datafile = 'JSC.mat';
save(datafile, 'JSC');


%%this function takes as input, the matrix you want to compare with the
%%manually-tracked data, the radius, and the manually-tracked data, it
%%outputs a 1 row 2 column matrix. The first column is diameter, and the
%%second is the Landsberg similarity coefficent.
function JS = accuracy(testauto, radius, testman)


%%Here we assemble a Cost matrix of distances from the auto to the manual
%%points. For example, Cost(i,j) is the Euclidean distance from point i to point j
%%The Cost matrix has the number of rows equal to the number of tracks in
%%the automatic tracks and the number of columns equal to the number of
%%tracks in the manual track. Its depth is the number of frames.
Cost = zeros(length(testauto),length(testman),size(testauto, 3));
for j = 1:size(testauto, 3)
    for k = 1:length(testauto)
        Cost(k,:,j) = vecnorm([testauto(k,1,j)-transpose(testman(:,1,j)); testauto(k,2,j)-transpose(testman(:,2,j))],2,1)';
    end
end

%%Now we set all NaN values to a super high value in the cost matrix, so
%%they will not be matched with anything. So long as they are higher than
%%the unassignment cost, I think this will be fine. This is just because
%%matchpairs can't handle NaN values. Match is a matrix where each row
%%shows the indices of paired points in automatic and manual track. So if a
%%row is [3,4], then the point in the 3rd row of testauto corresponds to
%%the point in the 4th row of testman.
Cost(isnan(Cost))=1000;
unassignment = .5;%in cm
%JSCvaryU = [];
%for m = 0:.01:1.25
    %unassignment = m;
    Match = NaN(length(testman),2,size(testauto,3));
    for j = 1:size(testauto, 3)
        singleMatch = matchpairs(Cost(:,:,j),unassignment);
        Match(1:size(singleMatch,1),:,j) = singleMatch;
    end
% Dist = [];  
%  for j = 1:size(testauto,3)
%    c = Cost(:,:,j);
%    RealMatchi = Match(:,1,j);
%    RealMatchj = Match(:,2,j);
%    RealMatchi(isnan(RealMatchi))=[];
%    RealMatchj(isnan(RealMatchj))=[];
%    %RealMatchi = transpose(RealMatchi);
%    %RealMatchj = transpose(RealMatchj);
%    RealMatch = cat(2,RealMatchi,RealMatchj);
%    linearIndices = sub2ind(size(c),transpose(RealMatch(:,1)), transpose(RealMatch(:,2)));
%    d = c(linearIndices);
%    Dist = [Dist,d];
%  end
% figure()
% histogram(Dist,100)
% xlabel("Distances between auto and manual points")
    %%Now I'll make a matrix to find the number of points present in both the
    %%manual and automatic tracks at each time step. Row 1 will be the number
    %%in the automatic, Row 2 will be the number in the manual, Row 3 will
    %%be the number of paired spots, Row 4 will be the number of false
    %%positives (Row 1 minus Row 3), andRow 5 will be the number of false
    %%negatives (Row 2 minus Row 3).
    PointsPresent = zeros(5,1,size(testauto,3));
    for j = 1:size(testauto, 3)
        PointsPresent(1,1,j) = sum(~isnan(testauto(:,1,j)));
        PointsPresent(2,1,j) = sum(~isnan(testman(:,1,j)));
        PointsPresent(3,1,j) = sum(~isnan(Match(:,1,j)));
        PointsPresent(4,1,j) = PointsPresent(1,1,j)-PointsPresent(3,1,j);
        PointsPresent(5,1,j) = PointsPresent(2,1,j)-PointsPresent(3,1,j);
    end
    
    %%JS will be our version of the Jaccard Similarity Coefficient. It will be
    %%equal to the true positives, i.e., the total number of matched points
    %%within the unassignment distance (TP), divided by the sum of the true
    %%positives plus the number of false positives (FP) plus the number of
    %%false negatives (FN).
    TP = sum(PointsPresent(3,1,:),3);
    FP = sum(PointsPresent(4,1,:),3);
    FN = sum(PointsPresent(5,1,:),3);
    JS = [radius*2,TP/(TP + FP + FN)]
end
%     rads = [15;18;20;22;24;26;28;30;32;35];
%     figure()
%     plot(rads,JS)
%     xlabel("diameters in pixels")
%     ylabel("JS coefficent")
    %JSCvaryU = cat(1,JSCvaryU,[JS]);
%end
%u = 0:.01:1.25;
%plot(u, JSCvaryU)

%%Now I will calculate the average distance between optimally paired
%%automatic and manually tracked points.
