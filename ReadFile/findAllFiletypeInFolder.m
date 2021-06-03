function [ files ] = findAllFiletypeInFolder( folderName, fileType, frontConstraint )
%finds all images within 'folderName' (recursively) whose names end in 
%'fileType' and start with 'frontConstraint
%Default with find all files with '.avi' 

    if nargin==1
        fileType = '.avi';
    end
    
    if nargin < 3 || isempty(frontConstraint) == 1
        frontConstraint = '';
    end
    
    
    if folderName(end) ~= '\'
        folderName = strcat(folderName, '\');
    end
    
    %modified for use on windows machine
    if isunix
        [~,temp] = unix(['find ' folderName ' -name ' frontConstraint '*' fileType]);
        files = regexp(temp,'\n','split')';
    elseif ispc
        imageFiles = dir([folderName frontConstraint '*' fileType]);
        for i = 1:length(imageFiles)
            if ~exist('files', 'var')
                files = cell(1,1);
                files{end} = imageFiles(i).name;
            else
                files{end+1} = imageFiles(i).name;
            end
        end
    else
        disp('Platform not supported')
    end
    imageLengths = returnCellLengths(files);
    files = files(imageLengths > length(fileType));

end

