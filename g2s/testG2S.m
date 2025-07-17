simSize=[200 200];
path=reshape(randperm(prod(simSize)),simSize);
kernel=ones([51,51]);
n=50;
j=8;

%%
%load data
ti=imread('https://raw.githubusercontent.com/GAIA-UNIL/TrainingImagesTIFF/master/stone.tiff');
%%
% QS call using G2S
[simulation1,t1]=g2s('-a','qs','-ti',ti,'-di',nan(simSize),'-dt',[0],'-k',1.2,'-n',n,'-ki',kernel,'-j',j,'-sp',path,'-s',100);
%%
[simulation2,t2]=g2s('-a','qs','-ti',ti,'-di',nan(simSize),'-dt',[0],'-k',1.2,'-n',n,'-ki',kernel,'-j',j,'-sp',path,'-s',100,'-wPO');
%%
[t1,t2]

(t1-t2)/t1