% v3: only consider forward swimming, forward running, turning, rapid
% turning, pause, sinking
% Analyze and correct specific behaviors in daphnia tracks.
%
% USAGE:
%   TrackAnalysis = AnalyzeTrack(Segment,SegAnalysis,trackbox,Settings)
% 
%   Segment: structure containing data for each track segment
%   SegAnalysis: structure of post-segmentation analysis
%   Settings: segmentation settings structure
%   TrackAnalysis: output analysis structure


function TrackAnalysis = AnalyzeDaphniaTrackForScatter(CurrentTrack,Settings) 
%% 
xy = CurrentTrack.Path;
frames = CurrentTrack.Frames;
trlength = length(frames);

%% Calculate Curvature of trajectories
xy_new = sgolayfilt(xy,3,25);
Curv = LineCurvature2D(xy_new);
Norm = LineNormals2D(xy_new);

% Calculated from orientation parameter of body shape (regionprops). Not a angle from path. 
bodyangle = mod([CurrentTrack.Orientation]+30,60)-30;      % make the range from -30 to +30 degrees
bodyangle360 = mod([CurrentTrack.Orientation]+30,360)-30;  % make the range from -30 to +330 degrees
ecc = sqrt(1 - CurrentTrack.Eccentricity.^2);              % eccentricity = minor axis / major axis
mindistance = Settings.StallDistance;  % max pixel movement per frame for stall

[smang, smangvel, smangacc,   smdist] = angle(xy_new);   % based on smoothed centroid data as mean between adjacent
[  ang,   angvel,   angacc, origdist] = angle2(xy_new);  % based on raw centroid data
niceangle = ang + 360*(ang < 0);        % make the range from   0 to +360 degrees
niceangle = mod(niceangle+30,360)-30;   % make the range from -30 to +330 degrees
pathangle = mod(ang+30,60)-30;          % make the range from -30 to +30 degrees
smpathangle = mod(smang+30,60)-30;
    

%% Find frames for distinctive behaviors
Fwdfr = []; Fwdrun = [];
pauselast=[];
origdist(1) = NaN;
stallfr = find(origdist < mindistance);
Fwdfr = find(origdist >= mindistance);
Turnfr = find(abs(Curv) >= 0.25); 
Fwdrun = find(origdist > Settings.FwdRunFr);

%% Test
% CurrentTrack.Path = Tracks(4).Path;
% figure, imshow(background)
% background = ones(1024, 1280);
% plot(xy_new(:,1),xy_new(:,2));
% % for i=1:size(xy_new,1)
% %     text(xy_new(i,1)+2, xy_new(i,2), sprintf('%.6s', num2str(Curv(i)))); 
% % end
% hold on
% scatter(xy_new(Turnfr,1),xy_new(Turnfr,2));
%scatter(xy_new(SharpTurns,1),xy_new(SharpTurns,2));

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

code = zeros(length(CurrentTrack.Frames),1); 
code(Fwdfr) = 1;
code(Fwdrun) = 2;
code(stallfr) = 3;
code(Turnfr) = 4;

% Find frames in spinning
SpinFrame = round(Settings.FrameRate*5);
SpinRef = zeros(length(CurrentTrack.Frames),1);
windowSize = SpinFrame+round(Settings.FrameRate);
for i=1:(floor(length(code)/windowSize)-1)*windowSize
    SpinInd = find(code(i:i+windowSize-1) == 4 | code(i:i+windowSize-1) == 5);
    SpinRef(SpinInd+i-1) = 1;
    
    if sum(SpinRef(i:i+windowSize-1)) >= SpinFrame
        code(SpinInd+i-1) = 5;
    end
end

% find frames in pause
pauseframeset = round(Settings.FrameRate);
temp = [true; diff(stallfr) ~=1];
temp2 = cumsum(temp);
temp3 = histc(temp2, 1:temp2(end));
idx = find(temp);
pausestart = stallfr(idx(temp3 >= pauseframeset));
idx2 = find(temp == 1);

if exist('pausestart')
    for i=1:length(pausestart)
        a = find(stallfr == pausestart(i));
        b = find(idx2 >= a);
        if length(b) >1
            seq = [stallfr(idx(b(1))):stallfr(idx(b(2))-1)]';
        else
            seq = [stallfr(idx(b(1))):stallfr(end)]';
        end
        pauselast = [pauselast; seq];
    end
    
    [c,nostallfr] = veccomp(1:trlength,pauselast);
    pausefr=pauselast;
else
    pausefr = [];
end

code(pausefr) =6;
code(find(code == 0)) = 7;

%% Analyze animal size
relativesize = CurrentTrack.Size / median(CurrentTrack.Size);
collision = relativesize > Settings.CollisionRelSize;
relativelength = CurrentTrack.MajorAxes / max(CurrentTrack.MajorAxes(~collision));

%% Analyze behaviors

%totalturns = length(Turns) + length(SharpTurns);
spd = origdist; %./ Settings.PixelSize * Settings.FrameRate;
%spd(1:3) = NaN;

%find(isnan(CurrentTrack.Frames) == 1)
%find(code == 6)

% Raw Data
TrackAnalysis.OriginalDistance = origdist;
TrackAnalysis.Distance = origdist;
TrackAnalysis.Speed = spd;
TrackAnalysis.pathang = pathangle;
TrackAnalysis.pathangvel = angvel;
TrackAnalysis.smoothxy = xy_new;

% Analyzed results
TrackAnalysis.StallFr = stallfr';
TrackAnalysis.NoStallFr = nostallfr;
TrackAnalysis.CollFr = find(collision);
TrackAnalysis.Length = length(CurrentTrack.Frames);
TrackAnalysis.MaxFr = max(CurrentTrack.Frames);

TrackAnalysis.Beh = code;


%--------------------------------------------------------------------------

function [ang,angvel,angacc,dist] = angle(pos)

len = size(pos,1);
if len >= 2
    smpos = [pos(1,:); (pos(2:len,:)+pos(1:len-1,:))/2; pos(len,:)];
    % smpos = [pos(1,:); (pos(3:len,:)+pos(2:len-1,:)+pos(1:len-2,:))/2; pos(len,:)];
    delpos = smpos(2:len+1,:)-smpos(1:len,:);
    ang = -atan2(delpos(:,2),delpos(:,1)) * 180 / pi;

    angvel = [0; ang(2:len)-ang(1:len-1)];
    angvel = mod(angvel+180,360)-180;

    angacc = [0; angvel(2:len)-angvel(1:len-1)];

    dist = sqrt(sum(delpos.^2,2));
else
    ang = 0;
    angvel = 0;
    angacc = 0;
    dist = 0;
end
%--------------------------------------------------------------------------

function [ang,angvel,angacc,dist] = angle2(pos)

len = size(pos,1);
if len >= 2
    delpos = pos(2:len,:)-pos(1:len-1,:); % abs
    ang = atan2(delpos(:,2),delpos(:,1)) * 180 / pi;
    ang = abs([ang(1); ang]);
    %absang = abs(ang);

    angvel = abs([ang(2:len)-ang(1:len-1); 0]);
    % angvel = mod(angvel+180,360)-180;
    %absangvel = abs([absang(2:len)-absang(1:len-1); 0]);
    angacc = [0; angvel(2:len)-angvel(1:len-1)];

    dist = sqrt(sum(delpos.^2,2));
    dist = [0; dist];
   
   %% Test
%     figure, plot(pos(:,1),pos(:,2));
%     for i=1:500 %size(ang,1)    
%        text(pos(i,1),pos(i,2), sprintf('%0.6s', num2str((i)))) % ,'color','r') %);
%     end

        
else
    ang = 0;
    angvel = 0;
    angacc = 0;
    dist = 0;
end