% 2019.07.14 delete SegmentTrack - merged to AnalyzeTrack
% Identifies instantaneous behavioral state from worm tracks and
% morphological data from ArenaTracker.
% Saves behavioral data to a file (*_seg.mat)
%
% USAGE:
%   SaveList = SegmentTracks(FileName)
%
%   FileName: single filename of tracked data or cell array of multiple
%               filenames. Select with user input if none given.
%   SaveList: cell array of output filename(s).


function SaveList = DaphniaSegmentTracks(FileName)

addpath(genpath('C:\MATLAB\Daphnia\BehaviorTracking\DaphniaPhenotyping'));


if nargin < 1
    FileName = {};
end

SaveList = {};

% Initialize Segment Analysis Settings
InitialSettings;

if length(FileName) == 0
    % Get track data for analysis
    % --------------------------
    [FileName, PathName] = uigetfile('*.mat','Select Track File(s) For Analysis','MultiSelect','on');
    if ~exist('Tracks') && ~iscell(FileName) && FileName(1) == 0 
        errordlg('No file was selected for analysis');
        return;
    end
    cd(PathName);
    if ~iscell(FileName)
        FileName = cellstr(FileName);
    end
end

NumFiles = size(FileName,2);

%% Loop for each file
for fnum = 1:NumFiles

    if exist('PathName')
        FullName = fullfile(PathName, char(FileName(fnum)));
    else 
        FullName = char(FileName(fnum)); %char(FileName(fnum));
    end

ind = find(FullName == '\');
disp(sprintf('File %d of %d: %s',fnum,NumFiles,FullName(ind(end-2)+1:end)));

[pathname,filename,ext] = fileparts(FullName);  SaveName = [filename,'_seg',ext];
SaveDir = [pathname '\QuantAnalyzed\'];
if ~exist(SaveDir)
    mkdir(SaveDir)
end
FullSaveName = fullfile(SaveDir, SaveName);
BehSaveName = [FullSaveName(1:end-8),'_beh.mat'];

 
%------------
% Load Data
%------------
clear('Tracks','background','ExpData','File','AllData');

%folderdate = []; founddate = strfind(FullName,'200'); if length(founddate)>0 folderdate = FullName(founddate+(0:7)); end
%disp([datestr(now),': Loading File #',num2str(fnum),': [',folderdate,'] ',filename]);

load(FullName,'Tracks','background','ExpData','File','AllData');

if ~exist('Tracks')
    disp('no Tracks variable found. skipping...');
    continue
end
% disp(['...loaded ',datestr(now)]);

AllData = single(AllData);

if (exist('ExpData') && length(ExpData) > 0)
    framerate = ExpData.FrameRate;
    pixelsize = ExpData.PixelSize;
else
    framerate = 2;
    pixelsize = 1;
    disp('WARNING: NO SCALING DATA');
end
Settings.FrameRate = framerate;
Settings.PixelSize = pixelsize;

if isfield(Tracks,'Segment')
    ButtonName=questdlg('Segments have already been analyzed.','','Reanalyze', 'Stop', 'Reanalyze');
    switch ButtonName
        case 'Stop'
            disp('ending.'),
            return;
    end
end

TrackArena = ones(1, length(Tracks));
NumArenas = 1;
%---------------------------
numtracks = length(Tracks);
trackstats = []; 
totalfr = 0;
sprg = -1;
tic;
%% Loop for each track
for tr = 1:length(Tracks)
%    Analysis = SegmentTrack_v3(Tracks(tr),Settings);

    TrackAnalysis = AnalyzeDaphniaTrack(Tracks(tr),Settings); % trackbox,

    %-------------------------------
    % segment codes:
    %-------------------------------
    %   1 - fwd
    %   2 - fwd running (high speed)
    %   3 - fwd slow (low speed)
    %   4 - turning
    %   5 - spinning
    %   6 - pause
    %   7 - unknown
    
    t = toc;
    trlength = length(TrackAnalysis.Beh);
    
    totalfr = totalfr + trlength;

    status = sprintf('Track: %d/%d [%d fr] %d @ %d fps]',tr,numtracks,trlength,totalfr,round(totalfr/t));
    sprg = showprog(status,sprg);

    trackstats = [trackstats; trlength];

    Tracks(tr).SmoothPath = TrackAnalysis.smoothxy;
    Tracks(tr).Distance = TrackAnalysis.Distance;
    Tracks(tr).Speed = TrackAnalysis.Speed;
    Tracks(tr).Beh = TrackAnalysis.Beh(1:end);
    Tracks(tr).PathAngle = TrackAnalysis.pathang ;
    Tracks(tr).PathAngVel = TrackAnalysis.pathangvel;
    Tracks(tr).OriginalDistance = TrackAnalysis.OriginalDistance;
    Tracks(tr).Stall = TrackAnalysis.StallFr;
    Tracks(tr).NoStall = TrackAnalysis.NoStallFr;

end
         
%% Link Tracks together
linkoutput = LinkDaphniaTracks(Tracks,0.5*ExpData.PixelSize/ExpData.FrameRate,Inf);  %Max avg velocity = 0.5mm/s
%linkoutput = LinkTracks(Tracks,0.5*ExpData.PixelSize/ExpData.FrameRate,Inf); 
[Tracks.OriginalTrack] = deal(linkoutput.OriginalTrack);
ExpData.Animals = max(struct2mat(1,linkoutput,[],{'OriginalTrack'}));

SegSettings = Settings;

save(FullSaveName,'Tracks','background','ExpData','File','AllData','trackstats','SegSettings');

%Save condensed data
disp('Condensing behavior data...'); 

BehSaveName = [FullSaveName(1:end-8),'_beh.mat'];
tfields = fieldnames(Tracks); 
rfields = tfields(find(~strcmp(tfields,'Beh') & ...
                       ~strcmp(tfields,'Frames') & ...
                       ~strcmp(tfields,'OriginalTrack') & ...
                       ~strcmp(tfields,'PathAngle') & ...
                       ~strcmp(tfields,'Speed')));
for tr=1:length(Tracks)
    Tracks(tr).X = Tracks(tr).Path(:,1)'; 
    Tracks(tr).Y = Tracks(tr).Path(:,2)'; 
end                   
Tracks = rmfield(Tracks,rfields);
Tracks = singleStruct(Tracks);

save(BehSaveName,'Tracks','ExpData');    
disp(['done. ',datestr(now)]);

SaveList = cat(1,SaveList,{FullSaveName});
end

%---------------------end big loop for each file
end

