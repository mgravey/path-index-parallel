function [groupcount]=getGroup(path,dep) 
    groupedPathSize = zeros(length(path),1);	% one allocation
    for idx=1:length(path)
        if(dep(path(idx))<0)
            groupedPathSize(idx)=1;
        else
            groupedPathSize(idx)=groupedPathSize(dep(path(idx)))+1;
        end
    end
    [groupcount]=groupcounts(groupedPathSize);
end