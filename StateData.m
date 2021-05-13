addpath("Data")
%%this file reports the total time percent in each state (PercentInState), and also the probabilities
%%of transitioning between states (TransitionTable)


%%Here we will find transitions between states (S = stop, C = crawl, H =
%%hop): 1 = SS, 2 = SC, 3 = SH, 4 = CC, 5 = CH, 6 = CS, 7 = HH, 8 = HS, 9 =
%%HC

%%Finding percent of time in each state
matNums = [1,3,4,5,6,7,8];%note we drop matrix 2 since it is a subset of matrix 7 in data_final
totStps = 0;
totCrwls = 0; 
totHps =  0;
totTotal = 0;
%%PercentInState is a 1x3 matrix with columns as fraction of time stopped,
%%crawling, and hopping
for mt = matNums
  focalMat = data_final{mt,2};
  focalCol = focalMat(:,6,:);
  focalCol = focalCol(:);
  totStps = totStps + sum(focalCol==0);
  totCrwls = totCrwls + sum(focalCol==1);
  totHps = totHps + sum(focalCol==2);
  totTotal = totTotal + sum(~isnan(focalCol));  
end
PercentInState = [totStps,totCrwls,totHps]/totTotal;%formated as a 1 row, 3 column matrix, with columns going as stopped, crawling, hopping time percentages




totalData = [];
for m = matNums
   focalmat = data_final{m,2};
   individualData = trn(focalmat);
   individualData = individualData(:);
   totalData = cat(1,totalData,individualData);
end 
%%the table is formated with rows being the from state, and the columns
%%being the to state. The first row and column correspond to stopped, the
%%second row and column correspond to crawling, and the third row and
%%column correspond to hopping
Stp2X = sum(totalData == 1 | totalData == 2 | totalData == 3);
Crwl2X = sum(totalData == 4 | totalData == 5 | totalData == 6);
Hp2X = sum(totalData == 7 | totalData == 8 | totalData == 9);
TransitionTable = NaN(3,3);
TransitionTable(1,1) = sum(totalData==1)/Stp2X;
TransitionTable(2,1) = sum(totalData==2)/Stp2X;
TransitionTable(3,1) = sum(totalData==3)/Stp2X;
TransitionTable(2,2) = sum(totalData==4)/Crwl2X;
TransitionTable(3,2) = sum(totalData==5)/Crwl2X;
TransitionTable(1,2) = sum(totalData==6)/Crwl2X;
TransitionTable(3,3) = sum(totalData==7)/Hp2X;
TransitionTable(1,3) = sum(totalData==8)/Hp2X;
TransitionTable(2,3) = sum(totalData==9)/Hp2X;


function Transitions = trn(M)
Transitions = NaN(size(M,1),1,size(M,3));

for locust = 1:size(M,1)
    for t = 1:size(M,3)-1
        if M(locust,6,t) == 0 &&  M(locust,6,t+1) == 0
            Transitions(locust,1,t) = 1;
        end
        if M(locust,6,t) == 0 &&  M(locust,6,t+1) == 1
            Transitions(locust,1,t) = 2;
        end
        if M(locust,6,t) == 0 &&  M(locust,6,t+1) == 2
            Transitions(locust,1,t) = 3;
        end
        if M(locust,6,t) == 1 &&  M(locust,6,t+1) == 1
            Transitions(locust,1,t) = 4;
        end
        if M(locust,6,t) == 1 &&  M(locust,6,t+1) == 2
            Transitions(locust,1,t) = 5;
        end
        if M(locust,6,t) == 1 &&  M(locust,6,t+1) == 0
            Transitions(locust,1,t) = 6;
        end
        if M(locust,6,t) == 2 &&  M(locust,6,t+1) == 2
            Transitions(locust,1,t) = 7;
        end
        if M(locust,6,t) == 2 &&  M(locust,6,t+1) == 0
            Transitions(locust,1,t) = 8;
        end
        if M(locust,6,t) == 2 &&  M(locust,6,t+1) == 1
            Transitions(locust,1,t) = 9;
        end
    end
end
end



