%function train(catNum, descNum, rgb)

%%%%%%%%%%%%%%%%%%
catNum=15;
descNum=500;
rgb=0;
gamma=0.01;
%%%%%%%%%%%%%%%%%%

dir_path = '/home/ayaz/Downloads/BSDS300/images/train';
dir_path_test = '/home/ayaz/Downloads/BSDS300/images/test';
iids = dir(fullfile(dir_path, '*jpg'));
iids_test = dir(fullfile(dir_path_test, '*jpg'));

%load('modified_4_3000_3_6.mat');
if (rgb == 1) 
    load(sprintf('CX%irgb.mat', descNum));
else
    load(sprintf('CX%igray.mat', descNum));
end
load(sprintf('idx%i.mat', catNum));
load(sprintf('centers%i.mat', catNum));
traindata=[];
Q=[];

[a,b]=hist(idx,unique(idx));

%2
for i = 1:numel(iids)  
    if (rgb == 1) 
        load(sprintf('vl_phow/%sdescrsrgb.mat',iids(i).name(1:end-4)));
    else
        load(sprintf('vl_phow/%sdescrsgray.mat',iids(i).name(1:end-4)));
    end
    DESCRS = double(DESCRS);
    n2 = dist2(CX,DESCRS);% Calculate the nearest sift feature
    [H,I]=min(n2);
    mx=1:1:descNum;
    n=hist(I,mx);% Form Histograms of similars features
    n=n./sum(n);
    traindata=[traindata;n];% Store histograms in traindata matrix
end

%3 test
for i = 1:numel(iids)  
    load(sprintf('vl_phow/%sdescrsgray.mat',iids(i).name(1:end-4)));
    DESCRS = double(DESCRS);
    n2 = dist2(CX,DESCRS);% Calculate the nearest sift feature
    [H,I]=min(n2);
    mx=1:1:descNum;
    n=hist(I,mx);% Form Histograms of similars features
    n=n./sum(n);
    Q=[Q;n];% Store histograms in traindata matrix
end


model = svmtrain(idx,traindata,sprintf('-s 0 -t 2 -c 100 -g %i', gamma));

%label = zeros(numel(iids_test),1);
label = zeros(numel(iids),1);

[label] = svmpredict(label, Q, model);


  

for i = 1:numel(iids)  
    imageID = str2double(iids(i).name(1:end - 4));
    segment(imageID,ceil(centers(label(i),1) * 100),ceil(centers(label(i), 2) * 1200),centers(label(i),1) * 50);
end
    %%eval

    benchNewAlg(bsdsRoot,'color','ALG');
    trainscores = dlmread(sprintf('%s/color/ALG/scores.txt',bsdsRoot));
    fitnessvalues = trainscores(:,4);
    clf;
    histogram(fitnessvalues);
    