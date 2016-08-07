%extractCCFs.m
%
%given the BoW descriptors of the categories, extract the CCFs of the
%categories.
%
%Chen-Ping Yu
%8/06/2016

%% inputs
%for loading
datasetPath = '.\dataset\SBU-hierarchical68\';

%for loading and saving
featurePath = '.\dataset\features\';


%% go through each category and extract the CCFs
siftPath = [featurePath, 'dsift\'];
huePath = [featurePath, 'hue\'];
bowPath = [featurePath, 'BoW_soft_descrs\'];

catList = dir(datasetPath);
catList(1) = [];
catList(1) = [];
numCat = length(catList);

numWords = 1000;
totalWords = numWords + 64;
octave = 3;

catFeatures = cell(numCat,1);
catMatrix = cell(numCat,1);
catScores = cell(numCat,1);

catFeaturesBad = cell(numCat,1);
catScoresBad = cell(numCat,1);

avgWord = 1/numWords;
avgHue = 1/64;

categories = cell(numCat,1);

%for subordinates
for i = 1:numCat
    [num2str(i), '/', num2str(numCat)]

    categories{i,1} = catList(i).name;
    
    matList = dir([featurePath, 'dsift\', catList(i).name, '\*.mat']);
    
    catMatrix = [];
    catMatrix2 = [];
    
    for j = 1:length(matList)
        
        %load its bow histograms
        load([bowPath, catList(i).name, '\', matList(j).name(1:end-4), '_vocab', num2str(numWords), '.mat']);
        
        %load its hue histogram
        load([huePath, catList(i).name, '\', matList(j).name]);
        
        %combine them
        catMatrix = [catMatrix; softHist(octave,:)];
        catMatrix2 = [catMatrix2; hueHist'];
    end
    
    avgFreq = mean(catMatrix);
    fStd = std(catMatrix);
    
    q3freq = prctile(avgFreq, 75);
    freqFence = q3freq+1.5*iqr(avgFreq);
    goodInd = find(avgFreq > freqFence);
    
    avgFreq2 = avgFreq(goodInd);
    fStd2 = fStd(goodInd);
    tempScores = avgFreq2./fStd2;
    [indx, c] = kmeans(tempScores', 2, 'Replicates', 10, 'EmptyAction', 'drop');
    
    
    %for color
    avgFreqH = mean(catMatrix2);
    fStdH = std(catMatrix2);
    q3freqH = prctile(avgFreqH, 75);
    freqFenceH = q3freq+1.5*iqr(avgFreqH);
    goodIndH = find(avgFreqH > freqFenceH);
    
    avgFreq2H = avgFreqH(goodIndH);
    fStd2H = fStdH(goodIndH);
    tempScoresH = avgFreq2H./fStd2H;
    [indx, cH] = kmeans(tempScoresH', 2, 'Replicates', 10, 'EmptyAction', 'drop');
    
    catFeatures{i,1} = [goodInd(tempScores > mean(c)), goodIndH(tempScoresH > mean(cH))+1000]';
    catScores{i,1} = [tempScores(tempScores > mean(c)), tempScoresH(tempScoresH > mean(cH))]';
    
    allScores = [avgFreq./fStd, avgFreqH./fStdH];
    catFeaturesBad{i,1} = setdiff(1:numWords+64, catFeatures{i,1})';
    catScoresBad{i,1} = allScores(catFeaturesBad{i,1})';
    
end

catExcel = cell(length(categories),2);
for i = 1:length(categories)
    catExcel{i,1} = i;
    catExcel{i,2} = categories{i};
end

%save the results
xlswrite([featurePath,'categoryID.xls'], catExcel);
save([featurePath,'categories.mat'], 'categories');
save([featurePath, 'CCFs.mat'], 'catFeatures', 'catScores');















