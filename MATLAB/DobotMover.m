safetyStatusSubscriber = rossubscriber('/dobot_magician/safety_status');
pause(2); %Allow some time for MATLAB to start the subscriber
%currentSafetyStatus = safetyStatusSubscriber.LatestMessage.Data;
imgNo = 3;

%calibImages = zeros(,unit8);

poses = [0.2635,0.1286, 0.0960; 0.1334, 0.0140, -0.0119; 0.2242, -0.0950, 0.0266 ];
rotations = [0.9684, 0, 0, 0.2494;0.9970, 0, 0, 0.0771;-0.9847, 0, 0, 0.1744];

for i = 1:imgNo 

endEffectorPosition = [poses(i,1),poses(i,2), poses(i,3)]
endEffectorRotation = [rotations(i,1),rotations(i,2), rotations(i,3)]

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

pause(1)

imageTopic = rossubscriber("/camera/color/image_raw");
pause(1);
rgbimg = imageTopic.LatestMessage;
pause(1);
imgread = readImage(rgbimg);
imwrite(imgread,strcat('calib',num2str(i),'.jpg'))
end
%imshow(imgread)
%imgdata = readImage(rgbImg.LatestMessage)