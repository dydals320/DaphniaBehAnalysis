%
% Create data matrices for each animal, including behavior ethogram, speed, 
% position, and direction. Can adjust timing according to flow properties.
%
% USAGE:
%   output = Tracks2Matrix(Tracks,Timing,fillgaps)
%
%   Tracks: Tracks structure from ArenaTracker script
%   Timing: structure indicating fluid flow properties, with fields:
%       DelayFr: delay (frames) from valve switch to upstream switch
%       VelocityPixPerFr: flow velocity in pixles per frame
%   fillgaps: fills single frame gaps for display
%   output: data matrices for animal behavior, speed, position, direction


function output = Tracks2Matrix_multi(Tracks,Timing,fillgaps)
warning('off','MATLAB:divideByZero');

if ~exist('Timing') || isempty(Timing)
    Timing.DelayFr = 0;
    Timing.VelocityPixPerFr = 0;
end
if ~exist('fillgaps') fillgaps = 0; end
    
numanimals = max([Tracks.OriginalTrack]);
numframes = max([Tracks.Frames]);

xmat = NaN*single(ones(numanimals,numframes)); ymat = xmat; behmat = xmat; spdmat = xmat; dirmat = xmat;
for tr = 1:length(Tracks)
    if length(Tracks(tr).OriginalTrack) == 0
        break
    end 
%     if ~isfield(Tracks,'Stall')
%         Tracks(tr).Stall = [];
%     end
%     [a,NoStallFrames] = veccomp(1:length(Tracks(tr).Frames), Tracks(tr).Stall);     % build list of frames not stalled
% 
%%
    frames = Tracks(tr).Frames;
    xmat(Tracks(tr).OriginalTrack, frames) = Tracks(tr).Path(:,1)';
    ymat(Tracks(tr).OriginalTrack, frames) = Tracks(tr).Path(:,2)';
    if isfield(Tracks(tr),'SmoothPath')
        smxmat(Tracks(tr).OriginalTrack, frames) = Tracks(tr).SmoothPath(:,1)';
        smymat(Tracks(tr).OriginalTrack, frames) = Tracks(tr).SmoothPath(:,2)';
    end
    behmat(Tracks(tr).OriginalTrack, frames(1:end)) = Tracks(tr).Beh;
    spdmat(Tracks(tr).OriginalTrack, frames(1:end)) = Tracks(tr).Speed;
    dirmat(Tracks(tr).OriginalTrack, frames) = Tracks(tr).PathAngle;

end
%% Image 
% ethfig = findobj(get(0,'Children'),'Tag','Ethogram');
% if isgraphics(ethfig)==1   % was: if ethfig
%     cmap = [1 1 1;.7 .7 .7; .7 .7 .7; 0 0 0; .3 .3 .3; .6 0 0; 1 .2 .2; 1 1 1; .9 .9 .9];
%     figure(ethfig); clf;
%     MaximizeWindow(ethfig);
%     subplot(3,2,2); imagesc(xmat); colorbar; title('X (pixel)');
%     subplot(3,2,4); imagesc(ymat); colorbar; title('Y (pixel)');
%     subplot(3,2,6); imagesc(dirmat); colorbar; title('Direction (deg)');
%     subplot(3,2,1); image(ind2rgb(behmat,cmap)); colorbar; title('Behavior');
%     subplot(3,2,3); imagesc(spdmat); colorbar; title('Speed (mm/s)');
%     subplot(3,2,5); image(ind2rgb(1+~isnan(behmat)+iselement(behmat,[1:6]),[1 1 1; .5 .5 .5; 0 0 0])); colorbar; title('Valid data');
% end

%%
if isfield(Tracks(tr),'SmoothPath')
    smxind = find(smxmat == 0);
    smyind = find(smymat == 0);
    smxmat(smxind) = NaN;
    smymat(smyind) = NaN;
    output.smxmat = smxmat;
    output.smymat = smymat;
end

output.xmat = xmat;
output.ymat = ymat;

output.dirmat = dirmat;
output.behmat = behmat;
output.spdmat = spdmat;
behmat(find(isnan(behmat))) = 7;
behhist = hist(behmat,1:7);
if size(behhist,1) > 1
    behnum = sum(behhist(1:6,:));
    output.behprob = behhist(1:6,:) ./ repmat(behnum,6,1);
elseif size(behhist,1) ==1
    behnum = sum(behhist(1:6));
    output.behprob = behhist(1:6) ./ repmat(behnum,6,1);
else
    printf('No detected animal')
    return
end

output.behnum = behnum;

% Not using specific behavior mode for all velocity calculation
% spdmat(find(~iselement(behmat,1:6))) = NaN;
output.speed.all = nanmean(spdmat,1);
spdmat(find(~iselement(behmat,[1 2 4]))) = NaN;
output.speed.fwdpause = nanmean(spdmat,1);
spdmat(find(~iselement(behmat,1:6))) = NaN;
output.speed.forward = nanmean(spdmat,1);



% if size(data,2) > cycle*cycles*framerate*60
%     data = data(:,1:cycle*cycles*framerate*60);
% end
% data(1,cycle*cycles*framerate*60) = 0;
% turns(1,cycle*cycles*framerate*60) = 0;
% 
% %data2 = reshape(data',cycle*framerate*60,[])';
% data2 = []; turn2 = []; %fdata2 = [];
% for i = 1:cycles
%     data2 = [data2; data(:,((i-1)*cycle*framerate*60 + 1):i*cycle*framerate*60)];
%     turn2 = [turn2; turns(:,((i-1)*cycle*framerate*60 + 1):i*cycle*framerate*60)];
%     %fdata2 = [fdata2; fdata(:,((i-1)*cycle*framerate*60 + 1):i*cycle*framerate*60)];
% end
% if ~all(size(data2) == size(turn2))
%     turn2(size(data2,1),size(data2,2))=0;
% end
% 
% % Clean up speed variable
% if size(speed,2) > cycle*cycles*framerate*60
%     speed = speed(:,1:cycle*cycles*framerate*60);
% end
% speed(size(data,1),cycle*cycles*framerate*60) = 1;   % make one point = 1 for uniform scaling
% 
% speed2 = []; %fdata2 = [];
% for i = 1:cycles
%     speed2 = [speed2; speed(:,((i-1)*cycle*framerate*60 + 1):i*cycle*framerate*60)];
%     %fdata2 = [fdata2; fdata(:,((i-1)*cycle*framerate*60 + 1):i*cycle*framerate*60)];
% end
% 
% 
% animals = size(data,1);
% timepoints = size(data,2);
% 
% cmap = [1 1 1; 0.9 0.9 0.9; .7 .7 .7; .3 .3 .3; 0 0 0; .6 0 0; 1 .2 .2];
% cmap = [1 1 1; 1 1 1; .7 .7 .7; .3 .3 .3; 0 0 0; .6 0 0; 1 .2 .2];
% 
% PlotCodes = 3:6; PlotSpacing = 0; PlotTimeBehaviorSpeed;
% 
% 
