%extractPatch.m
%
%given a bunch of interest point centers, extract a n by n patch from it

function output = extractPatch(img, frames, n)

if max(max(max(img))) > 1
    img = double(img)./255;
end

[r,c,z] = size(img);

patchR = zeros(n*n,size(frames,2));
patchG = zeros(n*n,size(frames,2));
patchB = zeros(n*n,size(frames,2));

count = 1;
for i = 1:size(frames,2)
    
    %try
    fromR = max(1, round(frames(2,i))-(n/2 - 1));
    fromC = max(1, round(frames(1,i))-(n/2 - 1));
    toR = min(r, round(frames(2,i))+(n/2));
    toC = min(c, round(frames(1,i))+(n/2));

    tR = img(fromR:toR, fromC:toC,1);
    tG = img(fromR:toR, fromC:toC,2);
    tB = img(fromR:toR, fromC:toC,3);
    
    if length(tR(:)) == n*n
        patchR(:,count) = tR(:);
        patchG(:,count) = tG(:);
        patchB(:,count) = tB(:);
        count = count + 1;
    end
%     catch err
%          keyboard;
%     end
end
patchR(:,count:end) = [];
patchG(:,count:end) = [];
patchB(:,count:end) = [];

output{1} = double(patchR);
output{2} = double(patchG);
output{3} = double(patchB);

