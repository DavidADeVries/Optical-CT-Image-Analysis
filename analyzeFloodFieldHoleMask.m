% analyzes the flood field hole mask by getting the average value and
% centre location of each hole, and then interpolates the values over the
% entire field

% 1) IMPORT IMAGE

path = 'E:\Data Files\Git Repos\Optical-CT-Image-Analysis Data\Hole Mask.bmp';

gridDims = [10, 8]; %[x,y]

image = double(imread(path));

if length(size(image)) == 3 % is 3D, average over colour channel
    image = mean(image, 3);
end


% 2) MAKE BINARY MAP OF THE HOLES

threshold = 150;

binaryMask = image >= threshold; % true is where a hole is

speckSize = 25;

% remove specks
binaryMask = bwareaopen(binaryMask, speckSize);


% 3) GET HOLE COORDS AND AVERAGE VALUES

[holeCoords, averHoleValues] = extractBlobsWithAreaFilling_4con(binaryMask, image);

holeCentreCoords = [holeCoords(:,1) + holeCoords(:,3)/2, holeCoords(:,2) + holeCoords(:,4)/2];

sortedX = sort(holeCentreCoords(:,1),'ascend');
sortedY = sort(holeCentreCoords(:,2),'ascend');

xGridPoints = zeros(gridDims(1),1);
yGridPoints = zeros(gridDims(2),1);

for i=1:gridDims(1)
    xGridPoints(i) = mean(sortedX((i-1)*gridDims(2)+1:i*gridDims(2)));
end

xSpacing = mean(xGridPoints(2:end)-xGridPoints(1:end-1));

for i=1:gridDims(2)
    yGridPoints(i) = mean(sortedY((i-1)*gridDims(1)+1:i*gridDims(1)));
end

ySpacing = mean(yGridPoints(2:end)-yGridPoints(1:end-1));

% get grid
xGridPoints = xGridPoints(1):xSpacing:xGridPoints(1)+(gridDims(1)-1)*xSpacing;
yGridPoints = yGridPoints(1):ySpacing:yGridPoints(1)+(gridDims(2)-1)*ySpacing;

gridPointValues = zeros([gridDims(2), gridDims(1)]);

for x=1:gridDims(1)
    for y=1:gridDims(2)
        distances = sqrt(sum((holeCentreCoords - [xGridPoints(x), yGridPoints(y)]).^2 ,2));
        
        [~,sortIndex] = sort(distances, 'ascend');
        
        gridPointValues(y, x) = averHoleValues(sortIndex(1));
    end
end


% 4) INTERPOLATE FOR ENTIRE FIELD WITH SCATTER POINTS

dims = size(image);

xSample = 1:1:dims(2);
ySample = 1:1:dims(1);

[X,Y] = meshgrid(xSample, ySample);

F = scatteredInterpolant(holeCentreCoords(:,1), holeCentreCoords(:,2), averHoleValues, 'linear');
scatterInterValues = F(X, Y);

figure();

interval = 2.5;

imshow(interval.*round(scatterInterValues./interval),[]);
hold on;
rectangle(...
    'Position', [sortedX(1), sortedY(1), sortedX(end)-sortedX(1), sortedY(end)-sortedY(1)],...
    'EdgeColor', 'r');


% 5) INTERPOLATE FOR ENTIRE FIELD WITH GRID POINTS

dims = size(image);

xSample = 1:1:dims(2);
ySample = 1:1:dims(1);

[X,Y] = meshgrid(xSample, ySample);

gridInterValues = interp2(xGridPoints, yGridPoints, gridPointValues, X, Y, 'cubic');

figure();

interval = 2.5;

imshow(interval.*round(gridInterValues./interval),[]);
hold on;
rectangle(...
    'Position', [xGridPoints(1), yGridPoints(1), xGridPoints(end)-xGridPoints(1), yGridPoints(end)-yGridPoints(1)],...
    'EdgeColor', 'r');

