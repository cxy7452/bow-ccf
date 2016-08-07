%genBoWsoftImg.m
%
%generate Bag-of-Word histograms for an img 
%
%
%Chen-Ping Y 10/13/2014

function output = genBoWsoftImg( inputFeatures, stde, vocab )

numWords = size(vocab,2);
%variance = [0.01, 0.04, 0.07, 0.1, 0.13, 0.16]

%compute euclidean distance
temp = pdist2(inputFeatures', vocab');

%invert it, so that more similar has larger value
temp = repmat(max(temp, [], 2), 1, numWords) - temp + eps;

% %adaptive variance based on the closest distance from the centroids
% if isempty(stde)
%     %multipliers = [1, 3, 5, 7, 9, 11];
%     multipliers = [1, 2, 3, 5, 8, 13];
%     stde = max(max(temp))*multipliers;
% end

%apply gaussian weighting
imgHist = zeros(length(stde), numWords);
myu = max(max(temp));
for i = 1:length(stde)
    %wTemp = exp(-((temp(:)-myu).^2)./(2*variance(i)));
    wTemp = (1/(2*pi*(stde(i)^2)))*exp(-((temp(:)-myu).^2)./(2*(stde(i)^2)));
    wTemp = reshape(wTemp, size(temp,1), size(temp,2));
    temp0 = sum(wTemp,1);
    imgHist(i,:) = temp0./sum(temp0);
end

output = imgHist;


