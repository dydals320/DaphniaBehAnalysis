%
% Track animals for a movie fragment.
%
% USAGE:
%   FragmentTracker(File,FragmentSaveNames,FragmentFrames,Fragment,Mask,TrackDye,WTFigH)
%
%   File: file structure from ArenaTracker
%   FragmentSaveNames: list of save names
%   FragmentFrames: list of frames for all fragments
%   Fragment: current fragment number
%   Mask: video mask pattern
%   TrackDye: flag to track dye concentration
%   WTFigH: figure handle

%% Updates
% 2019.05.30 Using filledarea instead of area from regionprops function
% 2020.02 background subtraction - seperate for normal vs light exp

function FragmentTracker(File,FragmentSaveNames,Mask,Settings,WTFigH)

MovieNum = 1;
NumArenas = 1;
MinDaphniaArea = Settings.MinDaphniaArea;
MaxDaphniaArea = Settings.MaxDaphniaArea;
MinDistance = Settings.MinDistance;           % 150 for large Min Distance for connecting a new worm to an existing track (in pixels)
ErosionArea = Settings.ErosionArea;
SizeChangeThreshold = Settings.SizeChangeThreshold;  % Max size change between frames (in pixels)
MinTrackLength = Settings.MinTrackLength;        % Min Length of valid track (in frames)    
edge = Settings.edge;
MinAnimalNum = Settings.MinAnimalNum;
StartFrame = Settings.StartFrame;
ForceSize = Settings.ForceSize; 
ForceSizePix = Settings.ForceSizePix;
getMask = Settings.getMask;

IRmode = Settings.IRmode;
ColorImage = Settings.ColorImage;

FrameInterval = Settings.FrameInterval;         % How often grab frames for background mask creation
createvideo = Settings.createvideo;            % create video based on BW image
VideoFrame = Settings.VideoFrame;
imagesave = Settings.imagesave;
Lifespan = Settings.lifespan;
FrameRate = Settings.FrameRate;
% backgroundsub = 1;

PlotFrameRate = Settings.PlotFrameRate;         % Display tracking results every 'PlotFrameRate' frames
DisplayMode = Settings.DisplayMode;
Light = [];
%Edit Here to Force Tracker to recognize a certain animal size

%%%%%%%%%%%%%%%%%%%%%%%%%
% backgroundcorrection
Backgroundcorrection = 0;

MovMain = VideoReader(File(MovieNum).MovieFile);
EndFrame = MovMain.NumberOfFrames;

% Get background
if contains(File(MovieNum).MovieFile, 'light')
    MovName = File(MovieNum).MovieFile;
    lighting=1; FrameInterval = 1;
    FrameRate = Settings.FrameRate;
    StartFrameLight0 = 9*FrameRate;   
    StartFrameLight1 = 11*FrameRate;   
    LightOn = getbackground_light(MovName, StartFrameLight0, StartFrameLight1, FrameInterval, lighting);   
    StartFrameLight = LightOn.TimeOn + StartFrameLight0;
    Light.On = StartFrameLight;
    
    EndFrameLight0 = 29*FrameRate;
    EndFrameLight1 = 31*FrameRate;
    LightOff = getbackground_light(MovName, EndFrameLight0, EndFrameLight1, FrameInterval, lighting);   
    EndFrameLight = LightOff.TimeOff + EndFrameLight0;
    Light.Off = EndFrameLight;
    
    FrameIntervalLight = Settings.FrameIntervalLight;  
    background0 = getbackground(File(MovieNum).MovieFile, 1, StartFrameLight, FrameIntervalLight);
    background1 = getbackground(File(MovieNum).MovieFile, StartFrameLight, EndFrameLight-1, FrameIntervalLight);% FragmentFrames(Fragment,1),FragmentFrames(Fragment,end)
    background2 = getbackground(File(MovieNum).MovieFile, EndFrameLight, MovMain.NumFrames, FrameIntervalLight);% FragmentFrames(Fragment,1),FragmentFrames(Fragment,end)

elseif contains(File(MovieNum).MovieFile, 'Stim')
    MovName = File(MovieNum).MovieFile;
    lighting=1; FrameInterval = 1;
    FrameRate = Settings.FrameRate;
    
    StartFrameLight0 = 10*FrameRate;   
    LightOn0 = getbackground_light(MovName, StartFrameLight0-10, StartFrameLight0+10, FrameInterval, lighting);   
    StartFrameLight0 = LightOn0.TimeOn + StartFrameLight0-10;
    EndFrameLight0 = 20*FrameRate;
    LightOff0 = getbackground_light(MovName, EndFrameLight0-10, EndFrameLight0+10, FrameInterval, lighting);   
    EndFrameLight0 = LightOff0.TimeOff + EndFrameLight0-10;    
    Light.On0 = StartFrameLight0;
    Light.Off0 = EndFrameLight0;
    
    StartFrameLight1 = 40*FrameRate; 
    LightOn1 = getbackground_light(MovName, StartFrameLight1-10, StartFrameLight1+10, FrameInterval, lighting);   
    StartFrameLight1 = LightOn1.TimeOn + StartFrameLight1-10;
    EndFrameLight1 = 50*FrameRate; 
    LightOff1 = getbackground_light(MovName, EndFrameLight1-10, EndFrameLight1+10, FrameInterval, lighting);  
    EndFrameLight1 = LightOff1.TimeOff + EndFrameLight1-10;
    Light.On1 = StartFrameLight1;
    Light.Off1 = EndFrameLight1;
    
    StartFrameLight2 = 100*FrameRate;
    LightOn2 = getbackground_light(MovName, StartFrameLight2-10, StartFrameLight2+10, FrameInterval, lighting);   
    StartFrameLight2 = LightOn2.TimeOn + StartFrameLight2-10;
    EndFrameLight2 = 110*FrameRate;
    LightOff2 = getbackground_light(MovName, EndFrameLight2-10, EndFrameLight2+10, FrameInterval, lighting);  
    EndFrameLight2 = LightOff2.TimeOff + EndFrameLight2-10;
    Light.On2 = StartFrameLight2;
    Light.Off2 = EndFrameLight2; 
    
    FrameIntervalLight = Settings.FrameIntervalLight;  
    background0 = getbackground(File(MovieNum).MovieFile, 1, StartFrameLight0, FrameIntervalLight); %before light1 stim.
    background1 = getbackground(File(MovieNum).MovieFile, StartFrameLight0, EndFrameLight0, FrameIntervalLight);
    background1_1 = getbackground(File(MovieNum).MovieFile, EndFrameLight0+5, StartFrameLight1-1, FrameIntervalLight);
    background2 = getbackground(File(MovieNum).MovieFile, StartFrameLight1, EndFrameLight1, FrameIntervalLight);
    background2_2 = getbackground(File(MovieNum).MovieFile, EndFrameLight1+5, StartFrameLight2-1, FrameIntervalLight);
    background3 = getbackground(File(MovieNum).MovieFile, StartFrameLight2, EndFrameLight2, FrameIntervalLight);
    background4 = getbackground(File(MovieNum).MovieFile, EndFrameLight2, MovMain.NumFrames, FrameIntervalLight);

else
    background = getbackground(File(MovieNum).MovieFile,StartFrame, EndFrame, FrameInterval); % FragmentFrames(Fragment,1),FragmentFrames(Fragment,end)
end

% Initialize variables
Tracks = [];
AllData = [];
Level = 0;
Settings = [];

if createvideo == 1
    [path name ext] = fileparts(char(FragmentSaveNames));
    partsfolder = '\Count\';
    savedir = [path partsfolder];
    if ~exist(savedir)
        mkdir(savedir)
    end
    vidObj = VideoWriter([savedir name '_counting.avi']);
    vidObj.FrameRate = FrameRate;
    vidObj.Quality = 100;
    open(vidObj);
end

if IRmode == 1
   background = 255 - uint8(background); % uint8(255) - background; 
end

%% Run big loop
h=waitbar(0, 'Please Wait');
for Frame = 1:EndFrame
    if contains(File(MovieNum).MovieFile, 'light')
       if Frame >= 1 && Frame < StartFrameLight
          background = background0;
       elseif Frame >= StartFrameLight && Frame < EndFrameLight
          background = background1;
       elseif Frame >= EndFrameLight
          background = background2;
       end
    end
    
%     if Frame == 1000
%        pause(1) 
%     end
    
    if contains(File(MovieNum).MovieFile, 'Stim')
        if Frame >= 1 && Frame < StartFrameLight0 
          background = background0;
       elseif Frame >= StartFrameLight0  && Frame < EndFrameLight0 
          background = background1;
       elseif Frame >= EndFrameLight0  && Frame < StartFrameLight1 
          background = background1_1; 
       elseif Frame >= StartFrameLight1  && Frame < EndFrameLight1 
          background = background2;
       elseif Frame >= EndFrameLight1  && Frame < StartFrameLight2 
          background = background2_2;
       elseif Frame >= StartFrameLight2  && Frame < EndFrameLight2 
          background = background3;
       elseif Frame >= EndFrameLight2
          background = background4; 
        else
          background = background0;
       end
    end
    
    Mov = read(MovMain,Frame); MovOrig = Mov;
    grayscaleImage =  background - Mov(:,:,1);
    if ColorImage == 1
       Mov = rgb2gray(Mov); 
       grayscaleImage =  background - Mov(:,:,1);
    end
    % Mov(find(Mov<120 & Mov>110))=180; % 
        if IRmode == 1
           Mov = 255 - double(Mov); % uint8(255) - Mov; 
        end
        %subtract the background from the frame
        Movdiv = 1 - min(double(Mov(:,:,1)+1)./(double(background)+1),1);
        % Movdiv = 1 - min(double(Mov(:,:,1)+1)./(double(background)-10),1);
        %Movdiv(TimerY,TimerX) = 0;  % clear timer region
        if getMask == 1
            Movdiv = Movdiv .* Mask; 
        else
            Movdiv = Movdiv .* ~Mask; 
        end
    if edge == 1
        frameset=10;
        Movdiv = Movdiv(frameset:end-frameset, frameset:end-frameset);
    end  
    
%% Set background
if Backgroundcorrection == 1
    box = File.Arena.TrackBox;
    Image = zeros(size(Movdiv));
    Img = imcrop(Movdiv,box);
    xset = round(box(2));
    yset = round(box(1));
    Image(xset:xset+size(Img,1)-1,yset:yset+size(Img,2)-1) = Img;
    Movdiv = Image;
end

%% Calculate threshold and animal size
    if Level == 0
        [Level,AnimalPix] = AutoThreshold(Movdiv); 
        if ForceSize == 1
            AnimalPix = ForceSizePix;
        end
        
        if AnimalPix >=300
            AnimalPix = ForceSizePix;
        end
        
        if AnimalPix <=10
            AnimalPix = ForceSizePix;
        end
        
        Settings = [Settings; Frame, Level, AnimalPix];
        disp(sprintf('Auto-threshold: %0.3f (Animal = %d pix; %0.3f mm^2)',Level,AnimalPix,AnimalPix / File.PixelSize^2));
        Level = Level;
    end
    if IRmode == 1
        Level = 0.01;
        ErosionArea = 0.5;
        
    end
    
    
% Filter and threshold video frame
    F2 = VideoFilter(Movdiv);
    BW = im2bw(F2,Level);
    BW2 = bwareaopen(BW, round(ErosionArea*AnimalPix));
    % imshow(BW) % save it
    if IRmode == 1
        se = strel('disk',50);
        BW2 = imclose(BW2,se);
    end
        
    [L,NUM] = bwlabel(BW2,4);
%     if NUM >= MinAnimalNum 
%         % Reset autothreshold if too many objects
%         [Level,AnimalPix] = AutoThreshold(Movdiv);
%         %if ForceSize == 1
%             AnimalPix = ForceSizePix;
%         %end
%         Settings = [Settings; Frame, Level, AnimalPix]; % disp(['(',num2str(Level),')']);
%         BW = im2bw(F2,Level);
%         [L,NUM] = bwlabel(BW,4);
%     end
    
    STATS = regionprops(L, grayscaleImage, {'Area', 'Centroid', 'Eccentricity', 'MajorAxisLength', ...
        'MinorAxisLength', 'Orientation', 'Image', 'BoundingBox', 'Perimeter', 'FilledArea', 'FilledImage',...
        'MeanIntensity','MaxIntensity','MinIntensity','FilledArea'});
    
    
    DaphniaIndices = find([STATS.FilledArea] > MinDaphniaArea*AnimalPix & [STATS.FilledArea] < MaxDaphniaArea*AnimalPix);
    if ~mod(Frame, PlotFrameRate)
        fprintf('Daphnia size: %0.0f \n', nanmean([STATS(DaphniaIndices).FilledArea]));
    end
    NumDaphnia = length(DaphniaIndices);
    if isempty(NumDaphnia)
        break
    end
    % Circularity
    allAreas = [STATS(DaphniaIndices).Area];
    allPerimeters = [STATS(DaphniaIndices).Perimeter];
    DaphniaCircularities = [(4 * pi * allAreas) ./ allPerimeters .^2];
    
    Daphniapopulation(Frame) = NumDaphnia;
    DaphniaCentroids = [STATS(DaphniaIndices).Centroid];
    DaphniaCoordinates = [DaphniaCentroids(1:2:2*NumDaphnia)', DaphniaCentroids(2:2:2*NumDaphnia)'];
    % DaphniaSizes = [STATS(DaphniaIndices).Area];
    DaphniaSizes = [STATS(DaphniaIndices).FilledArea]; 
    DaphniaEccentricities = [STATS(DaphniaIndices).Eccentricity];
    DaphniaPerimeters = [STATS(DaphniaIndices).Perimeter];
    DaphniaMajorAxes = [STATS(DaphniaIndices).MajorAxisLength];
    DaphniaMinorAxes = [STATS(DaphniaIndices).MinorAxisLength];
    DaphniaOrientation = [STATS(DaphniaIndices).Orientation];
    DaphniaIntensity = [STATS(DaphniaIndices).MeanIntensity];
    DaphniaIntensityMin = [STATS(DaphniaIndices).MinIntensity];
    DaphniaIntensityMax = [STATS(DaphniaIndices).MaxIntensity];
    DaphniaBox = [STATS(DaphniaIndices).BoundingBox];
    DaphniaBoundingBox = [DaphniaBox(1:4:4*NumDaphnia)', DaphniaBox(2:4:4*NumDaphnia)'];
    DaphniaImage = [];
    for wi = 1:length(DaphniaIndices)
        DaphniaImage(wi).Image = STATS(DaphniaIndices(wi)).Image;
        DaphniaImage(wi).FilledImage = STATS(DaphniaIndices(wi)).FilledImage; % Added
    end
    
    
%% for video generation
    if imagesave == 1
        radi = 30*ones(length(DaphniaCoordinates(:,1)),1);
        [path name ext] = fileparts(char(FragmentSaveNames));
        partsfolder = '\Image\';
        savedir = [path partsfolder name '\'];
        if ~exist(savedir)
            mkdir(savedir)
        end
%         warning('off', 'Images:initSize:adjustingMag');
%         hhg=figure('visible','off'); imshow(BW, 'border','tight'); % axis equal; hold on  % MovOrig
%         viscircles([DaphniaCoordinates(:,1),DaphniaCoordinates(:,2)],radi,'DrawBackgroundCircle',false,'linewidth',1);
%         % title(['Frame ' num2str(Frame) ': n = ' num2str(NumDaphnia)])
%         % saveas(hhg,[savedir name '_' num2str(Frame) '_seg.png']);
%         
%         % imwrite(BW,[savedir name '_' num2str(Frame) '_seg.png']);
%         BW2 = bwareaopen(BW, round(ErosionArea*AnimalPix));
%         imwrite(BW2,[savedir name '_' num2str(Frame) '_BW.png']);
%         imwrite(Mov, [savedir name '_' num2str(Frame) '_Orig.png']);
        
        ffg=figure(4); ffg.WindowState = 'maximized'; 

        subplot(1,20,1:10); imshow(Movdiv, []);viscircles([DaphniaCoordinates(:,1),DaphniaCoordinates(:,2)],radi,'DrawBackgroundCircle',false,...
             'linewidth',1);
        subplot(1,20,11:20); imshow(BW2);
        title(['Frame ' num2str(Frame) ': n = ' num2str(Daphniapopulation(Frame))])
        saveas(ffg,[savedir name '_' num2str(Frame) '.png']);
        save([savedir name '_' num2str(Frame) '.mat'],'BW','BW2','Mov','DaphniaCoordinates','NumDaphnia');
    end
if createvideo == 1  &&  Frame <= VideoFrame
         radi = 30*ones(length(DaphniaCoordinates(:,1)),1);
    %     % subplot(1,2,2); imshow(BW); axis equal; hold on
         warning('off', 'Images:initSize:adjustingMag'); 
         fig=figure('visible','off'); 
         %imshow(Mov); 
         %viscircles([DaphniaCoordinates(:,1),DaphniaCoordinates(:,2)],radi,'DrawBackgroundCircle',false,...
%             'linewidth',1);
            
        subplot(1,20,1:10); imshow(Movdiv, []);viscircles([DaphniaCoordinates(:,1),DaphniaCoordinates(:,2)],radi,'DrawBackgroundCircle',false,...
             'linewidth',1);
        subplot(1,20,11:20); imshow(BW2);
%          subplot(1,2,1), imshow(Movdiv); %imshow(MovOrig)
%          subplot(1,2,2), imshow(BW); axis equal; hold on
           %text(Tracks(i).LastCoordinates(1), Tracks(i).LastCoordinates(2), sprintf('c'), 'Color', 'r');
         if Lifespan == 1
            title(['Frame ' num2str(Frame) ': n = ' num2str(Daphniapopulation(Frame))])
         else
            title(['Frame ' num2str(Frame)])
         end
        currFrame = getframe(gcf);
        writeVideo(vidObj,currFrame);
end
%% Update data / tracking 
    
    for i=1:length(STATS) 
        AllData = [AllData; Frame, STATS(i).Area, STATS(i).Centroid, STATS(i).Eccentricity];
    end

    % Track Daphnia
    if ~isempty(Tracks)
        ActiveTracks = find([Tracks.Active]);
    else
        ActiveTracks = [];
    end

%% Update active tracks with new coordinates
    for i = 1:length(ActiveTracks)
        DistanceX = DaphniaCoordinates(:,1) - Tracks(ActiveTracks(i)).LastCoordinates(1);
        DistanceY = DaphniaCoordinates(:,2) - Tracks(ActiveTracks(i)).LastCoordinates(2);
        Distance = sqrt(DistanceX.^2 + DistanceY.^2);
        [MinVal, MinIndex] = min(Distance);
        if (MinVal <= MinDistance) & (abs(DaphniaSizes(MinIndex) - Tracks(ActiveTracks(i)).LastSize) < SizeChangeThreshold)
            Tracks(ActiveTracks(i)).Path = [Tracks(ActiveTracks(i)).Path; DaphniaCoordinates(MinIndex, :)];
            Tracks(ActiveTracks(i)).LastCoordinates = DaphniaCoordinates(MinIndex, :);
            Tracks(ActiveTracks(i)).Frames = [Tracks(ActiveTracks(i)).Frames, Frame];
            % Tracks(ActiveTracks(i)).Frames(end)
            Tracks(ActiveTracks(i)).Size = [Tracks(ActiveTracks(i)).Size, DaphniaSizes(MinIndex)];
            Tracks(ActiveTracks(i)).LastSize = DaphniaSizes(MinIndex);
            Tracks(ActiveTracks(i)).Eccentricity = [Tracks(ActiveTracks(i)).Eccentricity, DaphniaEccentricities(MinIndex)];
            Tracks(ActiveTracks(i)).Circularity = [Tracks(ActiveTracks(i)).Circularity, DaphniaCircularities(MinIndex)];
            Tracks(ActiveTracks(i)).Perimeter = [Tracks(ActiveTracks(i)).Perimeter, DaphniaPerimeters(MinIndex)];         
            Tracks(ActiveTracks(i)).MajorAxes = [Tracks(ActiveTracks(i)).MajorAxes, DaphniaMajorAxes(MinIndex)];
            Tracks(ActiveTracks(i)).MinorAxes = [Tracks(ActiveTracks(i)).MinorAxes, DaphniaMinorAxes(MinIndex)];
            Tracks(ActiveTracks(i)).Orientation = [Tracks(ActiveTracks(i)).Orientation, DaphniaOrientation(MinIndex)];
            Tracks(ActiveTracks(i)).Intensity = [Tracks(ActiveTracks(i)).Intensity, DaphniaIntensity(MinIndex)];
            Tracks(ActiveTracks(i)).IntensityMin = [Tracks(ActiveTracks(i)).IntensityMin, DaphniaIntensityMin(MinIndex)];
            Tracks(ActiveTracks(i)).IntensityMax = [Tracks(ActiveTracks(i)).IntensityMax, DaphniaIntensityMax(MinIndex)];
            Tracks(ActiveTracks(i)).Box = [Tracks(ActiveTracks(i)).Box; DaphniaBoundingBox(MinIndex,:)];
            TrackFrameNum = length(Tracks(ActiveTracks(i)).Size);
            Tracks(ActiveTracks(i)).Frame(TrackFrameNum).Image = DaphniaImage(MinIndex).Image;
            DaphniaCoordinates(MinIndex,:) = NaN;
        else
            Tracks(ActiveTracks(i)).Active = 0;
            if length(Tracks(ActiveTracks(i)).Frames) < MinTrackLength
                Tracks(ActiveTracks(i)) = [];
                ActiveTracks = ActiveTracks - 1;
            end
        end
    end

    % Start new tracks for coordinates not assigned to existing tracks
    NumTracks = length(Tracks);
    for i = 1:length(DaphniaCoordinates(:,1))
        Index = NumTracks + i;
        Tracks(Index).Active = 1;
        Tracks(Index).Path = DaphniaCoordinates(i,:);
        Tracks(Index).LastCoordinates = DaphniaCoordinates(i,:);
        Tracks(Index).Frames = Frame;
        Tracks(Index).Size = DaphniaSizes(i);
        Tracks(Index).LastSize = DaphniaSizes(i);
        Tracks(Index).Eccentricity = DaphniaEccentricities(i);
        Tracks(Index).Circularity = DaphniaCircularities(i);
        Tracks(Index).Perimeter = DaphniaPerimeters(i);
        Tracks(Index).MajorAxes = DaphniaMajorAxes(i);
        Tracks(Index).MinorAxes = DaphniaMinorAxes(i);
        Tracks(Index).Orientation = DaphniaOrientation(i);
        Tracks(Index).Intensity = DaphniaIntensity(i);
        Tracks(Index).IntensityMin = DaphniaIntensityMin(i);
        Tracks(Index).IntensityMax = DaphniaIntensityMax(i);
        Tracks(Index).Box = DaphniaBoundingBox(i,:);
        Tracks(Index).Frame(1).Image = DaphniaImage(i).Image;
    end

    % Display every PlotFrameRate'th frame
    if DisplayMode == 1
        if ~mod(Frame, PlotFrameRate)
            t1 = toc;
            PlotFrame(WTFigH, Mov, Tracks);
            pause (1);
            FigureName = ['Movie ',num2str(MovieNum),': ',File(MovieNum).MovieFile, ...
                ' - Frame ', num2str(Frame)];
            set(WTFigH, 'Name', FigureName);

            [Level,AnimalPix] = AutoThreshold(Movdiv);
        if ForceSize == 1
            AnimalPix = ForceSizePix;
        end
            Settings = [Settings; Frame, Level, AnimalPix];

            t2 = toc; tic;
            fps = PlotFrameRate/t1;
            fprintf('\nFrame: %5d - Time: %1.3f fps (%1.2f s) Level: (%1.3f/%3d)',Frame,fps,t2-t1,Level,AnimalPix)

            if (t1/PlotFrameRate) > 10     % stop if it takes too long to analyze- probably an error
                break;
            end
        end
    end
    
    Frames(Frame).Coordinate = DaphniaCoordinates;


    h=waitbar(Frame/EndFrame);
end

close(h);

if createvideo == 1
    close(vidObj);
end

% Get rid of invalid tracks
DeleteTracks = [];
for i = 1:length(Tracks)
    if length(Tracks(i).Frames) < MinTrackLength
        DeleteTracks = [DeleteTracks, i];
    end
end
Tracks(DeleteTracks) = [];

ExpData.PixelSize = File(MovieNum).PixelSize;
ExpData.ArenaSize = File(MovieNum).ArenaSize;
ExpData.FrameRate = File(MovieNum).FrameRate;
ExpData.MovieNum = MovieNum;
ExpData.TrackTime = datestr(now);
ExpData.TrackedFrames = File(MovieNum).TrackFrames - File(MovieNum).StartFrame + 1;
ExpData.TrackStats.MinDaphniaArea = MinDaphniaArea;  
ExpData.TrackStats.MaxDaphniaArea = MaxDaphniaArea;
ExpData.TrackStats.AnimalPix = AnimalPix;  
ExpData.TrackStats.Level = Level;
ExpData.TrackStats.MinDistance = MinDistance;
ExpData.TrackStats.SizeChangeThreshold = SizeChangeThreshold;
ExpData.TrackStats.MinTrackLength = MinTrackLength;
ExpData.TrackSettings = Settings;
ExpData.Coordinate = Frames;

% Save Fragment File
% disp([datestr(now),' Saving Data for Movie ',num2str(MovieNum),', fragment ',num2str(Fragment)]);
save(char(FragmentSaveNames), 'Tracks', 'AllData', 'background', 'ExpData', 'File','Daphniapopulation','Settings','Light');
disp([datestr(now),' *** Save complete *** ']);
