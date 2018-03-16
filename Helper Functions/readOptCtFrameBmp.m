function image = readOptCtFrameBmp(path)
    frameDims = [1024 768];

    fid = fopen(path);
    
    data = fread(fid, inf, 'uint16');
    
    fclose(fid);
    
    data = data(28:end); %strip header
    
    image = imrotate(reshape(data, frameDims), 90);
    
    image = double(image); %convert to double so we can do math!
end

