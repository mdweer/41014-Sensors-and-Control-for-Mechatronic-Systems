endEffectorPoseSubscriber = rossubscriber('/dobot_magician/end_effector_poses'); % Create a ROS Subscriber to the topic end_effector_poses
pause(2); %Allow some time for MATLAB to start the subscriber
currentEndEffectorPoseMsg = endEffectorPoseSubscriber.LatestMessage;
% Extract the position of the end effector from the received message
currentEndEffectorPosition = [currentEndEffectorPoseMsg.Pose.Position.X,
                              currentEndEffectorPoseMsg.Pose.Position.Y,
                              currentEndEffectorPoseMsg.Pose.Position.Z]
% Extract the orientation of the end effector
currentEndEffectorQuat = [currentEndEffectorPoseMsg.Pose.Orientation.W,currentEndEffectorPoseMsg.Pose.Orientation.X,currentEndEffectorPoseMsg.Pose.Orientation.Y,currentEndEffectorPoseMsg.Pose.Orientation.Z]
% Convert from quaternion to euler
%[roll,pitch,yaw] = quat2eul(currentEndEffectorQuat)
eulZYX = quat2eul(currentEndEffectorQuat);

yaw = rad2deg(eulZYX(1))