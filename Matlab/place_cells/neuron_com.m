clear all;
%close all;

[behavior_filepaths, temp]=uigetfile('*.mat', 'Chose behavior files to load:','MultiSelect','on');
load([temp behavior_filepaths]);

[cellsort_filepaths, temp]=uigetfile('*.mat', 'Chose cellsort files to load:','MultiSelect','on');
load([temp cellsort_filepaths]);

[pc_filepaths, temp]=uigetfile('*.mat', 'Chose PC files to load:','MultiSelect','on');
load([temp pc_filepaths]);
%% change the frame numbers according to your recorded data
%analyze specific range:
startF=1;%behavior.startframe(1);
endF=length(behavior.ybinned);
%  startF=14040;
%  endF=13000;
Fc3_DF=data.Fc3(startF:endF,:);
Fc2=data.Fc(startF:endF,:);
ybinned=behavior.ybinned(startF:endF);
% 
% empty_id=13610:14290-startF;
% Fc3_DF(empty_id,:)=[];
% Fc2(empty_id,:)=[];
% ybinned(empty_id,:)=[];
PC_id=find(~isnan(number_of_PFs));
%%
ybinned_GoodBehav=ybinned;
Fc3_DF_GoodBehav=Fc3_DF;

%%%%%%%%%%%%%%%%%%%parameters%%%%%%%%%%%%%%%%%

ybinned=ybinned';
E=bwlabel(double_thresh(ybinned,0.0145,0.014)); %labels each traversal

numneurons=size(Fc3_DF,2);
trackstart=min(ybinned_GoodBehav)+0.005; %track start location in quake units (+10 accounts for any noise in the track start location after teleportation)
trackend=max(ybinned_GoodBehav)-0.005; %track end location in quake units
ZThreshDivisor=4;%used to further break up the data in cases of long silent stretches

numbins=50;

binsize=(trackend-trackstart)/numbins;%in Quake unit

ybinmax=0.612;
%% correct E
    wrong_lap=0;
    for i=1:max(E)
            
        onpoint=find(E==i,1);
        offpoint=find(E==i,1,'last');    
%         end
        count=1;
        while max(ybinned(onpoint:offpoint))<ybinmax
           count=count+1;
           if i~=max(E) 
             offpoint=find(E==i+1,1,'last');
             E(onpoint:offpoint)=i;
             E(offpoint+1:end)=E(offpoint+1:end)-1;
           else
               E(onpoint:offpoint)=0;
           end

        end
        
    end

    
    for i=1:max(E)

        if i==1
        onpoint=find(E==i,1);
        if onpoint==1
            onpoint=2;
        end
        if ybinned(onpoint-1)>0.12
            E(E~=0)=E(E~=0)-1;
        end
        
        end

    end
    
mean_trans=[];
%%
figure1=figure('units','normalized','outerposition',[0 0 1 1])
figure2=figure('units','normalized','outerposition',[0 0 1 1])
subplot_x=10;
subplot_y=ceil(size(PC_id,2)/subplot_x);
%subplot_y=8;
COM=[];
binM=1:50;
count=1;
for ii =PC_id%1:numneurons    
    %%%%%%%%now cut out transients from each lap and bin them%%%%%%%%%%%%%%%%%
    
    %seperate transients into laps
    cut_mat=NaN(2000,1000);
    cut_mat_ybinned=NaN(2000,1000);
    wrong_lap=0;
    for i=1:max(E)

        onpoint=find(E==i,1);
        offpoint=find(E==i,1,'last');    

        if max(ybinned(onpoint:offpoint))>0.6
        %cut out the transient
        cut_mat(1:(offpoint-onpoint)+1,i)=Fc3_DF(onpoint:offpoint,ii); %cut out activity from each lap
        %cut out the ybinned associated with the transient
        cut_mat_ybinned(1:(offpoint-onpoint)+1,i)=ybinned(onpoint:offpoint,1);
        %figure; hold on;plot(cut_mat_ybinned);
        wrong_lap=0;
        else
        wrong_lap=1;    
        end
        
    end
    for i=1:max(E)
        [cut_mat_ybinned_sorted(:,i), idx] = sort(cut_mat_ybinned(:,i),1);
        cut_mat_sorted(:,i)=cut_mat(idx,i);
    end
    
    %bin activity
    cut_mat_ybinned_sorted(cut_mat_ybinned_sorted==0)=nan;
    topEdge = trackend; % define limits
    botEdge = trackstart; % define limits
    binMean=[];
    for r=1:max(E)
        x = cut_mat_ybinned_sorted(:,r); %split into x and y
        y = cut_mat_sorted(:,r);
        binEdges = linspace(botEdge, topEdge, numbins+1);
        [h,whichBin] = histc(x, binEdges);
        for i = 1:numbins
            flagBinMembers = (whichBin == i);
            binMembers     = y(flagBinMembers);
            binMean(i,r)     = mean(binMembers);
        end
    end
    
    mean_trans(ii,:)=mean(binMean,2);
    
    nonNANmean=binMean;
    nonNANmean(isnan(nonNANmean))=0;
    cur_com=sum(nonNANmean'.*binM,2)./sum(nonNANmean',2);
    cur_com(isnan(cur_com))=0;
    COM=[COM cur_com];

%     figure;
%     imagesc(binMean');
figure(figure1);
subplot(subplot_y,subplot_x,count);
bar(COM(:,count)-COM(1,count))
ylim([-50,50])

figure(figure2);
subplot(subplot_y,subplot_x,count);
imagesc(binMean')

count=count+1;    

    %close all
end %loops through each neuron