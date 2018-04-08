---
title: 'BioSigKit: A Matlab Toolbox and Interface for Analysis of BioSignals'
tags:
  - Biosignal
  - Electrocardiogram
  - Signal processing
  - Pan Tompkins
  - Beat detection
  - Matlab
authors:
 - name: Hooman Sedghamiz
   affiliation: "1"
affiliations:
 - name: Linkoping University, Sweden
   index: 1
date: 9 April 2018
bibliography: paper.bib
---

# Summary
BioSigKit is a set of Matlab (The MathWorks Inc., Natick, USA) tools for analysis and visualization of bio-signals, specifically Electrocardiogram (ECG) recordings. Matlab is a widely used programming language among researchers thanks to its simple and flexible syntax. Biomedical signal processing is one of the main areas that has been benefiting from Matlab for research and rapid prototyping. One of the most widely used and studied bio-signals is ECG. ECG is a signal reflecting the rotation of the electrical heart axis in respect to the electrode position in space. Therefore, ECG provides an invaluable insight into the cardiovascular and heart functionality. The beats in an ECG recording are identified with the help of an automated QRS detection algorithm and their morphology is studied in order to better understand the underlying cardiovascular function. Many of the most popular QRS detection algorithms [@Lee2002;@Afonso1999;@Pan1985;@Scholkmann2012] are only implemented in C or other similar higher level programming languages. BioSigKit provides a set of Matlab methods that implement 6 popular ECG QRS detectors. The object oriented implementation of BioSigKit makes it easy to update and add new algorithms to its collection. The ultimate goal of BioSigKit is to provide an easy to use interactive Matlab software that provides easy access to many standard bio-signal processing algorithms. BioSigKit currenlty provides six QRS detection algorithms detailed in the next section.

# BioSigKit Algorithms and Use
BioSigKit provides a set of subroutines implementing the six following QRS detection algorithms:

## 1. Pan and Tompkins [@Pan1985;@sedghamiz2014complete]: 
This algorithm is probably one of the most widely used algorithms for QRS detection in the research community. It combines a set of preprocessing methods in order to enhance the detection rate and reduce the false detection of T-waves in the ECG recordings (subroutine name : ```BioSigKit.PanTompkins()```).

## 2. Nonlinear Phase Space Reconstruction [@Lee2002]: 
This method employs the area under the non-linear phase space reconstruction of the ECG recording in order to identify the QRS complexes (subroutine name : ```BioSigKit.PhaseSpaceAlg()```). 

## 3. State-Machine [@sedghamiz2013online]: 
This algorithm employs state-machine in order to identify R, S and T waves in an ECG recording (subroutine name : ```BioSigKit.StateMachine()```).

## 4. Filter Bank [@Afonso1999]: 
The filter bank method combines several band-pass filters in order to better delineate the QRS complexes. This algorithm is very similar to wavelet based QRS detectors (subroutine name : ```BioSigKit.FilterBankQRS()```).

## 5. QRS Multilevel Teager Energy Operator (MTEO) [@7391510]: 
This algorithm employs Multilevel Teager Energy Operator (MTEO) in order to locate the QRS complexes. MTEO has been successfully used in Electromyography signals for action potential detection [@7391510] since it is computationally much more efficient than wavelet transform (subroutine name : ```BioSigKit.MTEO_qrstAlg()```). 

## 6. Automatic Multiscale-based Peak Detection [@Scholkmann2012]: 
This method is a more general peak detection. However, according to the study by Scholkmann et al. [@Scholkmann2012], it showed a high performance for the beat detection as well. Therefore, it is implemented as one of the subroutines in BioSigKit (subroutine name : ```BioSigKit.AMPD_PAlg()```).

BioSigKit might be used either directly  from the command-line by calling its constructor (e.g. ```BioSigKit = BioSigKit(InputSignal,SamplingFrequency)```) or by initiating its GUI.

![Graphical User Interface of BioSigKit. The algorithm pop-up menu provides an easy way for the selection of the QRS detection algorithm. The statistics panel automatically computes mean, maximum and minimum detected intervals.](fig1.png)


# References
