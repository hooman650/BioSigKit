[![DOI](http://joss.theoj.org/papers/10.21105/joss.00671/status.svg)](https://doi.org/10.21105/joss.00671)
[![DOI](https://zenodo.org/badge/128659224.svg)](https://zenodo.org/badge/latestdoi/128659224)

# BioSigKit
BioSigKit is a set of useful signal processing tools in Matlab that are either developed by me personally or others in different fields of biosignal processing. BioSigKit is a wrapper with a simple visual interface that gathers this tools under a simple easy to use platform. BioSigKit's goal is to create an open source platform and umbrella for the implementation and analysis of useful signal processing algorithms. All of it's subroutines are implemented in pure MatLab script for the educational purposes even the most popular algorithms such as (Pan-Tompkins).  

The ultimate goal of BioSigKit is not to be only used for ECG processing, it aims to be helpful in analysis of several different physiological signals such as EMG, ACC and EDR as well. For instance the last subroutine which is a general peak detector can already be used in many different signals even with low frequencies (Please see [the paper by Scholkmann)](http://www.mdpi.com/1999-4893/5/4/588). BioSigKit offers other subroutines for ECG-derived respiration computation, real time multi-channel and single channel Foetal ECG extraction based on non-linear filtering and neural PCA. BioSigKit also offers Psuedo-correlation template matching which has proven to be more accurate for locating MUAPs in EMG signals ([EMG toolbox (offered by the same author)](https://www.mathworks.com/matlabcentral/fileexchange/59344-toolbox-for-unsupervised-classification-of-muaps-and-action-potentials-in-emg)). Futhermore, several more subroutines enable the user to estimate the posture of the subject from 3 channel ACC recordings, as well as ACC-derived respiration estimation. Please see the cheatSheet.pdf for the list of all methods provided by BioSigKit.

# How to Cite
Sedghamiz, (2018). BioSigKit: A Matlab Toolbox and Interface for Analysis of BioSignals. Journal of Open Source Software, 3(30), 671, https://doi.org/10.21105/joss.00671

#### If you like the tools I develop, please get me a coffee :) 
[![paypal](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=9FAVSPGXTBBQU&currency_code=USD)

# QRS Detection Algorithms offered by BioSigKit
BioSigKit provides a set of subroutines implementing the six following QRS detection algorithms:

Pan and Tompkins [[J. Pan, 1985](http://www.robots.ox.ac.uk/~gari/teaching/cdt/A3/readings/ECG/Pan+Tompkins.pdf);[H. Sedghamiz, 2014](https://www.researchgate.net/publication/313673153_Matlab_Implementation_of_Pan_Tompkins_ECG_QRS_detector)]: This algorithm is probably one of the most widely used algorithms for QRS detection in the research community. It combines a set of preprocessing methods in order to enhance the detection rate and reduce the false detection of T-waves in the ECG recordings (subroutine name : ```BioSigKit.PanTompkins()```).

Nonlinear Phase Space Reconstruction [[J. Lee, 2002](https://link.springer.com/article/10.1114/1.1523030)]: This method employs the area under the non-linear phase space reconstruction of the ECG recording in order to identify the QRS complexes (subroutine name : ```BioSigKit.PhaseSpaceAlg()```).

State-Machine [[H. Sedghamiz, 2013](https://www.researchgate.net/publication/316960619_Matlab_Implementation_of_a_simple_real_time_Q_R_S_and_T_wave_detector)]: This algorithm employs state-machine in order to identify R, S and T waves in an ECG recording (subroutine name : ```BioSigKit.StateMachine()```).

Filter Bank [[V. Afonso, 1999](http://ieeexplore.ieee.org/document/740882/)]: The filter bank method combines several band-pass filters in order to better delineate the QRS complexes. This algorithm is very similar to wavelet based QRS detectors (subroutine name : ```BioSigKit.FilterBankQRS()```).

QRS Multilevel Teager Energy Operator (MTEO) [[H. Sedghamiz, 2016](http://ieeexplore.ieee.org/document/7391510/)]: This algorithm employs Multilevel Teager Energy Operator (MTEO) in order to locate the QRS complexes. MTEO has been successfully used in Electromyography signals for action potential detection [[H. Sedghamiz, 2016](http://ieeexplore.ieee.org/document/7391510/)] since it is computationally much more efficient than wavelet transform (subroutine name : ```BioSigKit.MTEO_qrstAlg()```).

Automatic Multiscale-based Peak Detection [[Scholkmann2012](http://www.mdpi.com/1999-4893/5/4/588)]: This method is a more general peak detection. However, according to the study by Scholkmann et al. [[Scholkmann, 2012](http://www.mdpi.com/1999-4893/5/4/588)], it showed a high performance for the beat detection as well. Therefore, it is implemented as one of the subroutines in BioSigKit (subroutine name : ```BioSigKit.AMPD_PAlg()```).

# Subroutines offered for analysis of ACC, EMG, EEG and Foetal-ECG
Activity detection with hilbert transform in EMG and audio signals (```obj.Env_hilbert()```). For more details regarding this algorithm see [[Alarm detection](https://blogs.mathworks.com/pick/2014/05/23/automatic-activity-detection-using-hilbert-transform/)].

Mobility and complexity computation with Hjorth parameters in EEG signals (```obj.ComputeHjorthP```). For more details regarding this subroutine refer to [[Hjorth Parameters](https://en.wikipedia.org/wiki/Hjorth_parameters)].

Posture detection and adaptive filtering in 3 Channel Accelerometer signals  (```obj.ACC_Act```). This subroutine is able to compute the Energy Expenditure (EE) and Signal Magnitude Area (SMA) from 3 channel ACC recordings. Based on EE and SMA, the subroutine is able to estimate the activity level of the subject (e.g. steady, active, highly active). Accelerometers are used in many studies and being able to estimate the state of the subject by analyzing the ACC signals is helpfull in many tasks.

Accurate template matching for locating MUAPs in EMG recordings based on Psuedo-Correlation (```obj.TemplateMatch```). Psuedocorrelation has shown to be more accurate than Pearson correlation. For more details see [[H. Sedghamiz, 2016](http://ieeexplore.ieee.org/document/7391510/)].

Computation of ECG derived respiration based on real time neural PCA computation ([[Neural PCA](https://www.researchgate.net/publication/4116857_Real-time_PCA_principal_component_analysis_implementation_on_DSP)]). This subroutine first applies pan-tompkins algorithm to locate the R peaks and then reconstructs the EDR signal by computing the PCs of the QRS complexes in real-time (```obj.EDR_comp```). 

Foetal-ECG extraction from multichannel and single channel maternal ecg recordings. BioSigKit implements a non-linear phase space filter that is able to extract foetal ecg recordings. This is based on delayed phase space reconstruction of the signal. For more details see [[Schreiber, 1996](https://www.ncbi.nlm.nih.gov/pubmed/12780239)]. Futhermore, it is possible to extract the foetal ecg in real-time with the neural PCA offered in BioSigKit. See demo.m file for more details (```obj.nonlinear_phase_filt```).

ECG artifact removal with Recursive Least Squares filter (RLS). BioSigKit also offers a subroutine to remove artefacts from ECG recordings by using a 3 channel Accelerometer recording with RLS filter (```obj.adaptive_filter```). BioSigKit also implements Adaptive Line Enhancer and its leaky version. For more details regarding motion artefact removal in ECG with ACC see [[Shing-Hong Liu, 2009](http://www.jmbe.org.tw/files/404/public/404-2265-1-PB.pdf)]

# Getting Started and Installation
To install BioSigKit simply:

1. Download the repository.

2. Unzip the downloaded package and simply run "RunBioSigKit.m".

3. See the instructions bellow for further details: 

For help, type ```help BioSigKit```.

BioSigKit might be used either from the command line or its Graphical User Interface (GUI). 
## Command Line : 

To use the command line simply call the constructor as follows:
```analysis = RunBioSigKit(InputSig, SampleFreq, 0);```

To access subroutines simply use the point operator as :
```analysis.PanTompkins();```

The results are stored in the result struct, you can access it as :
```analysis.Results;```

Depending on the processing algorithm employed, the result struct would contain 'P', 'Q', 'R', 'S' and 'T' wave indices. 

To see the list of all the subroutines and children accessible simply call ```analysis``` in Matlab command-line. 

## GUI : 
To instantiate the GUI, simply run the ```RunBioSigKit()```.
Please note that GUI has only been tested on windows platforms and not Unix. 

## Examples :
See the ```Demo.m``` for a few examples on how to use BioKitSig.

## GUI Functionalities
![Graphical User Interface of BioSigKit. The algorithm pop-up menu provides an easy way for the selection of the QRS detection algorithm. The statistics panel automatically computes mean, maximum and minimum detected intervals.](paper/fig1.png)

# Test Cases
BioSigKit comes with two sample ECG recordings for testing of the algorithms offered. See SampleSignals ECG1 and ECG2 for these test cases. Please use the GUI and simply choose the algorthim that you would like to evaluate to see the results. Furthermore, see the publications for each subroutine to get a better overview what the accuracy of the proposed method might be.

# Acknowledgements:
BioSigKit currently uses the following libraries and I would like to appreciate their efforts:
#### 1) [GUI Layout Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox).
#### 2) [Rupert Ortner, 2016. Matlab implementation of Filter-Bank](https://searchcode.com/codesearch/view/13912596/).
#### 3) [Distinguishable Colors](https://www.mathworks.com/matlabcentral/fileexchange/29702-generate-maximally-perceptually-distinct-colors).
#### 4) [Alexandros Leontitsis. Phase-Space Computation]( http://www.geocities.com/CapeCanaveral/Lab/1421).

# Inclusion of New Methods and Contribution
Have you published an algorithm that you would like it to be featured in BioSigKit or you like to suggest the inclusion of new algorithm you found helpful? Please open a request in the issue section, explain what the algorithm is, add the links to the supporting paper or the source code and I would try to add it to BioSigKit subroutines as soon as I can. Please note that I am maintaining BioSigKit in my free-time, so the updates might take a few days. Please read the [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) and [Contribution guidlines](CONTRIBUTING.md) carefully before starting any contribution. If you would like to personally contribute your algorithm or work to the subroutines please use the following codemap to get an idea about the structure of BioSigKit and how you could contribute directly;

# Community Guidelines
If you are an advanced user or developer who is seeking support for the software usage please post your queries in the "issues" section as a question. Before doing so, please first read the question section of the issues as it might have been asked by another advanced user or developer. I am currently working on a wiki as well that hopefully will document these questions in a much more organized manner.

## Codemap
```
|--- RunBioSigKit.m                     <-------- Main module, GUI and Commandline
|--- CheatSheet.pdf                     <-------- Detailed helper file and subroutines of BioSigKit
|--- @BioSigKit                         <-------- Main module BioSigKit class
    |--- BioSigKit.m                    <-------- BioSigKit object, instantiates all subroutines
    |--- BioSigKitPanel.m               <-------- Creates the Visualization panel and its controls
|--- Algorithms                         <-------- List of all subroutines offered by BioSigKit
    |--- AMPD_P.m                       <-------- Multi-scale Peak detector algorithm
    |--- MTEO_qrst.m                    <-------- Multilevel Teager Energy Operator
    |--- PhaseSpaceQRS.m                <-------- Phase Space based QRS detector
    |--- SimpleRST.m                    <-------- State machine for R, S and T peak detection
    |--- distingusihable_colors.m       <-------- Computes distinguishabe colors for visualization
    |--- nqrsdetect.m                   <-------- Filter Bank ECG detector
    |--- pan_tompkin.m                  <-------- Pan Tompkins implementation
    |--- phasespace.m                   <-------- Computes phase space of a signal
    |--- ACC_Activity.m                 <-------- Posture estimation in ACC recordings
    |--- ALE_imp.m                      <-------- Delayed adaptive line enhancer
    |--- envelop_hilbert.m              <-------- Alarm detection with hilbert transform (EMG, Audio, ECG)
    |--- energyop.m                     <-------- Teager energy operator 
    |--- NLMS_ecg.m                     <-------- ECG artefact removal with ACC recordings
    |--- projective.m                   <-------- Nonlinear delayed phase-space filtering
    |--- PsC.m                          <-------- Psuedo-correlation for template matching
    |--- RLS.m                          <-------- Recursive Least Squares filter
    |--- RTpca.m                        <-------- Real-time neural PCA
    |--- VLALE_imp.m                    <-------- variable leaky ALE filter
|--- layout                             <-------- Dependencies for GUI (third party)
|--- SampleSignals                      <-------- Test Cases
    |--- ECG1                           <-------- test case 1 for evaluation of the algorithms
    |--- ECG5                           <-------- test case 2 for evaluation of the algorithms 
    |--- Foetal_ecg                     <-------- 8 channel maternal ECG recordings
    |--- ACC                            <-------- 3 channel Accelerometer recordings
|--- paper                              <-------- Details the toolbox 

```
