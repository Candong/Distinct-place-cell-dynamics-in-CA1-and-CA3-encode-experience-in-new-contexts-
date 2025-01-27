clear all; %close all;
[behavior_filepaths, temp]=uigetfile('*.mat', 'Chose f files to load:','MultiSelect','on');
PF_center=[];
PF_mean=[];
PF_count=1;
placecell_id={};
MEAN=[];
if ~isa(behavior_filepaths,'cell') 
  behavior_filepaths={behavior_filepaths};  
    
end 
fcount=0;
ncount=0;
for f=1:size(behavior_filepaths,2)
 if contains(behavior_filepaths{f},'_f_')
    fcount=fcount+1;
    f_filepaths{fcount}=behavior_filepaths{f};
 elseif contains(behavior_filepaths{f},'_n_')
    ncount=ncount+1;
    n_filepaths{ncount}=behavior_filepaths{f}; 
     
 end
end
f_filepaths=sort(f_filepaths);
n_filepaths=sort(n_filepaths);
f_pc=0;
for f=1:size(f_filepaths,2)
load([temp f_filepaths{f}]);
placecell_id{f}=[];
f_pc=f_pc+size(mean_trans,1);
for i=1:size(sig_PFs,2)
    for j=1:size(sig_PFs,1)
        if ~isempty(sig_PFs{j,i})
            if number_of_PFs(i)<2
            binmean_temp=sig_PFs_with_noise{j,i};
            binmean_temp(isnan(binmean_temp))=0;
            binmean_PF_temp=sig_PFs{j,i};
            binmean_PF_temp(isnan(binmean_PF_temp))=0;
            
            mean_PF=mean(binmean_PF_temp,2);
            mean_PF_withnoise=mean(binmean_temp,2);
            [PF_center(PF_count) SP]=meanCOMandSP(binmean_PF_temp',1,50,50);
            %PF_center(PF_count)=find(mean_PF==max(mean_PF));
            PF_mean(PF_count,:)=mean_PF_withnoise;
            PF_count=PF_count+1;
            placecell_id{f}=[placecell_id{f} i];
            end
        end
    
    end
                   
end
%MEAN=[MEAN; mean_trans(placecell_id{f},:)];
end

[PF_sorted,sort_id]=sort(PF_center);
PF_mean_sorted=PF_mean(sort_id,:);
familiar_sort=sort_id;
% remove_id=find(mean(PF_mean_sorted')>3);
% PF_mean_sorted(remove_id,:)=[];
% familiar_sort(remove_id)=[];
f_PF_max=max(PF_mean_sorted');
f=figure;imagesc((PF_mean_sorted'./max(PF_mean_sorted'))');
title('novel day1')
colormap jet
f_PF_mean_sorted=PF_mean_sorted;
%%


%[behavior_filepaths, temp]=uigetfile('*.mat', 'Chose n files to load:','MultiSelect','on');
PF_center=[];
PF_mean=[];
PF_count=1;
% if ~isa(behavior_filepaths,'cell') 
%   behavior_filepaths={behavior_filepaths};  
%     
% end 
n_pc=0;
for f=1:size(n_filepaths,2)
load([temp n_filepaths{f}]);
n_pc=n_pc+size(mean_trans,1);
for i=1:size(sig_PFs,2)
    for j=1:size(sig_PFs,1)
        if ~isempty(sig_PFs{j,i})
            if number_of_PFs(i)<2
            binmean_temp=sig_PFs_with_noise{j,i};
            binmean_PF_temp=sig_PFs{j,i};
            
            mean_PF=mean(binmean_PF_temp,2);
            mean_PF_withnoise=mean(binmean_temp,2);
            [PF_center(PF_count) SP]=meanCOMandSP(binmean_PF_temp',1,50,50);
            %PF_center(PF_count)=find(mean_PF==max(mean_PF));
            PF_mean(PF_count,:)=mean_PF_withnoise;
            PF_count=PF_count+1;
            end

        end
    
    end
                   
end
end
[PF_sorted,sort_id]=sort(PF_center);
PF_mean_sorted=PF_mean(sort_id,:);

f=figure;imagesc((PF_mean_sorted'./max(PF_mean_sorted'))');
title('novel day2')
colormap jet
% f=figure;imagesc(PF_mean_sorted./max(PF_mean_sorted'));
% title('novel')

MEAN=[];

for f=1:size(n_filepaths,2)
load([temp n_filepaths{f}]);

field_id=placecell_id{f};
MEAN=[MEAN; mean_trans(placecell_id{f},:)];

end
f2n_mean=MEAN(familiar_sort,:);
% f2n_mean(remove_id,:)=[];
norm_f2n=(f2n_mean'./f_PF_max)';
norm_f2n(max(norm_f2n')>4,:)=[];

%f=figure;imagesc((f2n_mean'./f_PF_max)',[0 4]);
f=figure;imagesc((f2n_mean'./max(f2n_mean'))');
title('day1 to day2')
colormap jet