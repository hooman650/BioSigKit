# BioSigKit
BioSigKit is a set of useful signal processing tools in Matlab that are either developed by me personally or others in different fields of biosignal processing. BioSigKit is a wrapper with a simple visual interface that gathers this tools under a simple easy to use platform. BioSigKit's goal is to create an open source platform and umbrella for the implementation and analysis of useful signal processing algorithms. All of it's subroutines are implemented in pure MatLab script for the educational purposes even the most popular algorithms such as (Pan-Tompkins).  

The ultimate goal of BioSigKit is not to be only used for ECG processing, it aims to be helpful in analysis of several different physiological signals such as EMG, ACC and EDR as well. For instance the last subroutine which is a general peak detector can already be used in many different signals even with low frequencies (Please see [the paper by Scholkmann)](http://www.mdpi.com/1999-4893/5/4/588). While its current version still does not offer more algorithms for processing of the other physiological signals, at least several more subroutines are in pipeline that will be able to do so in the near future. For instance,extracting Fetal ECG from maternal ECG using projection techniques, computing ECG derived respiration (EDR) or MUAP detection in EMG signals ([EMG toolbox (offered by the same author)](https://www.mathworks.com/matlabcentral/fileexchange/59344-toolbox-for-unsupervised-classification-of-muaps-and-action-potentials-in-emg)). 

# QRS Detection Algorithms offered by BioSigKit
BioSigKit provides a set of subroutines implementing the six following QRS detection algorithms:

Pan and Tompkins [[J. Pan, 1985](http://www.robots.ox.ac.uk/~gari/teaching/cdt/A3/readings/ECG/Pan+Tompkins.pdf);[H. Sedghamiz, 2014](https://www.researchgate.net/publication/313673153_Matlab_Implementation_of_Pan_Tompkins_ECG_QRS_detector)]: This algorithm is probably one of the most widely used algorithms for QRS detection in the research community. It combines a set of preprocessing methods in order to enhance the detection rate and reduce the false detection of T-waves in the ECG recordings (subroutine name : ```BioSigKit.PanTompkins()```).

Nonlinear Phase Space Reconstruction [[J. Lee, 2002](https://link.springer.com/article/10.1114/1.1523030)]: This method employs the area under the non-linear phase space reconstruction of the ECG recording in order to identify the QRS complexes (subroutine name : ```BioSigKit.PhaseSpaceAlg()```).

State-Machine [[H. Sedghamiz, 2013](https://www.researchgate.net/publication/316960619_Matlab_Implementation_of_a_simple_real_time_Q_R_S_and_T_wave_detector)]: This algorithm employs state-machine in order to identify R, S and T waves in an ECG recording (subroutine name : ```BioSigKit.StateMachine()```).

Filter Bank [[V. Afonso, 1999](http://ieeexplore.ieee.org/document/740882/)]: The filter bank method combines several band-pass filters in order to better delineate the QRS complexes. This algorithm is very similar to wavelet based QRS detectors (subroutine name : ```BioSigKit.FilterBankQRS()```).

QRS Multilevel Teager Energy Operator (MTEO) [[H. Sedghamiz, 2016](http://ieeexplore.ieee.org/document/7391510/)]: This algorithm employs Multilevel Teager Energy Operator (MTEO) in order to locate the QRS complexes. MTEO has been successfully used in Electromyography signals for action potential detection [[H. Sedghamiz, 2016](http://ieeexplore.ieee.org/document/7391510/)] since it is computationally much more efficient than wavelet transform (subroutine name : ```BioSigKit.MTEO_qrstAlg()```).

Automatic Multiscale-based Peak Detection [[Scholkmann2012](http://www.mdpi.com/1999-4893/5/4/588)]: This method is a more general peak detection. However, according to the study by Scholkmann et al. [[Scholkmann, 2012](http://www.mdpi.com/1999-4893/5/4/588)], it showed a high performance for the beat detection as well. Therefore, it is implemented as one of the subroutines in BioSigKit (subroutine name : ```BioSigKit.AMPD_PAlg()```).

# Getting Started and Installation
To install BioSigKit simply:
1. Download the repository.

2. Unzip the downloaded package and simply run "RunBioSigKit.m".

3. See the instrcutions bellow for further details: 

BioSigKit might be used either from the command line or its Graphical User Interface (GUI). 
## Command Line : 

To use the command line simply call the constructor as follows:
```analysis = RunBioSigKit(InputSig, SampleFreq, 0);```

To access subroutines simply use the point operator as :
```analysis.PanTompkins();```

The results are stored in the result struct, you can access it as :
```analysis.Results;```

To see the list of all the subroutines and children accessible simply call ```analysis``` in Matlab command-line.

## GUI : 
To instantiate the GUI, simply run the ```RunBioSigKit()```.

## Examples :
See the ```Demo.m``` for a few examples on how to use BioKitSig.

## GUI Functionalities
![Graphical User Interface of BioSigKit. The algorithm pop-up menu provides an easy way for the selection of the QRS detection algorithm. The statistics panel automatically computes mean, maximum and minimum detected intervals.](paper/fig1.png)

# Acknowledgements:
BioSigKit currently uses the following libraries and I would like to appreciate their efforts:
### 1) [GUI Layout Toolbox](https://www.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox).
### 2) [Rupert Ortner, 2016. Matlab implementation of Filter-Bank](https://searchcode.com/codesearch/view/13912596/).
### 3) [Distinguishable Colors](https://www.mathworks.com/matlabcentral/fileexchange/29702-generate-maximally-perceptually-distinct-colors).
### 4) [Alexandros Leontitsis. Phase-Space Computation]( http://www.geocities.com/CapeCanaveral/Lab/1421).

# Inclusion of New Methods
Have you published an algorithm that you would like it to be featured in BioSigKit or you like to suggest the inclusion of new algorithm you found helpful? Please open a request in the issue section, explain what the algorithm is, add the links to the supporting paper or the source code and I would try to add it to BioSigKit subroutines as soon as I can. Please note that I am maintaining BioSigKit in my free-time, so the updates might take a few days. If you would like to personally contribute your algorithm or work to the subroutines please use the following codemap to get an idea about the structure of BioSigKit and how you could contribute directly;

## Codemap
```
|--- RunBioSigKit.m                     <-------- Main module, GUI and Commandline
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
|--- layout                             <-------- Dependencies for GUI (third party)
|--- SampleSignals                      <-------- Test Cases
    |--- ECG1                           <-------- test case 1 for evaluation of the algorithms
    |--- ECG5                           <-------- test case 2 for evaluation of the algorithms 
|--- paper                              <-------- Details the toolbox 

```
