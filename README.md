## Description
This repository includes the code I have done in *2018* for my [Master's Degree Thesis](https://cpvlordelo.github.io/docs/DissertacaoMestrado_CarlosLordelo.pdf). The project consists of a method to automatically detect and remove musical segments from TV programme signals. The main idea behind the method is to use a pre-existant music recording, easily obtainable from officially published CDs related to the audiovisual piece, as a reference for the undesired signal.

However, it is important to note that even though we have a reference for the music signal we want to extract from the mixture, we do not know the exact segments that appear in the mixture. Moreover, such segments might appear with distortions and in different positions througout the TV programme signal. So, the algorithm also includes the stage of segmentation, detection and synchronisation before performing the separation per se.

In summary, this repository has the results of my research regarding automatic musictrack removal. Even though the full algorithm works really well with synthesised signals, where the mixture is created by segmenting, filtering and mixing a reference signal with another audio signal, when using real-world TV programme signals, the synchronisation stage works really well, but, in my tests, the separation didn't obtain good results. I believe the reason is because the mixing procedure usually applies non-linear distortions in the signals, such as compression, that are not taken into account by the algorithm. Also, the reference signal that is used might not be the exact same signal that was used in the TV programme signal, so, in this case, the separation stage also fails.   

A detailed explanation for the key components of the segmentation, detection, synchronisation and separation system can be found in my [master's degree thesis](https://cpvlordelo.github.io/docs/DissertacaoMestrado_CarlosLordelo.pdf), where I also provide simulations with artificial and real TV programme signals. If you use this code, please, cite the following:

* C. Lordelo, __"Automatic Removal of Music Tracks from TV Programmes"__, in _Master's Degree Thesis_, Federal University of Rio de Janeiro (UFRJ), Brazil, Aug 2018

## Detection and Synchronisation
The first step in the method is to automatically detect and synchronise segments of the reference musictrack that are spread in the long audio signal of the programme, even if they appear with time-variable gain, or after having suffered linear distortions, such as being processed by equalization filters, or non-linear distortions, such as dynamic range compression. In order to do this, the project uses a quick-search algorithm based on robust audio fingerprinting technique that applies hash-token data types to ensure that the search and synchronisation of segments have low complexity. Most part of the code for this part I adapted from Dan Ellis' work.

* D. Ellis, __"Robust Landmark-Based Audio Fingerprinting"__, _web resource_, available in [https://www.ee.columbia.edu/~dpwe/resources/matlab/fingerprint/](https://www.ee.columbia.edu/~dpwe/resources/matlab/fingerprint/):

## Equalisation Filter and Amplitude Estimation
After the detection and syncronisation have been performed, the algorithm uses a Wiener filltering technique to estimate potential equalization filter coefficients that could have been used during the mixing procedure and applies a template matching algorithm to estimate time-variable gains to properly scale the musical segments to the correct amplitude they appear in the mixture. For instance, it is really common to have musictrack signals appear with fade-ins and fade-outs in a TV programme signal. In the end, the separation is performed by subtraction in time domain.

## Main Usage
The algorithm is fully implemented in __MATLAB__, so this software is necessary in order to properly run the scripts of this repo. The main script is the file `main_AutoMusicTrackRemoval.m` for stereo signals or `main_AutoMusicTrackRemoval_mono.m` for mono. They will read the parameters of the configuration file `SetParametersSoundtrackRemoval.m`. So, please, set the parameters for processing using this file first. 

The main scripts are divided into __4__ sections:
  
  * __Estimating the Delay__: the algorithm searches for small segments of the reference musictrack file that appear in the mixture file. It uses the mixture file as an anchor signal and returns the sample bin where there were the most landmark matches between the long anchor signal (mixture) and the queried signals (segments of reference musictrack). Such landmarks are computed using a robust spectrogram-based audio fingerprinting based in:
    
    * A. Wang, __"An Industrial-Strength Audio Search Algorithm"__ in _International Society for Music Information Retrieval Conference (ISMIR)_, Baltimore, USA, Oct 2003

 * __Estimating the Equalisation Filter__: after estimating the delay, the algorithm uses a Wiener filtering estimation technique to estimate an equalisation filter to be used in the segments of the musictrack before proceeding to the next step. This stage is necessary because in some cases the reference signal might have gone through filtering stage before being added to the TV soundtrack.
 
*  __Estimating the Amplitude__: before doing the separation it also estimates a time varying gain that could be used in the musictrack segment to create the mixture. 

* __Separating__: the separation is done by applying the estimated equalisation filter and amplitude gains and subtracting in the time domain.

Also, I included other directories in this repo where you can find the exact code I used for the simulations I performed in my thesis.