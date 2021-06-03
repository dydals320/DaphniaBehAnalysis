% Displays ethogram of behavior and summarizes behavioral state probability
% and speed over time.  Adjusts timing according to flow properties, either
% via user input or automatically from dye experiments. Saves data to a
% file (*_ethogram.mat) and prints PDF summary pages.    
%
% USAGE:
%   Ethogram(FileName)
%
%   FileName: single filename of segmented data or cell array of multiple
%               filenames. Select with user input if none given.

function Ethogram(FileName)

addpath(genpath('C:\MATLAB\Daphnia\BehaviorTracking\DaphniaPhenotyping'));

if nargin < 1 FileName = {}; end
if length(FileName) == 0
    % Get track data for analysis
    % --------------------------
    %[FileName, PathName] = uigetfile('*_seg.mat','Select segmented track File(s) For Analysis','MultiSelect','on');
    
    [FileName, PathName] = uigetfile('*_seg.mat', 'Select segmented track File(s) For Analysis','MultiSelect','on');
    FileName = cellstr(FileName); 
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
% disp(['Batch analyzing ',num2str(NumFiles),' segmented tracks files.']);

for fnum = 1:NumFiles
        %--------------------------------------------------------------------------
        % BIG LOOP FOR EACH FILE 
        %--------------------------------------------------------------------------
        
        if exist('PathName')
            FullName = fullfile(PathName, char(FileName(fnum)));
        else
            FullName = char(FileName(fnum));
        end

        disp(sprintf('File %d of %d: %s',fnum,NumFiles,FullName));
%% Save results in subfolder
        SaveName = strrepl(FullName,'_seg.mat','_ethogram.mat');        
        [mp,mf,me] = fileparts(SaveName);
        SaveDir = [mp '\Ethogram\'];
        if ~exist(SaveDir)
            mkdir(SaveDir)
        end
        FileName2=[mf me];
        SaveName = [SaveDir FileName2];

        %------------
        % Load Data
        %------------
        clear('Tracks','DyeData','ExpData','numcycles');
        load(FullName,'Tracks','ExpData');

%% Generate ethogram and data matrices
        ethfig = findobj(get(0,'Children'),'Tag','Ethogram');
        if isempty(ethfig) ethfig = figure; set(ethfig,'Tag','Ethogram'); end

        Data = Tracks2Matrix(Tracks); % not using dye for now (ExpData.Flow,~isnan(ExpData.Flow.DelayFr));

        %------------------------------
        % Save Data and summary plots
        %------------------------------

        save(SaveName,'Data','ExpData');
        
        cmap = [0.3010, 0.7450, 0.9330; 
                0, 0.4470, 0.7410; 
                0.9290, 0.6940, 0.1250; 
                0.8500, 0.3250, 0.0980; 
                0.6350, 0.0780, 0.1840; 
                0.4940, 0.1840, 0.5560; 
                1, 1, 1];  
        
%% Ethogram
        clf;
        % Convert pixel to real distance for speed
        PixLength = 1/ExpData.PixelSize;
        TimeRate = ExpData.FrameRate;
        Spd = Data.speed.all * PixLength * TimeRate;
        
        ethfig = findobj(get(0,'Children'),'Tag','Ethogram');
        t = (1:size(Data.behmat,2)) / ExpData.FrameRate; % seconds
        
%         t=t(1:1200);
%         Data.behmat = Data.behmat(:,1:1200);
%         Data.behprob = Data.behprob(:,1:1200);
        record_time = round(ExpData.TrackedFrames / ExpData.FrameRate);
        subplot(5,1,1); image(t,1:size(Data.behmat,1),ind2rgb(Data.behmat,cmap)); ylabel('Animal #');
        title(sprintf('%s %s',FileName2(1:end-4)),'interpreter','none'); %  title(sprintf('%s %s',FileName,FlowLabel),'interpreter','none'); 
        subplot(5,1,2); stateplot(Data.behprob,[],t,0,0,0); ylabel('State probability');
        subplot(5,1,[3:4]); stateplot(Data.behprob,[],t,0.5,0,0); %hilite(1,[],[1 1 .5]); 
        ylabel('State probability'); xlim([0 t(end)]);
        subplot(5,1,5); plot(t(3:end),Spd(3:end)); %hilite(ontime,[],[1 1 .5]); 
        %subplot(5,1,5); plot(t(3:1200),Spd(3:1200)); %hilite(ontime,[],[1 1 .5]); 
        ylabel('Speed (mm/s)'); xlim([0 record_time]); ylim([0 25]); % xlim([0 t(end)]);
        % subplot(5,1,5); plot(t,Data.speed.fwdpause); ylim([0 0.4]); hilite(ontime,[],[1 1 .5]); ylabel('Speed (mm/s)'); xlim([0 t(end)]);
        xlabel('Time (sec)');
        orient(ethfig,'tall');
        print([strrep(SaveName,'.mat','_avg.pdf')],'-dpdf','-fillpage')
        % saveas(ethfig,strrepl(SaveName,'.mat','_avg.pdf'),'pdf');
%%       
clf;
ethfig = findobj(get(0,'Children'),'Tag','Ethogram');
VideoName = strrepl(FileName2,'_ethogram.mat','.avi');
[mp mf me]= fileparts(FullName);
temp = find(mp == '\');
VideoName = [mp(1:temp(end)) VideoName];

obj = VideoReader(VideoName);

file = dir(VideoName);
day = file.date;
date = day(1:11);
time = day(13:end);
%background = zeros(obj.heigh, obj.width);
background = read(obj, obj.NumberOfFrames);
imshow(background)
hold on
cc = hsv(size(Data.xmat,1));
% cmap = [0.7 0.7 0.7; 1 0.42 0.16; .3 .3 .3; .49 .18 .56; .96 .73 1; 0.9412    0.9412    0.9412]; 
if isfield(Tracks,'SmoothPath')
    for i=1:size(Data.xmat,1)
        if colormap ==0
                plot(Data.smxmat(i,1:end),Data.smymat(i,1:end),'color','r','Linewidth',0.5)
            else  
                plot(Data.smxmat(i,1:end),Data.smymat(i,1:end),'color',cc(i,:),'Linewidth',0.5)     
        end
    end
    title([sprintf(FileName2(1:end-13)), ' smooth'],'Interpreter', 'none')
else
    for i=1:size(Data.xmat,1)
        if colormap ==0
            plot(Data.xmat(i,1:end),Data.ymat(i,1:end),'color','r','Linewidth',0.5)
        else  
            plot(Data.xmat(i,1:end),Data.ymat(i,1:end),'color',cc(i,:),'Linewidth',0.5)     
        end 
    end
    title([sprintf(FileName2(1:end-13))],'Interpreter', 'none')
end

saveas(ethfig,strrepl(SaveName,'.mat','_Tracked.pdf'),'pdf');

end

%% segment of trajectories
% AniNum = 1; 
% behavior = Data.behmat(AniNum,:);
% behavior(find(behavior == 0 )) = 7;
% back = ones(1024, 1280);
% figure; imshow(back); hold on;
% %sz = 30;
% for i = 1:200 % size(Data.behmat,2)-1
%     %index = behavior(i);
%     plot(Data.smxmat(AniNum,i:i+1),Data.smymat(AniNum,i:i+1),'color',cmap(behavior(i),:),'linewidth',3);
%     % scatter(Data.smxmat(AniNum,i),Data.smymat(AniNum,i),sz, 'filled','MarkerFaceColor',cmap(index,:),'marker','s') 
% end
% text(302, 870, 'Fwd','color',[0.5 0.5 0.5],'fontsize',20);
% text(302, 871, 'FwdRun','color',[1 0 0],'fontsize',20);
% text(302, 872, 'Spin', 'color', [0 1 0], 'fontsize',20);
end

