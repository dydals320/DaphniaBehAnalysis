%
% Display behavioral state probability.
%
% USAGE:
%   stateplot(behmat,plotgroups,xval,sep,stair,dotted)
% 
%   behmat: matrix of behavioral state
%   xval: x-axis values
%   sep: separation of state curves in y-dimension (0 = stacked)
%   stair: plot as stairs vs lines
%   dotted: plot horizontal dotted gridlines

function stateplot(behmat,plotgroups,xval,sep,stair,dotted)
[numc,numx] = size(behmat);

if ~exist('plotgroups') || isempty(plotgroups)                   
    plotgroups = [{'FwdRun'}, {[2]},   {[0, 0.4470, 0.7410]}; ...
                  {'Fwd'}, {[1]}, {[0.3010, 0.7450, 0.9330]}; ...    
                  {'FwdSlow'}, {[3]},   {[0.9290, 0.6940, 0.1250]}; ...
                  {'Turn'}, {[4]},   {[0.8500, 0.3250, 0.0980]}; ...
                  {'Spin'}, {[5]},   {[0.6350, 0.0780, 0.1840]	}; ...
                  {'Pause'}, {[6]},   {[0.4940, 0.1840, 0.5560]}]; ...
                       
end
if ~exist('xval') || isempty(xval) xval = 1:numx; end
if ~exist('sep') || isempty(sep) sep = 0; end
if ~exist('stair') || isempty(stair) stair = 1; end
if ~exist('dotted') || isempty(dotted) dotted = 1; end
   
sepsnap = 0.1;
gridsep = 0.1;

delx = mean(diff(xval));
numc = size(plotgroups,1);

mat2 = [];
for i=1:size(plotgroups,1)
    mat2 = [sum(behmat(plotgroups{i,2},:),1); mat2];
end
mat2 = [zeros(1,numx); mat2];
plotgroups = flipud(plotgroups);

base = ones(numc,1)*(max(abs(sep),sepsnap));
reset(gca);

for i = 1:size(plotgroups,1)
    groupcolor = plotgroups{i,3};
    xpos = xval;
    
    if sep
        ydn = repmat(base(i),1,numx);
        yup = ydn + mat2(i+1,:);
        if length(sep) > 1
            base(i+1) = base(i) + sep(i);
        else            
            if sep < 0
                base(i+1) = max(max(yup))-sep;
            else
                base(i+1) = ceil((max(max(yup))+sep)/sepsnap)*sepsnap;
            end    
        end
        maxy = base(i+1);
    else
        ydn = sum(mat2(1:i,:),1);
        yup = sum(mat2(1:i+1,:),1);
    end
    
    if stair
        yup = reshape(repmat(yup,2,1),1,[]);
        ydn = reshape(repmat(ydn,2,1),1,[]);
        xpos = reshape(repmat(xval,2,1)+repmat([-1;1]*delx/2,1,numx),1,[]);
    end
    if sep
        jbfill(xpos,yup,ydn,groupcolor,groupcolor,i>1,1);
        hold on; 
        if size(xpos,2) == size(yup,2)
            plot(xpos,yup,'Color',groupcolor/2);
        end
    else
        jbfill(xpos,yup,ydn,groupcolor,-1,i>1,1);
    end

end
axis tight
set(gca, 'xtick',[0:10:round(max(xval))-0.5])
%set(gca,'XLim',[min(xval) max(xval)] + (stair>0)*[-1 1]*delx/2);
if sep
    labels = char(plotgroups(:,1));
    set(gca,'YTick',base(1:size(plotgroups,1)),'YTickLabel',labels);
    set(gca,'YLim',[0 maxy]);
else
    set(gca,'YLim',[0 1]);
end
hold on;

if sep
    ylist = [];
    for i = 1:size(plotgroups,1)
        ylist = [ylist, base(i)+gridsep:gridsep:(base(i+1)-0.001)];
    end
    if dotted
        for i = 1:length(ylist)
            line(get(gca,'XLim'),[1 1]*ylist(i),'Color',[1 1 1],'LineStyle',':','LineWidth',0.2);
        end
    end
end
    
% legendtext = char('(out of bounds)','Forward Run','Pause','Reversal','Omega Reverse','Omega Forward');
% legendcolor = cmap(2:7,:);
% legendtextcolor = [0.5 0.5 0.5; zeros(5,3)];
% legendxy = [0.75,1.05];
% legenddelta = [0 -0.1];
% legendbox = [0.25,0.075];
%     
% dalegend(legendtext,legendxy,legenddelta,legendbox,legendcolor,legendtextcolor);


