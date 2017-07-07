% Clear the workspace and the screen
sca;
close all;
clearvars;
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Sound Setup
% Initialize Sounddriver
InitializePsychSound(1);
% Number of channels and frequency of the sound
nrchannels = 2;
freq = 12000;
repetitions = 1;
% Length of the beep
beepLengthSecs = 0.01;
% rate beeps presented in beeps/sec 
rate = 5;
%time between beeps
beepPauseTime = 1/rate - beepLengthSecs - 0.0072;%arbitrary last number depending on machine and frequency
% Start immediately (0 = immediately)
startCue = 0;
% Should we wait for the device to really start (1 = yes)
waitForDeviceStart = 1;

% Open Psych-Audio port, with the follow arguements
% (1) [] = default sound device
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo putput
pahandle = PsychPortAudio('Open', [], 1, 2, freq, nrchannels);

% Set the volume (scaled by last argument froM 0 to 1)
PsychPortAudio('Volume', pahandle, 0.75);

% Make a beep which we will play back to the user
myBeep = MakeBeep(500, beepLengthSecs, freq);

% Fill the audio playback buffer with the audio data, doubled for stereo
% presentation
PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Triggering
%settings

portNum = 0; %Choose device port to use 0=A, 1=B
triggerValueBlock = 5;
triggerValueBeep = 1; %0-255, or use e.g. bin2dec('00010100') to more easily control individual lines.  Rightmost digit would be rightmost wire on the port.
triggerValueRest = 10;

%find device
%%%daqInd=DaqDeviceIndex;  %Scans USB-HID device list, returns index number for the USB DAQ.
%%%HIDDevices=PsychHID('Devices');    %not generally used, but good for debugging if device is not found by DaqDeviceIndex.m
%initialize device
%%DaqDConfigPort(daqInd(1),0,0); % set digital port A's mode to output
%%%DaqDConfigPort(daqInd(1),1,0); % same for B
%%%DaqDOut(daqInd(1),0,0);	%set A and B to zero
%%%DaqDOut(daqInd(1),1,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%InterTrial Beep Interval (IBI) setting
prompt = ('Which song is used? (Por/Ride=1; Moonlight=3; Carol=4)');
WM = input(prompt);
if WM == 1
IBI = [6, 5, 6, 4, 5, 6, 3, 4, 3, 4, 3, 5, 3, 4, 5, 3, 5, 4, 5, 3, 4, 6, 4, 5, 4];
end
if WM == 3
IBI = [7, 6, 7, 5, 4, 7, 4, 3, 4, 5, 3, 5, 3, 4, 5, 4, 6, 5, 6, 4, 5, 7, 5, 6, 5];
end
if WM == 4
IBI = [3, 4, 5, 5, 3, 4, 5, 7, 5, 7, 6, 4, 6, 5, 5, 7, 5, 6, 4, 3, 5, 7, 6, 5, 3];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
numblocks = 25;
presentationTime = 1;
iv = 1;
WaitSecs(1);


for i = 1:numblocks
    resttime = IBI(1,iv);
    fprintf('%d\n', resttime);
    %DaqDOut(daqInd(1),portNum,triggerValueBlock);
	%DaqDOut(daqInd(1),portNum,0);
	start = GetSecs();
    now = GetSecs();
    disp(now)
    currentInterval = 0;
    while now < start + presentationTime
        fid = fopen('beeps.txt','wt');
        fprintf(fid,'1');
        %DaqDOut(daqInd(1),portNum,triggerValueBeep);
		%DaqDOut(daqInd(1),portNum,0);
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
        WaitSecs(beepLengthSecs);
        PsychPortAudio('Stop', pahandle);
        WaitSecs(beepPauseTime);
        fprintf(fid,'0');
        now = GetSecs();
        fclose(fid);
	end
	WaitSecs(2);
	%DaqDOut(daqInd(1),portNum,triggerValueRest);
	%DaqDOut(daqInd(1),portNum,0);
	WaitSecs(resttime-2);
    iv = iv+1;
end
    fprintf('Number of blocks = %d\n', i);
