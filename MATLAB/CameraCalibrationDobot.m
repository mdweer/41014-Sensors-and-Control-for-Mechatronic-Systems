%configuration parameters

%set square size
squareSize = 33;

%set number of images to calculate
imgNo = 10;

%calibImages = zeros(,unit8);

%predetermined end effector points to move to
%Poses X Y Z
%rotations X Y Z W
poses = [0.2635,0.1286, 0.0960; 0.1334, 0.0140, -0.0119; 0.2242, -0.0950, 0.0266; 0.2738,0.0218, 0.0880; 0.2492,0.0846,0.0313; 0.1930,0.0681, -0.0061;0.2635, 0.1286,0.0960;0.3020, 0.0418, -0.0034;0.1400,-0.1044, 0.0107;0.1988,-0.1083, 0.0774;0.2341, -0.0598,0.0171];
rotations = [0.9684, 0, 0, 0.2494;0.9970, 0, 0, 0.0771;-0.9847, 0, 0, 0.1744; 0.9992, 0,0,0.0397; 0.9867,0,0,0.1628; 0.9857, 0, 0, 0.1687; 1.0000,0,0,0.0085; -0.9888,0,0,0.1492;-0.8582, 0, 0, 0.5132; -0.8925,0, 0, 0.4511;-0.9416, 0,0,0.3368];
%%
%Ros initilization

jointStateSubscriber = rossubscriber('/dobot_magician/joint_states'); % Create a ROS Subscriber to the topic joint_states
img = rossubscriber("/camera/color/image_raw");
imageTopic = rossubscriber("/camera/color/image_raw");
pause(2);
%%
%for each position send move robot to position and save an image
for i = 1:imgNo 

endEffectorPosition = [poses(i,1),poses(i,2), poses(i,3)];
endEffectorRotation = [rotations(i,1),rotations(i,2), rotations(i,3)];

[targetEndEffectorPub,targetEndEffectorMsg] = rospublisher('/dobot_magician/target_end_effector_pose');

%Format end effector message positions
targetEndEffectorMsg.Position.X = endEffectorPosition(1);
targetEndEffectorMsg.Position.Y = endEffectorPosition(2);
targetEndEffectorMsg.Position.Z = endEffectorPosition(3);

qua = eul2quat(endEffectorRotation);
targetEndEffectorMsg.Orientation.W = qua(1);
targetEndEffectorMsg.Orientation.X = qua(2);
targetEndEffectorMsg.Orientation.Y = qua(3);
targetEndEffectorMsg.Orientation.Z = qua(4);

%send end effector position
send(targetEndEffectorPub,targetEndEffectorMsg);

%wait for the robot to enter desired position
pause(5)

%subscribe to image, convert to matlab format


rgbimg = imageTopic.LatestMessage;
pause(0.1);
imgread = readImage(rgbimg);

%strcat('Saving image Number: ', num2str(i))

%save images as calib(i).jpg
imwrite(imgread,strcat('Images/calib',num2str(i),'.jpg'))
imshow(imgread)
end
%%

%read saved images
images = imageDatastore("Images/");
imageFileNames = images.Files;

%detect checkerboard points
[imagePoints, boardSize] = detectCheckerboardPoints(imageFileNames);


%determine world points from pixels
worldPoints = generateCheckerboardPoints(boardSize,squareSize);

%estimate camera params
I = readimage(images,1); 
imageSize = [size(I, 1),size(I, 2)];
params = estimateCameraParameters(imagePoints,worldPoints,'ImageSize',imageSize)

showReprojectionErrors(params);

%generate a plot of relative poses
figure;
showExtrinsics(params);

%%
input("enter to start loop");

while 1

rgbimg = img.LatestMessage;
pause(0.1);
imgread = readImage(rgbimg);

%detect current checkerboard location for visual servoing

[imagePointsVS,boardSizeVS] = detectCheckerboardPoints(imgread);


%% Control

f = params.FocalLength(1,1);
p = params.PrincipalPoint;
Z = 50;
l = 0.1; %lambda 

% Populate Observation vector using values from "feature detection section"
% Populate target vector using image size (define your own target size for
% the square)


%% 
Target = [400,285;
          390,145;
          210,300;
          200,155];
            
%set the current corner locations to last detected corner locations, if points corrected incorrectly error = 0   
if size(imagePointsVS) ~= 20,2
Obs = Target;
else
Obs = [imagePointsVS(20,1),    imagePointsVS(20,2);
    imagePointsVS(17,1),    imagePointsVS(17,2);
    imagePointsVS(4,1),    imagePointsVS(4,2);
    imagePointsVS(1,1), imagePointsVS(1,2);]
end
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
pause(0.1);
%%

currentJointState = jointStateSubscriber.LatestMessage.Position % Get the latest message


%%

newPitch = currentJointState(3)-Vc(2)*0.1;
newPitch2 = currentJointState(2)+Vc(3)*0.1;

if newPitch < -0.16
    tempPitch = -0.16;
elseif newPitch > 1.33
    tempPitch = 1.30;
else
    tempPitch = newPitch;
end

if newPitch2 < -0.03
    tempPitch2 = -0.03;
elseif newPitch2 > 1.25
    tempPitch2 = 1.25;
else
    tempPitch2 = newPitch2
end

jointTarget = [currentJointState(1)-Vc(1)*0.1,tempPitch2,tempPitch,currentJointState(4)] % Remember that the Dobot has 4 joints by default.

[targetJointTrajPub,targetJointTrajMsg] = rospublisher('/dobot_magician/target_joint_states');
trajectoryPoint = rosmessage("trajectory_msgs/JointTrajectoryPoint");
trajectoryPoint.Positions = jointTarget;
targetJointTrajMsg.Points = trajectoryPoint;

%send end effector position
%send(targetEndEffectorPub,targetEndEffectorMsg);
send(targetJointTrajPub,targetJointTrajMsg);

end
