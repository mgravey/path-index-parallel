simSize=[200 200];

val=nan(prod(simSize),1);
path=randperm(prod(simSize));
val(path)=1:prod(simSize);
im=reshape(val,simSize);
ks=51;

kernel=ones([ks,ks]);
%%kernel=ones(simSize/2+1);
n=50;
dep=getDependancy(im,kernel,n);


%% optimal path
[~,idx]=sort(dep(path));
optimalPath=path(idx);

%%
threadings=(1:2000);

waitingDep=(1:length(path))-dep(path);
waitingDepIO=(1:length(path))-dep(optimalPath);

extraWaiting=-sum(min(waitingDep-(threadings)',0),2);
extraWaitingOP=-sum(min(waitingDepIO-(threadings)',0),2);
figure()
plot(threadings,extraWaiting)
hold on
plot(threadings,extraWaitingOP)

%% waisted ressouce in fucntion of the total computation

figure()
plot(threadings,extraWaiting/length(path))
hold on
plot(threadings,extraWaitingOP/length(path))


%% time wise


timePara=(length(path)+extraWaiting./(threadings)')./(threadings)';
timeParaOP=(length(path)+extraWaitingOP./(threadings)')./(threadings)';

figure()
plot(threadings,timePara)
hold on
plot(threadings,timeParaOP)

figure()
plot(threadings,timePara./timeParaOP)