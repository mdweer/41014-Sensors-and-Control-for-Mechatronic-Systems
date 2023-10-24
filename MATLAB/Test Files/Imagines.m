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
imageSize = [size(I, 1),size(I, 2)]
params = estimateCameraParameters(imagePoints,worldPoints,'ImageSize',imageSize);

%params.PatternExtrinsics.Translation

% showReprojectionErrors(params);

figure;
showExtrinsics(params);
% 
% drawnow;

% figure; 
% imshow(imageFileNames{1}); 
% hold on;
% plot(imagePoints(:,1,1), imagePoints(:,2,1),'go');
% plot(params.ReprojectedPoints(:,1,1),params.ReprojectedPoints(:,2,1),'r+');
% legend('Detected Points','ReprojectedPoints');
% hold off;

rotmat = params.PatternExtrinsics.R

rotmat
%%
%%while 1

img = rossubscriber("/camera/color/image_raw");
pause(1);
rgbimg = img.LatestMessage;
pause(0.5);
imgread = readImage(rgbimg);
%imgread = imread('frame0000.jpg');
%imgGray = rgb2gray(img);


[imagePointsVS,boardSizeVS] = detectCheckerboardPoints(imgread);

J = insertText(imgread,imagePointsVS,1:size(imagePointsVS,1));
J = insertMarker(J,imagePointsVS,'o','Color','red','Size',5);
imshow(J);
title(sprintf('Detected a %d x %d Checkerboard',boardSizeVS));

% Calculate corner points using Harris Feature detector
%cp = detectHarrisFeatures(imgGray);

%cp.Location;

%% Control

f = params.FocalLength(1,1);
p = params.PrincipalPoint;
Z = 50;
l = 0.1; %lambda 

% Populate Observation vector using values from "feature detection section"
% Populate target vector using image size (define your own target size for
% the square)

% imagePointsVS(1,2)
% imagePointsVS(4,2)
% imagePointsVS(17,2)
% imagePointsVS(20,2)

%% 
Target = [360,280;
          360,175;
          220,240;
          220,175];
            
   
sze = size(imagePointsVS)
Obs = [imagePointsVS(20,1),    imagePointsVS(20,2);
    imagePointsVS(17,1),    imagePointsVS(17,2);
    imagePointsVS(4,1),    imagePointsVS(4,2);
    imagePointsVS(1,1), imagePointsVS(1,2);]
%%
xy = (Target-p)/f;
Obsxy = (Obs-p)/f;

%%
n = length(Target(:,1));

Lx = [];
for i=1:n;
    Lxi = FuncLx(xy(i,1),xy(i,2),Z);
    Lx = [Lx;Lxi];
end

%%
e2 = Obsxy-xy;
e = reshape(e2',[],1);
de = -e*l;

%%
Lx2 = inv(Lx'*Lx)*Lx';
Vc = -l*Lx2*e
pause(0.5);
%end