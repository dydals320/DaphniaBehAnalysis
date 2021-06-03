%
% Calculate average background image for specified video range and interval.
%
% USAGE:
%   background = getbackground(RawMovieName,StartFrame,EndFrame,FrameInterval)
% 
%   RawMovieName: movie filename
%   filename: name to display on figure

%---------------------------- 
% Yongmin Cho
% Version 1.0 
%---------------------------- 
function Light = getbackground_light(RawMovieName,StartFrame,EndFrame,FrameInterval, lighting)
 
FileInfo = VideoReader(RawMovieName); % aviinfo(RawMovieName);
m = FileInfo.Width;
n = FileInfo.Height;
cdatasum = zeros(n,m,'double');   %for 8-bit movies

% FileInfo = aviinfo(RawMovieName,'Robust');
FrameNum = FileInfo.NumberOfFrames;
if EndFrame > FrameNum
    EndFrame = FrameNum
end
if nargin < 5, EndFrame = FrameNum; FrameInterval = 20; StartFrame = 1; lighting = 0; end

disp(['Background calculating from ',int2str(StartFrame),' to ',int2str(EndFrame),' in increments of ',int2str(FrameInterval)]);
light = [];
progbars = 10;
for Frame = StartFrame:FrameInterval:EndFrame
    MovMain = VideoReader(RawMovieName);
    Mov = read(MovMain,Frame);
    % Mov(find(Mov<120 & Mov>110))=180; % 
    % MovX64 = double(Mov(:,:,2))/255;
    MovX64 = double(Mov(:,:,1))/255;
    light = [light ; mean(MovX64(:))];
    cdatasum = cdatasum + MovX64;
    if mod(Frame * progbars,(EndFrame-StartFrame+1)) < progbars*FrameInterval fprintf(':'); end
end
fprintf('\n');

TimeOn = find(diff(light) == max(diff(light)));
Light.TimeOn = TimeOn * FrameInterval - (FrameInterval - 1);
TimeOff = find(diff(light) == min(diff(light)));
Light.TimeOff = TimeOff * FrameInterval - (FrameInterval - 1);
