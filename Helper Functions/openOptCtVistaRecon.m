function imgData = openOptCtVistaRecon(path, numSlices)
% imgData = openOptCtVistaRecon(path, numSlices)

dataSize = ones(1,3) * numSlices;

fid = fopen(path, 'r');
data = fread(fid, inf, '*uint8');
fclose(fid);

offset = size(data,1) - prod(dataSize) * 4 + 1;

imgData = data(offset:end);
imgData = typecast(imgData, 'single');
imgData = swapbytes(imgData);
imgData = reshape(imgData, dataSize);

imgData = double(imgData);

end

