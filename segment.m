function segment(iid, clustNum, superpixelNum, compactness,test)
if nargin<5, I1=imread(sprintf('%s/images/train/%d.jpg',bsdsRoot,iid)); 
else
I1=imread(sprintf('%s/images/test/%d.jpg',bsdsRoot,iid));
end
[y1,x1,z1] = size(I1);
[labels, numlabels] = slicmex(I1,superpixelNum,compactness);
while numlabels < clustNum
    superpixelNum = superpixelNum+1;
    [labels, numlabels] = slicmex(I1,superpixelNum,compactness);
    
end

%%change to LAB                         !
I1=rgb2lab(I1);
I2 = im2double(I1);

labels=labels+1;


%1-3:RGB or LAB
%4 is cluster number
empty_individual.Data=zeros(y1,x1,z1+1);
empty_individual.Data(:,:,1:3)=I2;

%empty_individual.adjData=zeros(x1*y1*2-(x1+y1),3);
empty_individual.adjData=zeros(0,3);
avgColors=zeros(numlabels,4);%rgb and size

for i=1:y1
    for j=1:x1
        if  j<x1 && labels(i,j)~=labels(i,j+1)
            empty_individual.adjData(end+1, :) = [min(labels(i,j),labels(i,j+1)) max(labels(i,j),labels(i,j+1)) 0];
        end
        if i<y1 && labels(i,j)~=labels(i+1,j)
            empty_individual.adjData(end+1, :) = [min(labels(i,j),labels(i+1,j)) max(labels(i,j),labels(i+1,j)) 0];
        end
        avgColors(labels(i,j),1)=avgColors(labels(i,j),1)+I2(i,j,1);
        avgColors(labels(i,j),2)=avgColors(labels(i,j),2)+I2(i,j,2);
        avgColors(labels(i,j),3)=avgColors(labels(i,j),3)+I2(i,j,3);
        avgColors(labels(i,j),4)=avgColors(labels(i,j),4)+1;
    end
end
%calculate avg colors
[temp1,temp2]= size(avgColors);
for i=1:temp1
    for j=1:3
        avgColors(i,j)=avgColors(i,j)/avgColors(i,4);
    end
end

empty_individual.adjData = unique(empty_individual.adjData,'rows');
[temp1,temp2]= size(empty_individual.adjData);
%calculate distance of adj superpixels
for i=1:temp1
    empty_individual.adjData(i,3)=hypot(hypot(avgColors(empty_individual.adjData(i,1),1)-avgColors(empty_individual.adjData(i,2),1),avgColors(empty_individual.adjData(i,1),2)-avgColors(empty_individual.adjData(i,2),2)),avgColors(empty_individual.adjData(i,1),3)-avgColors(empty_individual.adjData(i,2),3));
end

%construct graph and mst
s = transpose(empty_individual.adjData(:,1));
t = transpose(empty_individual.adjData(:,2));
weights = transpose(empty_individual.adjData(:,3));
G = graph(s,t,weights);
T = minspantree(G);
sortedEdges=sortrows(T.Edges,2,'descend');
%TODO change 9 later

fprintf('iid = %d\n',iid);
fprintf('clustNum = %d\n',clustNum);
fprintf('numlabels = %d\n',numlabels);
fprintf('superpixedlNum = %d\n',superpixelNum);
fprintf('compactness = %d\n',compactness);

temp1=transpose(sortedEdges(1:clustNum-1,1).EndNodes(:,1));
temp2=transpose(sortedEdges(1:clustNum-1,1).EndNodes(:,2));
%temp3=transpose(sortedEdges(1:clustNum-1,2).Weight);

visitedNodes=ones(numlabels,1);

for i=1:clustNum-1
    T = rmedge(T,temp1(i),temp2(i));
end


%colors = uint8(distinguishable_colors(clustNum, [0,0,0])*255);
clust=1;
for i=1:numlabels
    if visitedNodes(i)
        v=dfsearch(T,i);
        visitedNodes(v(:))=0;
        for j=1:size(v)
            for row=1:y1
                for col=1:x1
                    if labels(row,col)==v(j)
                        empty_individual.Data(row,col,4)=clust;
                        %I3(row,col,:)=colors(clust,:);
                    end
                    
                end
            end
        end
        clust=clust+1;
    end
    
end



I4=zeros(y1,x1);
for i = 1:y1-1
    for j = 1:x1-1
        if empty_individual.Data(i,j,4)~=empty_individual.Data(i+1,j,4) I4(i,j)=1;
        end
        if empty_individual.Data(i,j,4)~=empty_individual.Data(i,j+1,4) I4(i,j)=1;
        end
      %  if empty_individual.Data(i,j,4)~=empty_individual.Data(i+1,j+1,4) I4(i+1,j+1)=1;
      %  end
    end
end
imwrite(I4,fullfile(bsdsRoot,sprintf('/color/ALG/%d.bmp',iid)));


%{
I5 = readSeg(sprintf('%d.seg',iid));
I6=ones(y1,x1);
for i = 1:y1-1
    for j = 1:x1-1
        if I5(i,j)~=I5(i+1,j) || I5(i,j)~=I5(i,j+1) I6(i,j)=0;
        end
    end
end
imshow(I6);
%}
%{
I6=ones(y1,x1);
I5 = readSegs('color', 167062, bsdsRoot);
[temp1, temp2] = size(I5);
seg=1;
for seg = 1:temp2
    temp1=cell2mat(I5(temp2));
    i=1;j=1;
    for i = 1:y1-1
        for j = 1:x1-1
            if temp1(i,j)~=temp1(i+1,j) || temp1(i,j)~=temp1(i,j+1) I6(i,j)=0;
            end
        end
    end
    
end
imshow(I6);
%}

%imwrite(I6, sprintf('%d.bmp',iid));

%

%Now benchmarking the segmented image
%iids_test = load(fullfile('iids_test.txt'));

%one image
%boundaryBench(bsdsRoot, 'color', iid);
%several images
%%boundaryBench(bsdsRoot, 'color', iids_test);

end