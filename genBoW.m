%genBoW.m
%
%generate Bag-of-Word vocabulary and models, given a dataset.
%
%Chen-Ping Yu
%8/01/2016

%% inputs
%for loading
datasetPath = '..\dataset\SBU-hierarchical68\';

%for saving
featurePath = 'D:\matlab_work2\ccf_bow\release\dataset\features\';
siftPath = 'D:\matlab_work2\ccf_bow\features\dsift\';
huePath = 'D:\matlab_work2\ccf_bow\features\hue\';

%number of images per category for learning the BoW dictionary
numTrain = 25; 


%% extract the dsift and hue features for the 48 categories
if exist(featurePath, 'dir') == 0
    mkdir(featurePath);
end
catList = dir(datasetPath);
catList(1) = [];
catList(1) = [];

for i = 1:length(catList)
    i
    catName = catList(i).name;
    inDIR = [datasetPath, catName,'\'];
    
    %now generate dsift and hue
    inFiles = dir(inDIR);
    inFiles(1) = [];
    inFiles(1) = [];
    
    if exist([siftPath, catName], 'dir') == 0
        mkdir([siftPath, catName]);
    end
    if exist([huePath, catName], 'dir') == 0
        mkdir([huePath, catName]);
    end
    for j = 1:length(inFiles)
        img = imread([datasetPath, catName, '\', inFiles(j).name]);
        
        %standardize
        if size(img,1) > 480
            img = imresize(img, [480 NaN]);
        end
        
        out = extractDSIFT( img );
        descrs0 = out{1};
        frames = out{2};
        
        hueHist = getHueDescrs(img, frames, 64);
        
        %save
        
        save([siftPath, catName, '\', inFiles(j).name(1:end-4), '.mat'], 'descrs0', 'frames');
        save([huePath, catName, '\', inFiles(j).name(1:end-4), '.mat'], 'hueHist');
        
    end
    
end

%% load the first 'numTrain' images and build the dictionary from those.
toSample = round(100000/(numTrain*length(catList)));
trainingDescrs = zeros(128,100000);
beginInd = 1;
for i = 1:length(catList)
    i
    catName = catList(i).name;
    matList = dir([siftPath, catName, '\*.mat']);
    for j = 1:numTrain
        load([siftPath, catName, '\', matList(j).name]);
        if size(descrs0,2) > toSample
            descrs0 = descrs0(:,randsample(1:size(descrs0,2),toSample));
            
        end
        trainingDescrs(:,beginInd:beginInd+size(descrs0,2)-1) = descrs0;
        beginInd = beginInd + size(descrs0,2);
    end
end

trainingDescrs(:,beginInd:end) = [];
save([featurePath, 'BoW_soft_descrs\trainingDescrs.mat'], 'trainingDescrs');

%% use kmeans to obtain the actual vocabulary
load([featurePath, 'trainingDescrs.mat']);
numWords = 1000;
vocabTemp = [];
repeat = 2;
vEnergy = zeros(repeat,1);
for j = 1:repeat
    j
    [vocabTemp{j}, ~, vEnergy(j)] = vl_kmeans(single(trainingDescrs), numWords, 'algorithm', 'ann', 'MaxNumIterations', 50);
end

[~, minInd] = min(vEnergy);
vocab = vocabTemp{minInd};
save([featurePath, 'vocab1000.mat'], 'vocab');


%% generate the soft assignment BoW for all images
bowPath = [featurePath, 'BoW_soft_descrs\'];
meanPath = [featurePath, 'meanHistograms\'];
if exist(meanPath, 'dir') == 0
    mkdir(meanPath);
end
load([featurePath, 'vocab1000.mat']);
numWords = 1000;
%**check this for scale space octave info: http://www.vlfeat.org/api/sift.html#sift-tech-ss
%2 octaves starting from the 4th octave:
baseScale = 1;
octaves = baseScale*(2.^(4:0.5:6)); %2 octaves, half an octave increments

for i = 1:length(catList) %every category
    catName = catList(i).name;
    matList = dir([siftPath, catName, '\*.mat']);
    if exist([bowPath, catName], 'dir') == 0
        mkdir([bowPath, catName]);
    end
    
    [catList(i).name, ' ', num2str(i), '/', num2str(length(catList)), ',']
    
    meanHist = zeros(1,numWords+64);
    for j = 1:length(matList) %every image
        load([siftPath, catName, '\', matList(j).name]); %load dsift features
        load([huePath, catName, '\', matList(j).name]); %load hue features
        
        softHist = genBoWsoftImg( single(descrs0), octaves, vocab );
        
        save([bowPath, catName, '\', matList(j).name(1:end-4), '_vocab', num2str(numWords), '.mat'], 'softHist');
        
        meanHist = meanHist + [softHist, repmat(hueHist', length(octaves),1)];
    end
    
    meanHist = meanHist./length(matList);
    save([meanPath, catList(i).name, '.mat'], 'meanHist');
    
end






