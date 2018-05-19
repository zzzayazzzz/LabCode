%function train(catNum, descNum, rgb)

%%%%%%%%%%%%%%%%%%
catNum=15;
descNum=500;
rgb=0;
gamma=2.17;
featuresfolder = 'alexnet';
%0.01->0.537965tg

%2->0.5730
%1->0.5731
%1.5->0.5717
%%%%%%%%%%%%%%%%%%

dir_path = '/home/ayaz/Downloads/BSDS300/images/train';
dir_path_test = '/home/ayaz/Downloads/BSDS300/images/test';

iids = dir(fullfile(dir_path, '*jpg'));
iids_test = dir(fullfile(dir_path_test, '*jpg'));

%load('modified_4_3000_3_6.mat');
if (rgb == 1) 
    load(sprintf('CX_%s_%i_rgb.mat', featuresfolder, descNum));
else
    load(sprintf('CX_%s_%i_gray.mat', featuresfolder, descNum));
end
load(sprintf('idx_%s_%i.mat',featuresfolder, catNum));
load(sprintf('centers_%s_%i.mat',featuresfolder, catNum));
traindata=[];
Q=[];

[a,b]=hist(idx,unique(idx));

%2
for i = 1:numel(iids)  
    if (rgb == 1) 
        load(sprintf('%s/%sdescrsrgb.mat',featuresfolder,iids(i).name(1:end-4)));
    else
        load(sprintf('%s/%sdescrsgray.mat',featuresfolder,iids(i).name(1:end-4)));
    end
    DESCRS = double(DESCRS');
    %%% for alexnet
    %DESCRS = DESCRS';
    %%%
    n2 = dist2(CX,DESCRS);% Calculate the nearest feature
    [H,I]=min(n2);
    mx=1:1:descNum;
    n=hist(I,mx);% Form Histograms of similars features
    n=n./sum(n);
    traindata=[traindata;n];% Store histograms in traindata matrix
end

%3 test
for i = 1:numel(iids_test)  
    if (rgb == 1) 
        load(sprintf('%s/%sdescrsrgb.mat',featuresfolder,iids_test(i).name(1:end-4)));
    else
        load(sprintf('%s/%sdescrsgray.mat',featuresfolder,iids_test(i).name(1:end-4)));
    end
    DESCRS = double(DESCRS');
    n2 = dist2(CX,DESCRS);% Calculate the nearest feature
    [H,I]=min(n2);
    mx=1:1:descNum;
    n=hist(I,mx);% Form Histograms of similars features
    n=n./sum(n);
    Q=[Q;n];% Store histograms in test matrix
end

%model = svmtrain(idx,traindata,sprintf('-s 0 -t 1 -c 100 -g %i', gamma));
model = svmtrain(idx,traindata,sprintf('-s 0 -t 1 -g %i', gamma));
label = zeros(numel(iids_test),1);
[label] = svmpredict(label, Q, model);

for i = 1:numel(iids_test)  
    imageID = str2double(iids_test(i).name(1:end - 4));
    segment(imageID,ceil(centers(label(i),1) * 100),ceil(centers(label(i), 2) * 1200),centers(label(i),1) * 50,1);
end
    %%eval

benchNewAlg(bsdsRoot,'color','ALG');
trainscores = dlmread(sprintf('%s/color/ALG/scores.txt',bsdsRoot));
fitnessvalues = trainscores(:,5);
clf;
histogram(fitnessvalues);
    
%{    
comparison = zeros(100,3);
for i = 1:numel(iids_test)  

    comparison(i,1) = str2double(iids_test(i).name(1:end-4));
    comparison(i,2)=cfv(i);
    comparison(i,3)=fitnessvalues(i);
end
dlmwrite('comparison.txt',comparison,'delimiter','\t','precision',6);



for i=1:100
    for j=1:100
        if comparison(i,1)==webres(j,1);
            comparison(i,4)=webres(j,2);
        end
     end
end32eyr8u9
%}

load('comparison.mat');
for i=1:100
    if (comparison(i,1) == trainscores(i,1))
        comparison(i,3) = trainscores(i,5);
    end
end

higher = 0;
percentage = zeros(100,1);
for i = 1:100
    if (comparison(i,3)>comparison(i,4))
        higher = higher + 1;
        
    end
    percentage(i,1) = comparison(i,3)/comparison(i,4);
end

closest = max(percentage(:,1));
mean(percentage)

%%gammas
%{
gammas = [];
lol=[];
load('gammas.mat');
load('lol.mat');
for g = 1.07:0.01:2.2
    model = svmtrain(idx,traindata,sprintf('-s 0 -t 2 -c 100 -g %i', g));

    label = zeros(numel(iids_test),1);

    [label] = svmpredict(label, Q, model);

    %{    
    
    IDx=knnsearch(Q,traindata, 4);

    label = zeros(numel(iids_test),1);
    for i = 1:numel(iids_test)  
        for j = 1:4

            IDx(i,j)=idx(IDx(i,j));

        end
        label(i) = mode(IDx(i));
    end
    %}


    %%test

    for i = 1:numel(iids_test)  
        imageID=str2double(iids_test(i).name(1:end-4));
        segment(imageID,ceil(centers(label(i),1)*100),ceil(centers(label(i),2)*1200),centers(label(i),1)*50,1);

    end
    %%eval

    benchNewAlg(bsdsRoot,'color','ALG');
    trainscores = dlmread(sprintf('%s/color/ALG/scores.txt',bsdsRoot));
    fitnessvalues = trainscores(:,4);
    clf;
    histogram(fitnessvalues);
    
    %{
    comparison = zeros(100,3);
    for i = 1:numel(iids_test)  

        comparison(i,1) = str2double(iids_test(i).name(1:end-4));
        comparison(i,2)=cfv(i);
        comparison(i,3)=fitnessvalues(i);

    end
    dlmwrite('comparison.txt',comparison,'delimiter','\t','precision',6);
    %}
    
   % for i=1:100
   %     for j=1:100
   %         if comparison(i,1)==webres(j,1);
   %             comparison(i,4)=webres(j,2);
   %         end
   %     end
   % end

   % higher=0;
   % for i = 1:100
   %     if comparison(i,2)>comparison(i,4)
   %         higher = higher+1;
   %     end
   % end
    
   lol=[lol,fitnessvalues];
   gammas=[gammas,g];
   save('lol.mat','lol');
end

%end

summ = sum(lol);
summ = summ/100;
max(summ);
[num, idx] = max(summ(:));
%}
%{
georgeous = zeros(1,221);
for i=1:221
    summm = 0;
    for j=1:100
        summm = summm + lol(j,i);
    end
    georgeous(i)=summm;
end
%}
