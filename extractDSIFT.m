%extractDSIFT.m
%
%this function extracts dense sift features, and discard the ones that are
%background/uniform features


function output = extractDSIFT( img )

%im1 = imread('E:\matlab2011b\work\Justin\Cleaned_up_dataset\filing cabinet\n04529681_76.JPEG');
im1 = im2single(img) ;

% make grayscale
if size(im1,3) > 1, im1g = rgb2gray(im1) ; else im1g = im1 ; end

%extract dense sift features

binSize = [3, 6, 9, 12, 15];
magnif = 3;

descrs = [];
frames = [];
for j = 1:length(binSize)
    
    stepSize = binSize(j)*1.5;
    
    [f1,d1] = vl_dsift(im1g, 'Step', stepSize, 'Size', binSize(j), 'Fast', 'Norm') ;
    f1Norm = f1(3,:);
    f1(3,:) = binSize(j)/magnif ;
    f1(4,:) = 0 ;
    
    %get rid of uniform features
    f0 = [];
    d0 = [];
    mF1Norm = mean(f1Norm);

    try
        for i = 1:length(f1)
            %if (f1Norm(i) >= mF1Norm*0.75  || f1Norm(i) <= mF1Norm*0.25) && median(d1(:,i)) > 0
            if f1Norm(i) >= mF1Norm*0.75 && median(d1(:,i)) > 0
                f0 = [f0, f1(:,i)];
                d0 = [d0, d1(:,i)];
            end
        end
    catch err
        continue;
    end
    descrs = [descrs, d0];
    frames = [frames, f0];
    
end

output{1} = descrs;
output{2} = frames;

%figure, imshow(im1), vl_plotframe(f0);



