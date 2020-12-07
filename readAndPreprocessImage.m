function fout = readAndPreprocessImage(filename, size)
f = imread(filename);
if ismatrix(f)  % if grayscale, then convert to RGB
    f = cat(3,f,f,f);
end
% resize image
fout = imresize(f, size);
