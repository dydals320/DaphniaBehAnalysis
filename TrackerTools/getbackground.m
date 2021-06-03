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
function background = getbackground(RawMovieName,StartFrame,EndFrame,FrameInterval)
 
FileInfo = VideoReader(RawMovieName); % aviinfo(RawMovieName);
m = FileInfo.Width;
n = FileInfo.Height;
cdatasum = zeros(n,m,'double');   %for 8-bit movies

% FileInfo = aviinfo(RawMovieName,'Robust');
FrameNum = FileInfo.NumberOfFrames;
if nargin < 2, EndFrame = FrameNum; FrameInterval = 20; StartFrame = 1; end

disp(['Background calculating from ',int2str(StartFrame),' to ',int2str(EndFrame),' in increments of ',int2str(FrameInterval)]);

progbars = 10;
for Frame = StartFrame:FrameInterval:EndFrame
    MovMain = VideoReader(RawMovieName);
    Mov = read(MovMain,Frame);
    % MovX64 = double(Mov(:,:,2))/255;
    MovX64 = double(Mov(:,:,1))/255;
    cdatasum = cdatasum + MovX64;
    if mod(Frame * progbars,(EndFrame-StartFrame+1)) < progbars*FrameInterval fprintf(':'); end
end
fprintf('\n');

cdataaverage = cdatasum./round((EndFrame-StartFrame+1)/FrameInterval);
background = uint8(round(cdataaverage*255));
