close all;
clear all; 

%% Getting some important parameters for music analysis
SetParametersDelayExp1;
%load '../Audiofiles/mixture1.mat'
 
%% Reading Audio File & normalizing mean to zero and RMS value to 1

[dialogue, Fs1] = audioread(DATA_FILE);
dialogue = mean(dialogue, 2);
[musicTrack1, Fs2] = audioread(MUSICTRACK_FILE1); 
musicTrack1 = mean(musicTrack1, 2);

if Fs2 > Fs1
    [p,q] = rat(Fs2/Fs1,0.000001);
    dialogue = resample(dialogue,p,q);
    Fs = Fs2;
elseif Fs2 < Fs1
    [p,q] = rat(Fs1/Fs2,0.000001);
    musicTrack1 = resample(musicTrack1,p,q);
    Fs = Fs1;
else
    Fs = Fs1;
end

Fs1 = Fs;
[musicTrack2, Fs2] = audioread(MUSICTRACK_FILE2); 
musicTrack2 = mean(musicTrack2, 2);

if Fs2 > Fs1
    [p,q] = rat(Fs2/Fs1,0.000001);
    dialogue = resample(dialogue,p,q);
    Fs = Fs2;
elseif Fs2 < Fs1
    [p,q] = rat(Fs1/Fs2,0.000001);
    musicTrack1 = resample(musicTrack1,p,q);
    Fs = Fs1;
else
    Fs = Fs1;
end

Fs1 = Fs;
[musicTrack3, Fs2] = audioread(MUSICTRACK_FILE3); 
musicTrack3 = mean(musicTrack3, 2);

if Fs2 > Fs1
    [p,q] = rat(Fs2/Fs1,0.000001);
    dialogue = resample(dialogue,p,q);
    Fs = Fs2;
elseif Fs2 < Fs1
    [p,q] = rat(Fs1/Fs2,0.000001);
    musicTrack1 = resample(musicTrack1,p,q);
    Fs = Fs1;
else
    Fs = Fs1;
end

musicTrack = {};
musicTrack{1} = musicTrack1;
musicTrack{2} = musicTrack2;
musicTrack{3} = musicTrack3;


excerpt1 = musicTrack1(initialSample:finalSample);
excerpt2 = musicTrack2(initialSample:finalSample);
excerpt3 = musicTrack3(initialSample:finalSample);
excerpt = {};
excerpt{1} = excerpt1;
excerpt{2} = excerpt2;
excerpt{3} = excerpt3;

mix = {};
[mixture, m] = CreateMixture (dialogue, 0.4*excerpt1, delay1);
mix{1} = m;
[mixture, m] = CreateMixture (mixture,  0.4*excerpt2, delay2);
mix{2} = m;
[mixture, m] = CreateMixture (mixture,  0.4*excerpt3, delay3);
mix{3} = m;

delay = {};
delay{1} = delay1;
delay{2} = delay2;
delay{3} = delay3;

originalMixture  = mixture;

%% Saving the mixture landmarks in a HASH-Token Matrix used for delay estimation 
clear_hashtable;
H = landmark2hash(find_landmarks(originalMixture,Fs));
save_hashes(H);

parameters = {};
parameters.minLandmarkMatch = 200;
parameters.Fs = Fs;

for i = 2:3,
    musicTrackBuffer = excerpt{i};
    [nLandmarkMatch, D] = Look4Matches2(originalMixture, musicTrackBuffer, parameters);

    [nLandmarkMatch,idx] = sort(nLandmarkMatch, 'descend');
    nLandmarkMatch  % to check number of lmark matches debug
    for j = 1:length(nLandmarkMatch)
        colBuffer = D(idx(j),1);
        est_initialSample = D(idx(j),2);
        est_delay = D(idx(j),3);
        est_L_mix = D(idx(j),4);
        est_finalSample = est_initialSample + est_L_mix - 1;
        est_finalMixSample = est_delay + est_L_mix - 1;
        est_mix = mixture(est_delay:est_finalMixSample);
        est_excerpt = musicTrackBuffer(est_initialSample:est_finalSample,colBuffer);
        %% Estimating the Gain Curve used in the Mixture Process
        %parameters = {};
        %parameters.gainWindow = gainWindow;
        %parameters.gainHop = gainHop;
    
        %estGainCurve = EstimateGain(mix, excerpt, parameters);
        est_GainCurve = 0.4;%ones(size(est_excerpt));
        mixture(est_delay:1:est_finalMixSample) = est_mix - est_excerpt.*est_GainCurve;
    end

    %% BSS EVAL
    s1 = excerpt{i};
    s2 = dialogue(delay{i}:delay{i} + length(excerpt{i}) - 1);

    s2_e = mixture(delay{i}:delay{i} + length(excerpt{i}) - 1);
    s1_e = originalMixture(delay{i}:delay{i} + length(excerpt{i}) - 1) - s2_e;
    [SDR,SIR,SAR,perm]=bss_eval_sources([s1_e' ; s2_e'],[s1' ; s2']);
    
    file = ['mixture' , num2str(i), '.mat'];  
    save (file);
end
    