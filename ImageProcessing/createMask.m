function TankMask = createMask(rgImage)
% based on user input, define chamber locations (60 chamber lifespan device)
close all

tankFig = figure;
tankAxis = axes();
vidHeight = size(rgImage,1);
vidWidth = size(rgImage,2);
k = false;
dStatus = false;

%axes(chamberAxis);
axis image
imshow(rgImage)
title('Click on the centers of the corner chambers')
[r, c] = ginput(4); % grab four corner points
hold on; 
% rgSample2=imcrop(rgImage,box);
locMat = zeros(4,2);
chamberCenters = zeros(60, 2);
TankMat = false(vidHeight, vidWidth);

%% Determine which corner is which 
[~, i] = sort(r); %sorts in ascending order
[~, j] = sort(c);



for k= 1:2
    locMat(i(k),1) = 1; %1 for 2 lower values
    locMat(j(k),2) = 1; %1 for 2 lower values
end

checkMat = [1 1;0 1; 1 0; 0 0];
for f= 1:4
    b = ismember(locMat, checkMat(f,:), 'rows');
    idx = find(b);
    if sum(b) == 1
        if f ==1
            topleft = [r(idx), c(idx)];
        elseif f==2
            topright = [r(idx), c(idx)];
        elseif f== 3
            bottomleft = [r(idx), c(idx)];
        elseif f== 4
            bottomright = [r(idx), c(idx)];
        end
    else
        dStatus = true;
        disp('manual chamber identification error')
        createChamberMask(tankAxis, vidHeight, vidWidth, rgImage);
    end
    
end

TankMat(topleft(2):bottomleft(2), topleft(1):topright(1)) = true;
f=figure; imshow(TankMat);
close(f)
TankMask = TankMat;
close(tankFig)