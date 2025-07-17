function [dependanceImage] = getDependancy(image,kernel,n)
    dist=kernel*0;
    dist(ceil(end/2),ceil(end/2))=1;
    dependanceImage=image*nan;
    makeKernelDistanceNoise=bwdist(dist);%+rand(size(kernel));
    offset=size(kernel)/2;
    padImage=padarray(image,floor(offset),nan,"both");
    for j=1:size(image,2)
        for i=1:size(image,1)
            %[i,j]
            localPtach=padImage(i:i+size(kernel,1)-1,j:j+size(kernel,2)-1);
            center=localPtach(ceil(end/2),ceil(end/2));
            val=localPtach(localPtach<center);
            [~,idx]=sort(makeKernelDistanceNoise(localPtach<center));
            val=val(idx);
            maxVal=max(val(1:min(end,n)));
            if(isempty(maxVal))
                maxVal=-1;
            end
            dependanceImage(i,j)=maxVal;
        end
    end
end

