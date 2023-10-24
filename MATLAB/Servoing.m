img = rossubscriber("/camera/color/image_raw");
jointStateSubscriber = rossubscriber('/dobot_magician/joint_states');
while 1


pause(1);
rgbimg = img.LatestMessage;
pause(0.5);
imgread = readImage(rgbimg);
%img = imread('frame0000.jpg');
%imgGray = rgb2gray(img);


[imagePointsVS,boardSizeVS] = detectCheckerboardPoints(imgread);

% J = insertText(img,imagePointsVS,1:size(imagePointsVS,1));
% J = insertMarker(J,imagePointsVS,'o','Color','red','Size',5);
% imshow(J);
% title(sprintf('Detected a %d x %d Checkerboard',boardSizeVS));

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
Target = [400,285;
          390,145;
          210,300;
          200,155];
            
   
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

%%
% endEffectorPoseSubscriber = rossubscriber('/dobot_magician/end_effector_poses'); % Create a ROS Subscriber to the topic end_effector_poses
% pause(2); %Allow some time for MATLAB to start the subscriber
% currentEndEffectorPoseMsg = endEffectorPoseSubscriber.LatestMessage;
% % Extract the position of the end effector from the received message
% currentEndEffectorPosition = [currentEndEffectorPoseMsg.Pose.Position.X,
%                               currentEndEffectorPoseMsg.Pose.Position.Y,
%                               currentEndEffectorPoseMsg.Pose.Position.Z]
% % Extract the orientation of the end effector
% currentEndEffectorQuat = [currentEndEffectorPoseMsg.Pose.Orientation.W,currentEndEffectorPoseMsg.Pose.Orientation.X,currentEndEffectorPoseMsg.Pose.Orientation.Y,currentEndEffectorPoseMsg.Pose.Orientation.Z]
% % Convert from quaternion to euler
% %[roll,pitch,yaw] = quat2eul(currentEndEffectorQuat)
% eulZYX = quat2eul(currentEndEffectorQuat)

 % Create a ROS Subscriber to the topic joint_states
pause(0.5); % Allow some time for a message to appear
currentJointState = jointStateSubscriber.LatestMessage.Position % Get the latest message

% 
% newPose = [(currentEndEffectorPosition(1)-(Vc(1,1)*0.001)),(currentEndEffectorPosition(2)-(Vc(2,1)*0.001)),(currentEndEffectorPosition(3)-(Vc(3,1)*0.001))]
% newRoteul = [(eulZYX(1,1)+Vc(1,1)*0.01),0,0]
% newRotquat = eul2quat(newRoteul)

%%
% [targetEndEffectorPub,targetEndEffectorMsg] = rospublisher('/dobot_magician/target_end_effector_pose');
% 
% %Format end effector message positions
% targetEndEffectorMsg.Position.X = newPose(1);
% targetEndEffectorMsg.Position.Y = newPose(2);
% targetEndEffectorMsg.Position.Z = newPose(3);
% 
% qua = eul2quat(endEffectorRotation);
% targetEndEffectorMsg.Orientation.W = newRotquat(1);
% targetEndEffectorMsg.Orientation.X = newRotquat(2);
% targetEndEffectorMsg.Orientation.Y = newRotquat(3);
% targetEndEffectorMsg.Orientation.Z = newRotquat(4);

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
    tempPitch2 = newPitch2;
end

jointTarget = [currentJointState(1)-Vc(1)*0.1,tempPitch2,tempPitch,currentJointState(4)] % Remember that the Dobot has 4 joints by default.

[targetJointTrajPub,targetJointTrajMsg] = rospublisher('/dobot_magician/target_joint_states');
trajectoryPoint = rosmessage("trajectory_msgs/JointTrajectoryPoint");
trajectoryPoint.Positions = jointTarget;
targetJointTrajMsg.Points = trajectoryPoint;



%x = input("value check")
x=1;
%send end effector position
if x == 1
%send(targetEndEffectorPub,targetEndEffectorMsg);
send(targetJointTrajPub,targetJointTrajMsg);
end

x = 0;

end