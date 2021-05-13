% A script for importing trackmate tracks into Matlab

% Works for simple linear tracks with NO splits/merges
% for more details and options, see the Trackmate Manual Section 8, p. 74
% Manual: https://imagej.net/File:TrackMate-manual.pdf

close all
% Jasper's PC
% Fiji's path to use the import scripts shipped with TrackMate
addpath('C:\Users\Jazzy\Fiji.app\scripts')
addpath('..\Data')

%These are all the video files that we've clipped for processing, each is given a unique variable name
vid_man = '133_10sec_710_720_scripted'; %Need this clipped in the same way as the others, Jacob?
vid0 = '133_30sec_230_300'; %Need this clipped in the same way as the others, Jacob?
vid1 = '133_30sec_1120_1150';
vid2 = '133_30sec_1910_1940';
vid3 = '133_30sec_2424_2454';
vid4 = '133_30sec_2455_2525';
vid5 = '133_60sec_225_325';
vid6 = '133_180sec_720_1020';

% % A list for looping below
%xml_list = {vid_man, vid0, vid1, vid2, vid3, vid4, vid5, vid6};
%ran on rad=9.5 data 2/22/2021
%ran on rad=9.6 data 4/5/2021
xml_list = {vid_man};

% load datafile, possibly with existence check
data_rough = {};

for k = 1:length(xml_list)
    xml = append('tracks_',xml_list{k},'.xml');
    
    plot = false;
    data = xml2mat(xml,plot);
    
    data_rough{end+1,1} = xml_list{k};
    data_rough{end,2} = data;
end

datafile = '..\Data\data_rough.mat';
save(datafile, 'data_rough');

function mat = xml2mat(file,varargin)
    % input file is an .xml file of tracks only
    % obtained by dropdown option: "Save as .xml" --> Execute in TrackMate
    
    % optional input = true produces a plot
    
    % Each track will be a N_det x 4 matrix, one line per detection (so track was
    % detected in N_det frames)
    % On each row, the spot data is:
    %       [timestep   x   y   z=0]

    clipZ = true; % cut off the z value, making each track a N_det x 3 matrix
    % does not work for us b/c did not set time per frame in trackmate tracking
    % scaleT = true; % use physical time for T, IF it was set in the .xml file
    
    sprintf('Now importing %s',file)
    tracks = importTrackMateTracks(file,clipZ);

    n_tracks = numel( tracks );

    sprintf('Found %d tracks in the file.', n_tracks)
    
    if varargin{1}
        % plot from the cell array
        figure(1)
        for ii = 1:n_tracks
            hold on
            plot(tracks{ii}(:,2), tracks{ii}(:,3))
        end
    end
    
    %takes tracks as an import in cell array format and produces a matrix in
    %the format that lines up with DataCleaning.m
    sprintf('Now reformatting tracks from %s',file)
    
    reformatMat=cell2mat(tracks);
    TT = max(reformatMat(:,1));
    Import = NaN(length(tracks),(TT+1)*3); %set up a matrix of NaN values in which to load the data

    for locust = 1:length(tracks)
        focalLoc = transpose(cell2mat(tracks(locust)));
        focalLoc = focalLoc(:);
        focalLoc = transpose(focalLoc);
        Import(locust,1:length(focalLoc)) = focalLoc;
    end
    
    mat = Import;
end