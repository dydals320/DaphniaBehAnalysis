
%% Add paths
clear all; 

addpath(genpath('C:\MATLAB\Daphnia\BehaviorTracking\DaphniaPhenotyping'));
RootPath = 'O:\SysBio\KIRSCHNER LAB\Yongmin\DaphniaBehaviorTracking\CohortLifespan_Round2\'; %'E:\Data\Daphnia\BehaviorTracking\NewTank\Trial1'; %'O:\SysBio\KIRSCHNER LAB\Yongmin\DaphniaBehaviorTracking\';

%% Setting up parameters
Settings.arena = 180; %180; % 180 for cohort2 %200 for metformin; %145 for Ethanol and Ficoll // 240 for Lev tank // 78mm for small caffeine test
% 135 for 5mM metformin, 128
Settings.getMask = 0; % if want to use a mask to segment a specific region, put 1. 
Settings.ForceSize = 1; %1 forces override, 0 runs default to find most common size present
Settings.ForceSizePix = 50;

%60; %50; %female: 50 // 200 for caffeine test

fprintf('Arena width is %s & SizePix is %s.   ',  num2str(Settings.arena), num2str(Settings.ForceSizePix))
m=input('Is it right?\n','s');

Settings.FrameRate = 25;
Settings.SegmentOnly = 0;
Settings.selection = 1;
Settings.DefaultFragmentLength = 30*60*5; % frames
Settings.ColorImage = 0;
Settings.progenycounting = 1;
Settings.lifespan = 0;
Settings.createvideo = 0;
Settings.imagesave = 0; % same individual frames

% backgroundsubtraction for phototaxis experiment
Settings.StartFrameLight = 200;
Settings.EndFrameLight = 800;
Settings.FrameIntervalLight = 5;  

% Setting for segments
Settings.MinDaphniaArea = 0.5; %0.5;          % Min area for object to be a valid worm
Settings.MaxDaphniaArea = 4;          % Max area for single worm (1.7)
Settings.MinDistance = 100; %150; % 40;           % 150 for large Min Distance for connecting a new daphnia to an existing track (in pixels)
Settings.SizeChangeThreshold = 100;  % Max size change between frames (in pixels)
Settings.MinTrackLength = 30; %30;        % Min Length of valid track (in frames)    
Settings.edge = 0;
Settings.MinAnimalNum = 20;
Settings.StartFrame = 1;
Settings.ErosionArea = 0.1;

Settings.VideoFrame = 500;
Settings.FrameInterval = 20;         % How often grab frames for background mask creation

% Imaging mode  
Settings.IRmode = 0;
Settings.ColorImage = 0;

% Display
Settings.PlotFrameRate = 25*10;         % Display tracking results every 'PlotFrameRate' frames
Settings.DisplayMode = 0;

%% Read all file names
if Settings.SegmentOnly == 1
    [FileName, pathname] = uigetfile([RootPath, '\*.mat'], 'Select Track File(s) For Visualization','MultiSelect','on');
    fileNames = cellstr(FileName); 
else    
    if Settings.selection == 0
        fileNames =findAllFiletypeInFolder(RootPath, '.mp4');
    else
        [FileName, pathname] = uigetfile([RootPath, '\*.avi'], 'Select Track File(s) For Visualization','MultiSelect','on');
        %[FileName, pathname] = uigetfile([RootPath, '\*.mov'], 'Select Track File(s) For Visualization','MultiSelect','on');
        fileNames = cellstr(FileName); 
    end
end
addpath(genpath(pathname));

%% Create a Mask
if Settings.getMask == 1
    fullFileName = [pathname 'TankMask.mat'];
    if isfile(fullFileName)
        prompt = 'Will you make a new mask (Yes = 1, No = 0) \n ';
        newMask = input(prompt);
        if newMask == 1
            objReadVid=VideoReader([pathname '\' fileNames{1}]);
            rgImage = read(objReadVid,1);
            TankMask = createMask(rgImage);
            save([pathname '\newTankMask.mat'],'TankMask'); 
        else
            load(fullFileName)
        end
    else
        objReadVid=VideoReader([pathname '\' fileNames{1}]);
        rgImage = read(objReadVid,1);
        TankMask = createMask(rgImage);
        save([pathname '\TankMask.mat'],'TankMask'); 
    end
    
end
%% analyze videos in folder
for i = 1:length(fileNames)
    filename = fileNames{i};
    temp = find(pathname == '\');
    fprintf('Path: %s\n', pathname(temp(end-1)+1:temp(end)-1))
    fprintf('File %s : %s \n', num2str(i), filename)
    
    % Track Video File
    if Settings.SegmentOnly == 0
        File = DaphniaTracker(filename, pathname, Settings);
    end
    
    % Segment & Link Tracks
    if Settings.SegmentOnly == 1
       load([pathname '\' filename]);  
    end    
    
    SegFileList = DaphniaSegmentTracks({File.TrackFile}); %[pathname fileNames{i}]); % % ;
    
    % Obtain Ethogram
    Ethogram(SegFileList);

    % Summarize Data by binning over space and time
    DaphniaDensity(SegFileList);
    
    LinkedVideo(SegFileList)
    
    fprintf('Processed File: \n %s \n', [pathname filename]);
end









