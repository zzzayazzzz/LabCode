catNum = 15;
descNum = 500;
rgb=0;

dir_path = '/home/ayaz/Downloads/BSDS300/images/train';
featuresfolder = 'alexnet';
iids = dir(fullfile(dir_path, '*jpg'));
X=[];
fast=0;
traindata = [];

for i = 1:numel(iids)  
    
    I(i,:,:,:) = dlmread(sprintf('trainparams/%sparams', iids(i).name(1:end-4)));
        
end
idx = zeros(numel(iids),2);

I(:,1) = I(:,1)/100;
I(:,2) = I(:,2)/1200;
I(:,3) = I(:,3)/50;
[idx,centers] = kmeans(I,catNum);

[a,b]=hist(idx,unique(idx));

for i = 1:numel(iids)  
    
    I(i,:,:,:) = dlmread(sprintf('trainparams/%sparams', iids(i).name(1:end-4)));
    if (rgb == 1) 
        load(sprintf('%s/%sdescrsrgb.mat', featuresfolder, iids(i).name(1:end-4)));
    else
        load(sprintf('%s/%sdescrsgray.mat', featuresfolder, iids(i).name(1:end-4)));
    end
    %if (featuresfolder == 'vl_phow')
    %    X = [X; DESCRS];
    %else                %%% for alexnet
        %DESCRS = DESCRS';
        X = [X, DESCRS];
    %end
   
    %%%
    %%%X=[X;DESCRS];
    
end

%save('modified_4_3000_3_6.mat','X');
X = double(X);
[a,b] = size(X);

if (a==1)
    %CX=vgg_kmeans(X, descNum);% Clustering
    tic;
    [CX,A] = vl_kmeans(X, descNum,'Initialization', 'plusplus');
    toc;
    %maxiters changed to 38 in the file
else
   tic;
   if (fast==1)
       [CX,A] = vl_kmeans(X, descNum,'Initialization', 'plusplus', 'Algorithm','ANN','MaxNumComparisons',descNum/10);
   else
       [CX,A] = vl_kmeans(X, descNum,'Initialization', 'plusplus');
   end
   toc;
end
CX=CX';

if (rgb == 1) 
    save(sprintf('CX_%s_%i_rgb.mat', featuresfolder, descNum),'CX');
else
    save(sprintf('CX_%s_%i_gray.mat', featuresfolder, descNum),'CX');
end
%%wont distingish between rgb and gray...
save(sprintf('idx_%s_%i.mat',featuresfolder, catNum)','idx');
save(sprintf('centers_%s_%i.mat',featuresfolder, catNum),'centers');
train2;