imageTopic = rossubscriber("/camera/color/image_raw");
pause(1);
rgbimg = imageTopic.LatestMessage
pause(1);
imgread = readImage(rgbimg)
