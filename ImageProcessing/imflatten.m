function rgFlatImage = imflatten(rgImage,strMethod,strAxis,strBgShape,uiBgSize)
% Filename:     imflatten.m
% Date: 	    2008-08-20
% Author(s):    Ivan Caceres      (ivan.caceres@gmail.com)
%               Matt Crane        (mcrane6@mail.gatech.edu)
% Description: 	Returns "flattened" image of zstack for simplified image
%               processing.  Process used depends on user specification.
% Requires:     
% Parameters:   rgImage - Zstack to be summed in 4-D uint16 format returned
%                         from get_zstack function
%               strAxis - String indicating along which axis to sum image.
%                         Default value of 'z'
%               strMethod - String indicating which flattening technique to
%                           use on the Zstack.  Default value of 'max'
%               strBgShape - String to specify shape to use for imopen
%                            morphological operations used in background
%                            removal.  Default value of 'disk'
%               uiBgSize - Size to use of shape for imopen morphological
%                          operations used in background removal.  Default
%                          value of 25
% Returns:      udImSum - sum of all images of zstack
% Debug Codes:  ? - ?
%               ?1:  Number of arguments invalid
%               ?2:  Debug code explanation
%               ?3:  Debug code explanation
%               ?4:  Debug code explanation
%               ?5:  Debug code explanation
%               ?6:  Debug code explanation
%               ?7:  Debug code explanation
%               ?8:  Debug code explanation
%               ?9:  Debug code explanation
%               ?0:  Debug code explanation
% Change Log:
%               Version:        1.1
%               Editor:         Ivan Caceres    (ivan.caceres@gmail.com)
%               Date Edited:    2008-08-20    
%               Changes:        Added ability to flatten stack using
%                               different methods by using a switch
%                               statement. Changed function descriptions to
%                               match this change. Also changed filename to 
%                               imflatten.m. Removed for loop method of
%                               doing sum method.  Max and stand deviation
%                               algorithms contributed from Matt Crane.
%                               Used syntax from Matt's sum zstack but
%                               added normalize factor to avoid saturation.
%                               Added Matt Crane to author's list.
%
%               Version:        1.2
%               Editor:         Ivan Caceres    (ivan.caceres@gmail.com)
%               Date Edited:    2009-02-11    
%               Changes:        Added new functionality to flatten image
%                               along the dextro-sinistral axis (left-right
%                               axis or x axis). 
%               
%               Version:        1.3
%               Editor:         Ivan Caceres    (ivan.caceres@gmail.com)
%               Date Edited:    2010-04-22    
%               Changes:        Added ability to sum in all dimensions
%                              
%               Version:        1.4
%               Editor:         Ivan Caceres    (ivan.caceres@gmail.com)
%               Date Edited:    2010-04-27    
%               Changes:        Changed 'sum' option to 'avg' and default
%                               to 'max. Also commented out section which
%                               would remove background from the image
%
%               Version:        1.5
%               Editor:         author    (email)
%               Date Edited:    date    
%               Changes:        description of changes

%% Setup Default Variables
% Declare default values for arguments in case function is called without
% some parameters

strDefaultAxis = 'z';
strDefaultMethod = 'max';
strDefaultBgShape = 'disk';
uiDefaultBgSize = 25;
bAllAxis = false;

if(nargin < 5)
    uiBgSize = uiDefaultBgSize;
end
if(nargin < 4)
    strBgShape = strDefaultBgShape;
end
if(nargin < 3)
    strAxis = strDefaultAxis;
end
if(nargin < 2)
    strMethod = strDefaultMethod;
end

%% Variable Initialization
% Required since taking zstack of image returns empty column in array, ends
% up being 4-D instead of 3-D. Need to see why this is happening 
% get_zstack.m function (IC 2008-08-20)

rgImage = squeeze(rgImage);         

%% Set Axis Dimension
% Check to make sure that the axis chosen to evaluate is valid and set the
% dimension accordingly.

if(strAxis=='z')
    dim = 3;
elseif(strAxis=='x')
    dim = 1;
elseif(strAxis=='y')
    dim = 2;
else
    error('Invalid image flattening axis chosen.');
end

%% Call Sub-Function to "Flatten" Zstack

switch strMethod
    case 'avg'
        [rgFlatImage udTime] = imstacksum(rgImage,dim);
    case 'std'
        [rgFlatImage udTime] = imstackstd(rgImage,dim);
    case 'max'
        [rgFlatImage udTime] = imstackmax(rgImage,dim);
    otherwise
        error('Invalid image flattening method chosen.');
end
    
%% Remove Background Noise
% Remove background using imopen function removing elements smaller than
% specified radius size by subtracting them from original image

% rgBackground = imopen(rgFlatImage,strel(strBgShape,uiBgSize));
% rgFlatImage = imsubtract(rgFlatImage,rgBackground);

function [rgImAvg udProcTime] = imstacksum(rgZStack,dimension)
%% Average Method
% Scale maximum brightness of zstack by dividing each slice by the total
% number in series. This will prevent saturation in flattened image. Add 
% each image to eachother to create flattened image.

tic;

uiImageNum = size(rgZStack,3);
rgScaledImage = rgZStack / uiImageNum;
rgImAvg = uint16(sum(rgScaledImage,dimension));
rgImAvg = squeeze(rgImAvg);

if(dimension==1)
    rgImAvg = rgImAvg';
end

udProcTime = toc;

function [rgImStd udProcTime] = imstackstd(rgZStack,dimension)
%% Standard Deviation Method
% Compute standard deviation of each pixel along the Z axis to flatten 
% image. Any feature that is similar between planes should have a low 
% standard deviation and therefore be very faint. If a feature is detected, 
% planes should have a larger standard deviation because of differences 
% between fluorescent feature and background

tic;

rgImStd = uint16(std(double(rgZStack),[],dimension));
rgImStd = squeeze(rgImStd);

if(dimension==1)
    rgImStd = rgImStd';
end

udProcTime = toc;

function [rgImMax udProcTime] = imstackmax(rgZStack,dimension)
%% Max Intensity Method
% Flattens image by only keeping the brightest elements in each slice

tic;

rgImMax = max(rgZStack,[],dimension);
rgImMax = squeeze(rgImMax);

if(dimension==1)
    rgImMax = rgImMax';
end

udProcTime = toc;