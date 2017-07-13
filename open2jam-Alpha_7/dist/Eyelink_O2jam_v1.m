% Most basic elements to run eyelink during series of trials.
%
% More sophisticated uses can be found in Eyelink Demos
%   (.../Psychtoolbox/PsychHardware/Eyelinktoolbox/EyelinkDemos/)
% 
% If running on new computer, need to install Eyelink API.
%   can be downloaded from SR Research support forum
%       https://www.sr-support.com/forums/
%   Look in section: Downloads - Eyelink Display Software
%       Posts for various platforms titled: Eyelink Developers Kit for ...
%   Also, in Downloads - Data Analysis
%       edf2asc utility, which converts the proprietary .edf
%       data file into a text file.

clear all

!java -jar open2jam.jar &

%%  SETTINGS
screenNum = max(Screen('Screens')); %runs experiment on external monitor if available.  If not, falls back to main screen.

trialDuration = 180; %in seconds.
numTrials = 1;

EyelinkFilename = 'demo01'; %filename for data file stored on Eyelink computer.  Limit 6 characters b/c Eyelink runs on DOS.
LocalFilename = 'demoEyeData01.edf'; %filename for local copy of data, gets created at end of experiment.


%% INITIALIZE
%Open experiment window
[win0.ptr, win0.rect] = Screen('OpenWindow', screenNum, [0 0 0]);


% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.
if EyelinkInit()~=1;
    sca
    return;
end

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
el=EyelinkInitDefaults(win0.ptr);

% make sure that we get gaze data from the Eyelink
Eyelink('command', 'link_sample_data = RIGHT,LEFT,GAZE,AREA');  %set to receive both eyes, gaze position & pupil size(area)
% open file on eyelink computer to store data.
Eyelink('openfile',[EyelinkFilename,'.edf']);
% Calibrate the eye tracker using the standard calibration routines
EyelinkDoTrackerSetup(el);
%disp('setup over, driftcorrecting')
% do a final check of calibration using driftcorrection
EyelinkDoDriftCorrection(el);
FlushEvents('keydown')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setting for the sound beep %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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


communicate = '0';
% 
% daqInd=DaqDeviceIndex;  %Scans USB-HID device list, returns index number for the USB DAQ.
% HIDDevices=PsychHID('Devices');    %not generally used, but good for debugging if device is not found by DaqDeviceIndex.m
% %initialize device
% DaqDConfigPort(daqInd(1),0,0); % set digital port A's mode to output
% DaqDConfigPort(daqInd(1),1,0); % same for B
% DaqDOut(daqInd(1),0,0);	%set A and B to zero
% DaqDOut(daqInd(1),1,0);
game_end_trigger = 20;
music_start_trigger = 19;
game_start_trigger = 18;
right_miss_trigger = 8;
left_miss_trigger = 7;
beep_trigger = 17;
portNum = 0;

left_miss_num = '2';
right_miss_num = '3';
  

%% RUN TRIALS
%% You know, I need to make this more modular

for trialNum = 1:numTrials
    %Eyelink drift correct
    EyelinkDoDriftCorrection(el);
    
    %Start writing data
    Eyelink('StartRecording');
    Screen('Close',win0.ptr);
    
	
    %Normally you'd show your stimulus here, but as placeholder we'll just
    %wait for trial duration.
	
	
	a = 0;
	right_flag = false;
    left_flag = false;
	beep_flag = false;
    
	tic
	while  toc < trialDuration 
		f_miss = fopen('communicate.txt');
		f_beep = fopen('beeps.txt');
		communicate = fgets(f_miss);
		beep = fgets(f_beep);
		fclose(f_miss);
		fclose(f_beep);
        %% I know it's a bad practice, but I am using 
        % miss for trigger of game start
		% Do miss triggering
        if communicate == '2'
    %         DaqDOut(daqInd(1),portNum,game_start_trigger);
    %         DaqDOut(daqInd(1),portNum,0);
            Eyelink('Message', 'Start Game');
        elseif communicate == '3'
    %         DaqDOut(daqInd(1),portNum,music_start_trigger);
    %         DaqDOut(daqInd(1),portNum,0);
            Eyelink('Message', 'Start Music');
        elseif communicate = '4'
    %         DaqDOut(daqInd(1),portNum,game_end_trigger);
    %         DaqDOut(daqInd(1),portNum,0);
            Eyelink('Message', 'End of the Game');    
        elseif communicate == left_miss_num && left_flag == false
	%         DaqDOut(daqInd(1),portNum,left_miss_trigger);
	%         DaqDOut(daqInd(1),portNum,0);
			left_flag = true;
        elseif communicate == right_miss_num && right_flag == false
    %         DaqDOut(daqInd(1),portNum,right_miss_trigger);
	%         DaqDOut(daqInd(1),portNum,0);
            right_flag = true;
        elseif communicate =='0' 
            left_flag = false;
            right_flag = false;
		end

		%% Do beep
        if beep == '0' && beep_flag == true
            beep_flag = false;
        elseif beep_flag == false
			%DaqDOut(daqInd(1),portNum,beep_trigger);
			%DaqDOut(daqInd(1),portNum,0);
			PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
			WaitSecs(beepLengthSecs);
			PsychPortAudio('Stop', pahandle);
			beep_flag = true;
            Eyelink('Message', strcat('Flash at',beep));
		end
	end

    
    %Stop recording at end of trial
    Eyelink('StopRecording')
end

%% CLEAN UP
Screen('CloseAll');

%close edf file on eyelink computer
Eyelink('CloseFile');
    
%get edf file from eyelink computer, assign new name as desired.
status=Eyelink('ReceiveFile', EyelinkFilename, ['LocallyNamed_' EyelinkFilename '.edf']);
disp(status)

Eyelink('Shutdown')
