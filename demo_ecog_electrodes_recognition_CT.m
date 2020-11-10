% Load pre-trained model
load trainedModelGSVM22patients.mat

% Uncomment only one command line at a time to choose between Patient A and
% Patient B datasets. 
% load patientAdata.mat
% load patientBdata.mat

% Call to the Matlab function that implements the proposed automated method
% for ECoG electrodes recognition in CT volumes
ClassifiedObjects = ElectrodeRecognitionCT(V,2500,trainedModel22patients)

% Classification performance analysis
PredictedClass = ClassifiedObjects.PredictedClass;
Performances = ClassifierPerformances(TrueClass,PredictedClass);