# 41014-Sensors-and-Control-for-Mechatronic-Systems

# Dependancies
MATLAB Toolboxes:
Computer vision toolbox:
https://au.mathworks.com/help/vision/index.html?s_tid=CRUX_lftnav


ROS drivers:
dobot drivers used in this project:
https://github.com/gapaul/dobot_magician_driver

Camera driver
Note that intel realsense camera was used in this project using the drivers below:
https://github.com/IntelRealSense/realsense-ros/tree/ros1-legacy

Note that any camera that runs through ROS can be used within this code.
It simply requires the subscribed camera topic to be changed

# Running the Program

To run this program first the dobot drivers should be launched with the following command
```
roslaunch dobot_magician_driver dobot_magician.launch
```

next run the ros camera node (the specifics of this command will depend on your camera)
in my case i am using the realsense camera, so the command is as follows:

```
roslaunch realsense2_camera rs_camera.launch
```
The final step is to execute below in the matlab terminal
```
rosinit
```

then run the CameraCalibrationDobot.m file under MATLAB
note that the MATLAB folder under this git repo should be open as the path in matlab as the file saves and reads the calibration images in the /images file
