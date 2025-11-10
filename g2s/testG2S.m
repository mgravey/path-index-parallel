addpath '/Users/mathieugravey/githubProject/G2S/build/matlab-build'
simSize=[200 200];
path=reshape(randperm(prod(simSize)),simSize);
kernel=ones([51,51]);
n=50;
j=64;

seed=100;

%%
%load data
ti=imread('https://raw.githubusercontent.com/GAIA-UNIL/TrainingImagesTIFF/master/stone.tiff');
%%
% QS call using G2S
[simulation1,t1]=g2s('-sa','138.232.184.13','-a','qs','-ti',ti,'-di',nan(simSize),'-dt',[0],'-k',1.2,'-n',n,'-ki',kernel,'-j',j,'-sp',path,'-s',seed);
%%
[simulation2,t2]=g2s('-sa','138.232.184.13','-a','qs','-ti',ti,'-di',nan(simSize),'-dt',[0],'-k',1.2,'-n',n,'-ki',kernel,'-j',j,'-sp',path,'-s',seed,'-wPO');
%%
[t1,t2]

(t1-t2)/t1


%%

figure
ts=(1:128)*NaN;
for j=randperm(128)
    [simulation,ts(j)]=g2s('-sa','138.232.184.13','-a','qs','-ti',ti,'-di',nan(simSize),'-dt',[0],'-k',1.2,'-n',n,'-ki',kernel,'-j',j,'-sp',path,'-s',seed);
    plot(1:128,ts)
    drawnow
end

plot(1:128,ts)