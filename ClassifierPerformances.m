function Performances = ClassifierPerformances(TrueClasses,Predictions)

Classes = sort(string(unique(TrueClasses)));

% Total number of predictions
NumPred = numel(Predictions);

% Correct predictions
iC = Predictions == TrueClasses;
CorrPred = sum(iC);

% Positives
iP = TrueClasses == Classes(1);
P = sum(iP); 

% Negatives
iN = ~iP;
N = sum(iN); 

% True positives
iTP = iC & iP;
TP = sum(iTP);

% False negatives
iFN = (~iC) & iP;
FN = sum(iFN);

% True negatives
iTN = iC & (~iP);
TN = sum(iTN);

% False positives
iFP = (~iC) & (~iP);
FP = sum(iFP);

% Performances
Performances.Accuracy = 100*CorrPred/NumPred;        % percentage of correct predictions
Performances.Sensitivity = 100*TP/P;                 % sensitivity or true positive rate
Performances.Specificity = 100*TN/N;                 % specificity or true negative rate
Performances.MissRate = 100*FN/P;                    % miss rate or false negative rate
Performances.FallOut = 100*FP/N;                     % fall-out or false positive rate

% Confusion matrix (number of observations)
Performances.ConfusionMatrix = [TP FN; FP TN];
Performances.ConfusionMatrixPercentage = 100*[TP/P FN/P; FP/N TN/N];
plotConfMat(Performances.ConfusionMatrix,{"Electrode","Non-electrode"});

end


function plotConfMat(varargin)
%PLOTCONFMAT plots the confusion matrix with colorscale, absolute numbers
%   and precision normalized percentages
%
%   usage: 
%   PLOTCONFMAT(confmat) plots the confmat with integers 1 to n as class labels
%   PLOTCONFMAT(confmat, labels) plots the confmat with the specified labels
%
%   Vahe Tshitoyan
%   20/08/2017
%
%   Arguments
%   confmat:            a square confusion matrix
%   labels (optional):  vector of class labels

% number of arguments
switch (nargin)
    case 0
       confmat = 1;
       labels = {'1'};
    case 1
       confmat = varargin{1};
       labels = 1:size(confmat, 1);
    otherwise
       confmat = varargin{1};
       labels = varargin{2};
end

confmat(isnan(confmat))=0; % in case there are NaN elements
numlabels = size(confmat, 1); % number of labels

% calculate the percentage accuracies
% % % % confpercent = 100*confmat./repmat(sum(confmat, 1),numlabels,1); % commented by Emilio Andreozzi
confpercent = 100*confmat./repmat(sum(confmat, 2),1,numlabels); % added by Emilio Andreozzi

% GENERATION OF COLORS (added by Emilio Andreozzi)
SG = 0.01*confpercent.*eye(size(confpercent));
CG = cat(3,zeros(size(SG)),eye(size(SG)),zeros(size(SG)));
CGH = rgb2hsv(CG);
CG = hsv2rgb(cat(3,CGH(:,:,1)-0.05,CGH(:,:,2).*SG*0.7,CGH(:,:,3)-0.2*SG));

SR = 0.01*confpercent.*(1-eye(size(confpercent)));
CR = cat(3,1-eye(size(SR)),zeros(size(SR)),zeros(size(SR)));
CRH = rgb2hsv(CR);
CR = hsv2rgb(cat(3,CRH(:,:,1)+0.08,CRH(:,:,2).*SR,CRH(:,:,3)));
confpercentRGB = CG + CR;


% plotting the colors
figure                  % added by Emilio Andreozzi
% imagesc(confpercent);   % commented by Emilio Andreozzi
imagesc(confpercentRGB);   % added by Emilio Andreozzi
title(sprintf('Accuracy: %.2f%%', 100*trace(confmat)/sum(confmat(:))));
% % % % ylabel('Output Class'); xlabel('Target Class');   % commented by Emilio Andreozzi
ylabel('True Class'); xlabel('Predicted Class');    % added by Emilio Andreozzi

% set the colormap
colormap(flipud(gray));

% Create strings from the matrix values and remove spaces
textStrings = num2str([confpercent(:), confmat(:)], '%.1f%%\n%d\n');
textStrings = strtrim(cellstr(textStrings));

% Create x and y coordinates for the strings and plot them
[x,y] = meshgrid(1:numlabels);
hStrings = text(x(:),y(:),textStrings(:), ...
    'HorizontalAlignment','center');

% Get the middle value of the color range
midValue = mean(get(gca,'CLim'));


% Choose white or black for the text color of the strings so
% they can be easily seen over the background color
textColors = repmat(confpercent(:) > midValue,1,3);
% set(hStrings,{'Color'},num2cell(textColors,2));   % commented by Emilio Andreozzi 

% Setting the axis labels
set(gca,'XTick',1:numlabels,...
    'XTickLabel',labels,...
    'YTick',1:numlabels,...
    'YTickLabel',labels,...
    'TickLength',[0 0]);
end