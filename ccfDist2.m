%ccfDist2.m
%
%generate BoW histograms for the given pair of image, and compute their
%chisq distance using their CCFs.
%
%img1p: the file path and name of the first image
%id1: the category ID for the first input image
%img2p: the file path and name of the second image
%id2: the category ID for the second input image
%featPath: the path to the 'features' directory
%
%example usage:
%ccfDist2('fighter01.png', 20, 'racecar01.png', 37, 'c:/work/myDataset/features/')
%
%Date: 8/06/2018
%Author: Chen-Ping Yu

function output = ccfDist2(img1p, id1, img2p, id2, featPath)

%load the features
if featPath(end) ~= '/' & featPath(end) ~= '\'
    featPath = [featPath,'/'];
end

load([featPath, 'categories.mat']);
load([featPath, 'vocab1000.mat']);
load([featPath, 'CCFs.mat']);

disp(['category ''',categories{id1}, ''' vs category ''', categories{id2},'''']);

numWords = size(vocab,2);
baseScale = 1;
octaves = baseScale*(2.^(4:0.5:6));

img1 = imread(img1p);
img2 = imread(img2p);

%% extract DSift and Hue
%standardize
if size(img1,1) > 480
    img1 = imresize(img1, [480 NaN]);
end
if size(img2,1) > 480
    img2 = imresize(img2, [480 NaN]);
end

dSIFT1 = extractDSIFT( img1);
dSIFT2 = extractDSIFT( img2);

descrs1 = dSIFT1{1};
frames1 = dSIFT1{2};
descrs2 = dSIFT2{1};
frames2 = dSIFT2{2};

%% generate the BoW and Hue histograms:
octave = 3;
siftHist1 = genBoWsoftImg( single(descrs1), octaves(octave), vocab );
siftHist2 = genBoWsoftImg( single(descrs2), octaves(octave), vocab );

hueHist1 = getHueDescrs(img1, frames1, 64)';
hueHist2 = getHueDescrs(img2, frames2, 64)';

%final combined histograms
totalWords = numWords + 64;
siftW = (totalWords-64)/totalWords;
hueW = 1-siftW;

imgHist1 = [siftHist1.*siftW, hueHist1.*hueW];
imgHist2 = [siftHist2.*siftW, hueHist2.*hueW];

%% compute their CCF chisq distance
ccf1 = catFeatures{id1};
ccf2 = catFeatures{id2};
ccfT = unique([ccf1(:);ccf2(:)]);

imgHist1 = imgHist1(1,ccfT);
imgHist2 = imgHist2(1,ccfT);
imgHist1 = imgHist1./sum(imgHist1);
imgHist2 = imgHist2./sum(imgHist2);

output = dist2(imgHist1, imgHist2, 'chisq');










