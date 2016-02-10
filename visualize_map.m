% Visualize roads on map

% load volume data
load('tdata/VolumeData_tensor.mat');

% load map data
load('tdata/centerRoads.mat')


% Direction is either 1 or 0
DIR=false(1,length(centerRoads));
for i=1:length(centerRoads) if centerRoads(i).DIRECTION==1 DIR(i)=true;end;end;

%% %---show center roads
roadspec = makesymbolspec('Line',...
    {'ADMIN_TYPE',0, 'Color','black'}, ...
    {'ADMIN_TYPE',3, 'Color','red'},...
    {'CLASS',6, 'Visible','off'},...
    {'CLASS',[1 4], 'LineWidth',2});

%% --show map
figure;
%mapshow(S,'Color',[0.4,0.4,0.4])
mapshow(centerRoads(DIR),'Color','blue','LineWidth',2);
mapshow(centerRoads(~DIR),'Color','red','LineWidth',1);
plot_google_map


%% --Visualize a random cluster of roads
dailySum=sum(data(:,:),2);
SEL=(dailySum>quantile(dailySum,0.85));


figure;
mapshow(centerRoads(DIR),'Color','blue','LineWidth',0.5);
mapshow(centerRoads(~DIR),'Color','red','LineWidth',0.1);

mapshow(centerRoads(SEL' & ~DIR ),'Color','red','LineWidth',3);
mapshow(centerRoads(SEL' & DIR ),'Color','blue','LineWidth',2);

plot_google_map
