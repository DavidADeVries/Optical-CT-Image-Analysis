% used to analyze the optical distortion pin phantom

% STEP 1: LOAD .VFF FILE

numSlices = 256;
voxelSize = 0.5; %[mm]

path = 'E:\Data Files\Git Repos\Optical-CT-Image-Analysis Data\20180126_590nm_distortion_2pg_HR.vff';

dataSet = openOptCtVistaRecon(path, numSlices);


% STEP 2: THRESHOLD PINS

% pins have a low attenuation value
threshold = -0.8;

binaryMap = (dataSet <= threshold);


% STEP 3: MAKE PIN MEASUREMENTS ON EACH SLICE

% number of slices to average over (will always take the central slices)
averageSlices = 100;
numPins = 9;

% holds distance from centre pin to other pins
% ordered from closest to farthest pin
pinDistances = zeros(numPins-1, averageSlices);

% flag if you want to see the progress
showMeasurements = false;

if showMeasurements       
    fig = figure(); 
end

% loop through slices
for i=1:averageSlices
    sliceIndex = floor((numSlices / 2) - (averageSlices / 2)) + i - 1;
    slice = binaryMap(:,:,sliceIndex);
    
    % remove specks (most pins have >10 pixels)
    slice = bwareaopen(slice, 10);
    
    % get coords of pins
    pinCoords = extractBlobsWithAreaFilling_4con(slice);
    
    if length(pinCoords) ~= numPins
        error('More pins found then specified, please adjust settings.');
    else
        centreCoords = ones(1,2) .* (numSlices + 1)/2;
        
        pinCentreCoords = [pinCoords(:,1) + pinCoords(:,3)/2, pinCoords(:,2) + pinCoords(:,4)/2];
        
        % want to order pins from closest to centre to farthest
        pinToCentreLengths = sqrt(sum((centreCoords - pinCentreCoords).^2, 2));
        
        [~,sortIndex] = sort(pinToCentreLengths, 'ascend');
        
        centrePinCoords = pinCentreCoords(sortIndex(1),:);
        
        centrePinToPinsLengths = sqrt(sum((centrePinCoords - pinCentreCoords).^2, 2));
                
        [~,sortIndex] = sort(centrePinToPinsLengths, 'ascend');
        
        for j=2:numPins
            pinDistances(j-1, i) = sqrt(sum((centrePinCoords - pinCentreCoords(sortIndex(j),:)).^2)) .* voxelSize;
        end
            
        if showMeasurements            
            imshow(dataSet(:,:,sliceIndex), []);
            drawnow;
            hold on;
            
            for j=2:numPins
                x1 = pinCentreCoords(sortIndex(1),1);
                y1 = pinCentreCoords(sortIndex(1),2);
                
                x2 = pinCentreCoords(sortIndex(j),1);                
                y2 = pinCentreCoords(sortIndex(j),2);
                
                h = line([x1, x2], [y1, y2], 'Color', (0.5 + 0.5 * ((j-1)/(numPins-1))).*[1 0 0]);
                
                drawnow;
                pause(0.05);
                
                delete(h);
            end
            
            hold off;
            
            drawnow;
        end
    end
end

if showMeasurements  
	 delete(fig);
end            


% STEP 4: AVERAGE PIN MEASUREMENTS ACROSS SLICES

averagePinDistances = mean(pinDistances,2);

disp(averagePinDistances);