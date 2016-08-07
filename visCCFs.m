%visCCFs.m
%
%visualize the CCFs of a given category as average of image patches

%clear all;

%% inputs
datasetPath = '.\dataset\SBU-hierarchical68\';
featurePath = '.\dataset\features\';
catNum = 14;
topCCFs = 10; %up to top k number of CCFs to be visualized


%% visualization code
load([featurePath, 'vocab1000.mat']);
load([featurePath, 'CCFs.mat']);
load([featurePath, 'categories.mat']);

kdtree_vocab = vl_kdtreebuild(vocab);

dSample = 0.5; 
colorSIFT = 1;

catName = categories{catNum,1};
ccf = [catFeatures{catNum}, catScores{catNum}];


siftCCF = sortrows(ccf(ccf(:,1) <= 1000,:), -2);
siftCCF(topCCFs+1:end,:) = [];

%find the 2 closest factor, for subplot
t = factor(topCCFs);
lInd = 1;
rInd = length(t);
r = t(1);
c = t(end);
while abs(lInd-rInd) > 1
    if r < c
        r = r*t(lInd+1);
        lInd = lInd + 1;
    else
        c = c*t(rInd-1);
        rInd = rInd - 1;
    end
end

%load the features
siftPatch = cell(topCCFs,1);
siftPatchSize = zeros(topCCFs,1);
magnif = 3;
count = zeros(topCCFs,1);
%load all exemplars of all those categories
matList = dir([featurePath, 'dsift\', catName, '\*.mat']);

%for each image
for j = 1:length(matList)
    
    j
    fileName = matList(j).name(1:end-4);
    img = imread([datasetPath, catName, '\', fileName '.jpg']);
    
    if size(img,1) > 480
        img = imresize(img, [480 NaN]);
    end
    
    if size(img,3) == 1
        img = repmat(img, [1,1,3]);
    end
    %hsvImg = rgb2hsv(img);
    img1 = single(img(:,:,1));
    img2 = single(img(:,:,2));
    img3 = single(img(:,:,3));
    
    
    %sift features
    load([featurePath, 'dsift\', catName, '\', fileName, '.mat'])
    
    %find which feature belongs to which centroid
    binsa = double(vl_kdtreequery(kdtree_vocab, vocab, single(descrs0), 'MaxComparisons', 50));
    
    %for each CCF
    for k = 1:min([topCCFs, size(siftCCF,1)])
        
        %row1: x, row2: y, row3: circle radius
        t = frames(:,binsa == siftCCF(k,1));
        
        if round(dSample*size(t,2)) >= 1
            
            %goodsize = mode(t(3,:));
            goodsize = 5; %force to use the largest patch size possible
            
            t = t(:,randsample(size(t,2), round(dSample*size(t,2))));
            
            tempSet1 = single(zeros(1+2*goodsize*magnif, 1+2*goodsize*magnif));
            tempSet2 = tempSet1;
            tempSet3 = tempSet1;
            for z = 1:size(t,2)
                
                %if t(3,z) == goodsize
                
                %pSize = t(3,z);
                pSize = 5;
                
                cornerR = round(t(2,z)-pSize*magnif);
                cornerC = round(t(1,z)-pSize*magnif);
                
                if cornerR >= 1 & cornerC >=1 & cornerR+pSize*magnif*2 <= size(img,1) & cornerC+pSize*magnif*2 <= size(img,2)
                    
                    tempSet1 = tempSet1 + img1(cornerR:cornerR+pSize*magnif*2, cornerC:cornerC+pSize*magnif*2);
                    tempSet2 = tempSet2 + img2(cornerR:cornerR+pSize*magnif*2, cornerC:cornerC+pSize*magnif*2);
                    tempSet3 = tempSet3 + img3(cornerR:cornerR+pSize*magnif*2, cornerC:cornerC+pSize*magnif*2);
                    
                    siftPatchSize(k,1) = siftPatchSize(k,1) + t(3,z);
                    count(k) = count(k) + 1;
                end
                %end
            end
            
            %average it
            if size(siftPatch{k,1},1) == 0
                if colorSIFT == 0
                    siftPatch{k,1} = tempSet1;
                else
                    siftPatch{k,1} = cat(3, tempSet1, tempSet2, tempSet3);
                end
            else
                if colorSIFT == 0
                    siftPatch{k,1} = siftPatch{k,1} + tempSet1;
                else
                    siftPatch{k,1} = siftPatch{k,1} + cat(3, tempSet1, tempSet2, tempSet3);
                end
            end
            
        end
    end
    
end

for j = 1:topCCFs
    siftPatchSize(j,1) = round(siftPatchSize(j,1)/count(j));
    siftPatch{j,1} = siftPatch{j,1}./count(j);
end

%plot them out
if r > c
    t = r;
    r = c;
    c = t;
end

figure,
for i = 1:min([topCCFs, size(siftCCF,1)])
    %subplot(r,c,i), imagesc(uint8(siftPatch{i,1}));
    if colorSIFT == 0
        minI = min(min(siftPatch{i,1}));
        maxI = max(max(siftPatch{i,1}));
        [a, b] = linTransform( minI, maxI, 0, 255);
        showPatch = uint8(siftPatch{i,1}.*a + b);
    else
        hsvImg = rgb2hsv(siftPatch{i,1});
        tI = hsvImg(:,:,3);
        [a, b] = linTransform( min(min(tI)), max(max(tI)), 0, 1);
        hsvImg(:,:,3) = tI.*a+b;
        showPatch = hsv2rgb(hsvImg);
    end
    subplot(r,c,i), imshow(showPatch);
    %imshow(uint8(siftPatch{i,1}));
end
suptitle(catName)









