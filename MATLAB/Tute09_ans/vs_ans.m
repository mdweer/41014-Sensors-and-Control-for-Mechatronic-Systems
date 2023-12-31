%% Feature detection
close all
clear all

img = imread('frame0000.jpg');
imgGray = rgb2gray(img);

% Calculate corner points using Harris Feature detector
cp = detectHarrisFeatures(imgGray);

cp.Location


%% Control

f = params.FocalLength;
p = params.PrincipalPoint;
Z = 50;
l = 0.1; %lambda 

% Populate Observation vector using values from "feature detection section"
% Populate target vector using image size (define your own target size for
% the square)

%% image_1.png
% Target = [250,250;
%           250,750;
%           750,250;
%           750,750];
%       
% Obs = [ 100.4890,  100.4890;
%         100.4890,  598.5110;
%         598.5110,  100.4890;
%         598.5110,  598.5110;];

%% image_2.png
Target = [  446,946;
            446,446;
            946,946;
            946,446
            
    ];

Obs = [313.5,    547.7;
    599.0,    140.2;
    720.9,    833.3;
    1006.4 ,   425.7;];

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