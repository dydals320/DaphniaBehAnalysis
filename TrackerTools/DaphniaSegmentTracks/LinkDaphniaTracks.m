%
% Link individual tracks from same animal together.
%
% USAGE:
%   output = LinkTracks(Tracks,maxdisp,maxfr)
%
%   Tracks: structure from ArenaTracker script
%   maxdisp: maximum displacement from end of one track to beginning of
%               next (pixels/fr)
%   maxfr: maximum frames from end of one track to beginning of next


function output = LinkDaphniaTracks(Tracks,maxdisp,maxfr)
if nargin < 3 maxfr = Inf; end
if nargin < 2 maxdisp = 0.3 * 36/2; end

%-----------------------
% Link Tracks together
%-----------------------

for tr = 1:length(Tracks)
    %data(tr, Tracks(tr).Frames) = Tracks(tr).Eccentricity;
    startfr(tr) = Tracks(tr).Frames(1);
    tracklen(tr) = length(Tracks(tr).Frames);
    endfr(tr) = max(Tracks(tr).Frames);
    endpos(tr,:) = Tracks(tr).Path(tracklen(tr),:);
    
    DistanceMax(tr) = max(Tracks(tr).Distance);
end

disp(['Linking Tracks... ',datestr(now)]); 
taken = 0; numanimals = 0; linked = [];
tic;

%% Calculate Distance Criteria for LinkTrack
% maxdisp = 2*max(DistanceMax);
%%


for tr = 1:length(Tracks)
    if startfr(tr) > min(startfr)
        active = setdiff(1:tr,linked);
        framediff = startfr(tr) - endfr(active);
        [a,b]=sort(framediff);
        b = active(b);
        c = find(a >= -1 & a < 20*10);
        if length(c) > 0
            % Reset max distance
            
            maxdisp = nanmean(Tracks(tr).Distance)*1.5; %1.2 1.5

            distance = sqrt(sum((ones(length(c),1)*Tracks(tr).Path(1,:) - endpos(b(c),:)).^2,2));
            possiblelink = b(c)'; possiblelinkframes = max(a(c)',1);
            acceptible = distance < maxdisp*possiblelinkframes ...  % shouldn't be too far away...
                            & possiblelinkframes < maxfr;
            output(tr).LinkData = [possiblelink, possiblelinkframes, distance, acceptible];
            goodlink = possiblelink(find(acceptible))';
            [used, goodlink] = veccomp(goodlink, taken);
        else
            goodlink = NaN;
        end

        if ~isnan(goodlink)
            output(tr).Link = goodlink(1);    %take first 
            taken(tr) = output(tr).Link;
            output(tr).TrackList = [output(output(tr).Link).TrackList, output(tr).Link];
            linked = [linked,output(tr).Link];
        else
            numanimals = numanimals + 1;
            output(tr).Link = numanimals;
            output(tr).TrackList = numanimals;
        end

    else
        output(tr).Link = tr;
        output(tr).TrackList = tr; % new track #s
        numanimals = numanimals + 1;
    end

    output(tr).OriginalTrack = output(tr).TrackList(1);

%     if mod(tr,10) == 0
%         t = toc; tic;
%         disp(['Track ',num2str(tr),' completed: ',num2str(t),' sec']);
%     end
end

