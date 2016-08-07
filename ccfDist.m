%ccfDist.m
%
%Compute the CCF distance of a given image to a specified target category.
%
%targetLvl: the hierarchy level (sub, basic, super) of the target exemplar
%targetID: the category ID
%featPath: the path to the 'features' directory
%
%example usage:
%ccfDist('c:/work/airplane03.jpg', 3, 'c:/work/myDataset/features/')
%
%Date: 8/06/2016
%Author: Chen-Ping Yu

function output = ccfDist(imgP, targetID, featPath)

%%load the ccf info
if featPath(end) ~= '/' & featPath(end) ~= '\'
    featPath = [featPath,'/'];
end

load([featPath, 'categories.mat']);
load([featPath, 'vocab1000.mat']);
load([featPath, 'CCFs.mat']);

disp(['target category: ', categories{targetID}]);

tCCF = catFeatures{targetID};

numWords = size(vocab,2);
baseScale = 1;
octaves = baseScale*(2.^(4:0.5:6));

img = imread(imgP);

%% extract DSift and Hue
%standardize
if size(img,1) > 480
    img = imresize(img, [480 NaN]);
end

dSIFT1 = extractDSIFT( img);

descrs1 = dSIFT1{1};
frames1 = dSIFT1{2};

%% generate the BoW and Hue histograms:
octave = 3;
siftHist1 = genBoWsoftImg( single(descrs1), octaves(octave), vocab );

hueHist1 = getHueDescrs(img, frames1, 64)';

%final combined histograms
totalWords = numWords + 64;
siftW = (totalWords-64)/totalWords;
hueW = 1-siftW;

imgHist1 = [siftHist1.*siftW, hueHist1.*hueW];

%% compute their CCF chisq distance
targetName = categories{targetID};

load([featPath, 'meanHistograms\',targetName, '.mat']);
%octave = 1;

meanHist = [meanHist(octave,1:numWords).*siftW, meanHist(octave,numWords+1:end).*hueW];

imgHist1 = imgHist1(1,tCCF);
meanHist = meanHist(1,tCCF);

imgHist1 = imgHist1./sum(imgHist1);
meanHist = meanHist./sum(meanHist);

output = dist2(imgHist1, meanHist, 'chisq');









