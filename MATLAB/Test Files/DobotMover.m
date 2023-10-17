% safetyStatusSubscriber = rossubscriber('/dobot_magician/safety_status');
% pause(2); %Allow some time for MATLAB to start the subscriber
% %currentSafetyStatus = safetyStatusSubscriber.LatestMessage.Data;

%set number of images to calculate
imgNo = 10;

%calibImages = zeros(,unit8);

%predeter
poses = [0.2635,0.1286, 0.0960; 0.1334, 0.0140, -0.0119; 0.2242, -0.0950, 0.0266; 0.2738,0.0218, 0.0880; 0.2492,0.0846,0.0313; 0.1930,0.0681, -0.0061;0.2635, 0.1286,0.0960;0.3020, 0.0418, -0.0034;0.1400,-0.1044, 0.0107;0.1988,-0.1083, 0.0774;0.2341, -0.0598,0.0171];
rotations = [0.9684, 0, 0, 0.2494;0.9970, 0, 0, 0.0771;-0.9847, 0, 0, 0.1744; 0.9992, 0,0,0.0397; 0.9867,0,0,0.1628; 0.9857, 0, 0, 0.1687; 1.0000,0,0,0.0085; -0.9888,0,0,0.1492;-0.8582, 0, 0, 0.5132; -0.8925,0, 0, 0.4511;-0.9416, 0,0,0.3368];

for i = 1:imgNo 

endEffectorPosition = [poses(i,1),poses(i,2), poses(i,3)];
endEffectorRotation = [rotations(i,1),rotations(i,2), rotations(i,3)];

[targetEndEffectorPub,targetEndEffectorMsg] = rospublisher('/dobot_magician/target_end_effector_pose');

targetEndEffectorMsg.Position.X = endEffectorPosition(1);
targetEndEffectorMsg.Position.Y = endEffectorPosition(2);
targetEndEffectorMsg.Position.Z = endEffectorPosition(3);

qua = eul2quat(endEffectorRotation);
targetEndEffectorMsg.Orientation.W = qua(1);
targetEndEffectorMsg.Orientation.X = qua(2);
targetEndEffectorMsg.Orientation.Y = qua(3);
targetEndEffectorMsg.Orientation.Z = qua(4);

send(targetEndEffectorPub,targetEndEffectorMsg);

pause(5)

imageTopic = rossubscriber("/camera/color/image_raw");
pause(1);
rgbimg = imageTopic.LatestMessage;
pause(1);
imgread = readImage(rgbimg);

strcat('Saving image Number: ', num2str(i))

imwrite(imgread,strcat('Images/calib',num2str(i),'.jpg'))
imshow(imgread)
end
%imshow(imgread)
%imgdata = readImage(rgbImg.LatestMessage)