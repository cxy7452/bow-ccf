%getHueDescrs.m
%
%compute the hue descriptor

function output = getHueDescrs(img, frames, binNum)

%get the SIFT descriptors
if isempty(frames)
    imgs = im2single(rgb2gray(img));
    [frames, ~] = vl_covdet(imgs, 'method', 'HessianLaplace');
end
patches = extractPatch(img, frames, 20);
hDescr = HueDescriptor(patches{1}, patches{2}, patches{3}, binNum, 0, 0.6);

%normalized descriptor
if sum(sum(hDescr)) == 0
    output = ones(binNum,1)./binNum;
else
    output = sum(hDescr,2)./sum(sum(hDescr));
end