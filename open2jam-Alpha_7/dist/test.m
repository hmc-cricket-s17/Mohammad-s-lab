%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting for the sound beep %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
PsychPortAudio('Volume', pahandle, 1);

% Make a beep which we will play back to the user
myBeep = MakeBeep(500, beepLengthSecs, freq);

% Fill the audio playback buffer with the audio data, doubled for stereo
% presentation
PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);

beep = '0';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting for the trigger to EEG %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


miss = '0';
% 
% daqInd=DaqDeviceIndex;  %Scans USB-HID device list, returns index number for the USB DAQ.
% HIDDevices=PsychHID('Devices');    %not generally used, but good for debugging if device is not found by DaqDeviceIndex.m
% %initialize device
% DaqDConfigPort(daqInd(1),0,0); % set digital port A's mode to output
% DaqDConfigPort(daqInd(1),1,0); % same for B
% DaqDOut(daqInd(1),0,0);	%set A and B to zero
% DaqDOut(daqInd(1),1,0);

triggerValue = 7;
portNum = 0;

a = 0;
flag = false;
beep_flag = false;
tic
while  true
    f_miss = fopen('communicate.txt');
    f_beep = fopen('beeps.txt');
    miss = fgets(f_miss);
    beep = fgets(f_beep);
    fclose(f_miss);
    fclose(f_beep);
    
        
    
    %% Do miss triggering
    if miss == '1' && flag == false
%         DaqDOut(daqInd(1),portNum,triggerValue);
%         DaqDOut(daqInd(1),portNum,0);
        a = a + 1;
		% disp(a)
		flag = true;
	elseif miss == '1' && flag == true
		
	else
		flag = false;
    end
    
    %% Do beep
    if beep == '1' && beep_flag == false        
        %DaqDOut(daqInd(1),portNum,triggerValueBeep);
		%DaqDOut(daqInd(1),portNum,0);
        datestr(now,'dd-mm-yyyy HH:MM:SS FFF')
        PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
        WaitSecs(beepLengthSecs);
        PsychPortAudio('Stop', pahandle);
        beep_flag = true;
    elseif beep == '0' && beep_flag == true
        beep_flag = false;
    end
    
    
    
end
toc 

