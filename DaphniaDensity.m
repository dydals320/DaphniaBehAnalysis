%
% Summarizes behavioral state and speed data over space and time. Data is
% reduced by binning data in sapce and time according to BinSettings.
%
% USAGE:
%   BinFileList = WormDensity(FileName,BinSettings)
%
%   FileName: single filename of segmented data or cell array of multiple
%               filenames. Select with user input if none given.
%   BinSettings: vector of binsize [time(min) distance(pixels)]
%                default is [0.5 10]

function BinFileList = WormDensity_v2(FileName,BinSettings)

defaultBinSettings = [0.5 10]; % time bin (min), x-y bin (pix)
if nargin < 2 BinSettings = defaultBinSettings; end
if nargin < 1 || isempty(FileName)
    FileName = {};
end
    
%-------- Settings ------ 
SaveData = 1;
s = 4;
segname = '_seg';
BinFileList = {};

%-- Bin Settings ----------------------
if isempty(BinSettings)
    answer = dagetnum({'Time Bin (min):','Area Bin (pixels):'}, ...
                        defaultBinSettings);
    timebin = answer(1).num;  % minutes per bin
    areabin = answer(2).num; % in pixels
end

timebin = BinSettings(1); %0.5  % minutes per bin
areabin = BinSettings(2); %10;  % in pixels
    
clear FileData

if isempty(FileName)
    
    [FileName, PathName] = uigetfile('*_seg.mat','Select segmented track File(s) For Analysis','MultiSelect','on');
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
disp(['Batch analyzing ',num2str(NumFiles),' segmented tracks files.']);

    
%-------------------------------------------------------%
%               BIG LOOP FOR EACH FILE                  %
%-------------------------------------------------------%

for FileNum = 1:NumFiles
       
    if exist('PathName')
        FullName = fullfile(PathName, char(FileName(FileNum)));
    else
        FullName = char(FileName(FileNum));
    end

    [PathName,BaseName,Ext] = fileparts(FullName);
    BaseName = BaseName(1:strfind(BaseName,segname)-1); % remove '_seg' from filename
    FileData(FileNum).PathName = PathName;
    FileData(FileNum).BaseName = BaseName;
    FileData(FileNum).RawFile = fullfile(PathName,[BaseName,Ext]);
    FileData(FileNum).SegFile = fullfile(PathName,[BaseName,segname,Ext]);
    
clear('FileInfo','ExpData','TrackData','All*','Animal*','Track','Beh*','*Speed*'); %free memory

%----------------------
% Get experiment data 
%----------------------

%disp([datestr(now),': Loading File #',num2str(FileNum),': ',FullName]);

try
    load(FileData(FileNum).SegFile,'Tracks','File','AllData','ExpData');
    % disp([datestr(now),'--     ...loaded OK.']);
catch
    disp('Problem Loading File.  Skipping to next File.');
    continue
end
% if exist('Filter')
%     AllData = getAllData(ExpData, Tracks);
% end
existAll = exist('AllData');

[mp,mf,me] = fileparts(File(ExpData.MovieNum).MovieFile);
FileData(FileNum).MovieFile = fullfile(PathName,[mf,me]);

sizebins = 0:5:max(AllData(:,2));
singleworm = mean(ExpData.TrackSettings(:,3));

if length(singleworm)>0
    singleworm = singleworm(1);
    disp(['Animal size: ',num2str(singleworm),' pixels']);

%     figure(1);clf;bar(sizebins,hist(AllData(:,2),sizebins)); grid on;
%     figure(1);clf;bar(sizebins,hist(AllData(:,2),sizebins)); grid on;

    AllData(:,6) = round(AllData(:,2)/singleworm);  % number of worms per centroid
    SkipArena = 0;
else
    disp(['*** NO SINGLE WORMS FOUND ***  Mean object size = ',num2str(mean(AllData(:,2)))]);
    SkipArena = 1;
end

AllData(:,7) = AllData(:,1) / ExpData.FrameRate; % Second / 60 for time in mins

% Proportion of clumping animals
hrange = 0:9;
[nw,wms] = hist(AllData(:,6),hrange);
total = sum(nw.*wms);
nclump = nw.*wms/total;
disp('Percent animals in collisions of n animals');
disp([wms; nclump*100]);

%--- Trim AllData Variable: only 1+ worms/object and correct timing range
prevsize = size(AllData,1);
AllData = AllData(find(AllData(:,6) >= 1),:); % & AllData(:,7) >= StartTime & AllData(:,7) <= EndTime),:);
sizesaving = 1 - size(AllData,1)/prevsize;
% disp(['AllData size decreased by: ',num2str(sizesaving*100),'%']);
AllData = single(AllData);

%---set bin parameters
TimeBin = ceil(AllData(:,7)/timebin); tbins = max(TimeBin);
XBin = ceil(AllData(:,3)/areabin); xbins = max(XBin);
YBin = ceil(AllData(:,4)/areabin); ybins = max(YBin);

AllXYT = zeros(xbins, ybins, tbins,'single');
% tic;
for i=1:size(AllData,1)
    if XBin(i)>0 & YBin(i)>0
        AllXYT(XBin(i),YBin(i),TimeBin(i)) = AllXYT(XBin(i),YBin(i),TimeBin(i)) + AllData(i,6);
    end
end

All.XYTime = AllXYT;
% t = toc; disp(['AllXYT analysis: ',num2str(t),' s']);

All.XY = squeeze(sum(AllXYT,3));
All.TimeX = squeeze(sum(AllXYT,2))';
All.TimeY = squeeze(sum(AllXYT,1))';

All.X = ((1:xbins)-0.5) * areabin / ExpData.PixelSize;
All.Y = ((1:ybins)-0.5) * areabin / ExpData.PixelSize;
All.Time = ((1:tbins)-0.5) * timebin;

All.SingleWormSize = singleworm;
All.SizeHist = [wms; nw];
All.ClumpFrxn = nclump;

%--------------------
% print figure - All 
densfig = findobj(get(0,'Children'),'Tag','Worm Density');
if isempty(densfig) densfig = figure; set(densfig,'Tag','Worm Density'); end
figure(densfig); clf;

n = 3; for i=1:n; 
    subplot(3,n+1,8+i); 
    imagesc(All.X,All.Y,squeeze(sum(AllXYT(:,:,1+round(end*(i-1)/n):round(i*end/n)),3))'); 
    colormap([flipud(gray(64));zeros(64,3)]); axis equal tight; title(sprintf('%d/%d',i,n)); if i==1 ylabel('Height(mm)'); end
end; subplot(3,n+1,8+(n+1)); imagesc(All.X,All.Y,All.XY'); axis equal tight; title('All'); xlabel('x(mm)');
hy = subplot(3,4,1:3); imagesc(All.Time,All.Y,All.TimeY'); colormap([flipud(gray(64));zeros(64,3)]); ylabel('Height(mm)'); 
title(BaseName,'Interpreter','none');
hx = subplot(3,4,5:7); imagesc(All.Time,All.X,All.TimeX'); colormap([flipud(gray(64));zeros(64,3)]); ylabel('x(mm)'); xlabel('Time (s)');
subplot(3,4,4); barh(All.Y,sum(All.XY,1)); ylim(get(hy,'YLim')); axis ij; title('(All animals)');
subplot(3,4,8); barh(All.X,sum(All.XY,2)); ylim(get(hx,'YLim')); axis ij;
warning('off','MATLAB:log:logOfZero');
warning('off','MATLAB:divideByZero');
hold on
% subplot(5,4,13:14); bar(sizebins/singleworm,log10(hist(AllData(:,2),sizebins)));grid on; 
%     title(sprintf('Object Size (1 worm = %0d pix^2)',round(singleworm))); 
%     set(gca,'XTick',1/2:max(sizebins)/singleworm);
%     ylabel('log10(frames)'); xlabel('Animals per object');


orient tall

SaveName = strrepl(FileData(FileNum).SegFile,'_seg.mat','_density.pdf');        
[mp,mf,me] = fileparts(SaveName);
SaveDir = [mp '\Ethogram\'];
if ~exist(SaveDir)
    mkdir(SaveDir)
end
FileNames=[mf me];
FullSaveName = fullfile(SaveDir, FileNames);        
saveas(densfig,FullSaveName);



% Bin numbers (tbins, xbins,etc) should be the same as before...
end

end
function ssTracks = getAllData(ExpData, Tracks)

numframes = ExpData.TrackedFrames;

for i = 1:length(Tracks)
        try
            AnimalID(i) = Tracks(i).OriginalTrack;
        catch
            AnimalID(i) = NaN; 
        end
    end

ssTracks=NaN(numframes,5,max(AnimalID));
for i = 1:max(AnimalID)
    valind = find(AnimalID==i);

    for j = 1:length(valind)
        ssTracks(Tracks(valind(j)).Frames(1):Tracks(valind(j)).Frames(end),1,i) = Tracks(valind(j)).Frames;
        ssTracks(Tracks(valind(j)).Frames(1):Tracks(valind(j)).Frames(end),2,i) = Tracks(valind(j)).Size;
        ssTracks(Tracks(valind(j)).Frames(1):Tracks(valind(j)).Frames(end),3,i) = Tracks(valind(j)).SmoothPath(:,1);
        ssTracks(Tracks(valind(j)).Frames(1):Tracks(valind(j)).Frames(end),4,i) = Tracks(valind(j)).SmoothPath(:,2);
        ssTracks(Tracks(valind(j)).Frames(1):Tracks(valind(j)).Frames(end),5,i) = Tracks(valind(j)).Eccentricity;

    end
end

end