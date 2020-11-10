function [ClassifiedObjects,DATASET] = ElectrodeRecognitionCT(CTVol,HUth,trainedModel)
%ELECTRODERECOGNITIONCT Recognize ECoG electrodes in a CT volume
%   INPUTS:
%       - CTVol is a 3-D numeric array containing the CT volume already
%       resampled to 0.5 mm cubic voxel
%       - HUth is the threshold for metal objects identification
%       
%   OUTPUTS:
%       - ClassifiedObjects is a N-by-13 table. Each row corresponds to a
%         metal object identified in the CT volume analysis and contains
%         the predicted class and many other parameters related to the
%         object.


% THRESHOLDING ON HU FOR METAL OBJECTS IDENTIFICATION
Vm = (CTVol >= HUth);


% 6-CONNECTED VOXEL CLUSTERS LABELLING
L = bwlabeln(Vm,6);


% GEOMETRIC FEATURES EXTRACTION
STATS = regionprops3(L,'all');


% DATASET CONSTRUCTION
Vol = STATS.Volume;
Centroid = STATS.Centroid;
VoxelIdxList = STATS.VoxelIdxList;
Paxes = STATS.PrincipalAxisLength;

DATASET = STATS(:,1);
DATASET.PrimaryAxisLength = Paxes(:,1);
DATASET.SecondaryAxisLength = Paxes(:,2);
DATASET.TertiaryAxisLength = Paxes(:,3);
DATASET.Circularity = Paxes(:,1)./Paxes(:,2);
DATASET.CylinderSimilarity = ((((Paxes(:,1)+Paxes(:,2))/4).^2) .* pi .* Paxes(:,3))./Vol;


% CLASSIFICATION
PredictedClass = trainedModel.predictFcn(DATASET);
ClassifiedObjects = [table(PredictedClass, Centroid) DATASET table(VoxelIdxList)];

end


