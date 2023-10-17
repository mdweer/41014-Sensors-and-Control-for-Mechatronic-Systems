% img = imread("calib0+1i.jpg");
% imshow(img)
% [imagePoints,boardSize] = detectCheckerboardPoints(img);
% 
% J = insertText(img,imagePoints,1:size(imagePoints,1));
% J = insertMarker(J,imagePoints,'o','Color','red','Size',5);
% imshow(J);
% title(sprintf('Detected a %d x %d Checkerboard',boardSize));

images = imageDatastore("Images/");
imageFileNames = images.Files;

[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);

squareSize = 33;
worldPoints = generateCheckerboardPoints(boardSize,squareSize);

I = readimage(images,1); 
imageSize = [size(I, 1),size(I, 2)];
params = estimateCameraParameters(imagePoints,worldPoints,'ImageSize',imageSize)

showReprojectionErrors(params);

figure;
showExtrinsics(params);

drawnow;

figure; 
imshow(imageFileNames{1}); 
hold on;
plot(imagePoints(:,1,1), imagePoints(:,2,1),'go');
plot(params.ReprojectedPoints(:,1,1),params.ReprojectedPoints(:,2,1),'r+');
legend('Detected Points','ReprojectedPoints');
hold off;

