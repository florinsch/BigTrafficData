% Predict high or low volume using several models
%
%

%% Load the dataset generated with construct_sliding_dataset.m 
% load tdata/VolumeData_Window_11_norm01.mat

%% -- Configure settings here

noNeighbors = 0; % train using closest noNeighbors sensors
noModels = 4; % number of models used

models = {'H0', 'glmfit', 'net'}; % uncomment below and add here

% set filename and start diary
filename = strcat('win',num2str(winWidth),'_neighbors',num2str(noNeighbors));
diary(strcat('diary_', filename));

acc = zeros(noSensors, noModels);
cmt =  cell(noSensors, noModels);
auc = zeros(noSensors, noModels);
tti = zeros(noSensors, noModels);
allzero = zeros(1,size(tstLblBin,1));

if noNeighbors > 0
    if ~exist('EUC')
        load tdata/euclidean.mat
    end
    % make diagonal elements NaN
    EUC(logical(eye(size(EUC)))) = NaN;
    % make EUC range bettwen 0-1
    EUC = EUC / max(max(EUC));
end

% for computing auc
addpath(genpath('fastAUC'));

tStart = tic;
for i = 1:noSensors
   
    [X, y] = get_data_slice(trnDat, trnLblBin, winWidth, i);
    [Xnew, ynew] = get_data_slice(tstDat, tstLblBin, winWidth, i);
     
    % --- add closest neighbor's data -------------------------------------
    if noNeighbors > 0
        [~, idx] = sort(EUC(i,:));
        near = idx(1:noNeighbors);
%         near = sort(near);

        for j = 1:noNeighbors
            XX = get_data_slice(trnDat, trnLblBin, winWidth, near(j));
            XXnew = get_data_slice(tstDat, tstLblBin, winWidth, near(j));
            X = [X, XX];
            Xnew = [Xnew, XXnew];
        end
        clear XX XXnew;
    end
    % ---------------------------------------------------------------------
    
    if( sum(y) == numel(y) || sum(y) == 0 )
        continue;
        disp(['Sensor: ', num2str(i), ' has examples only 0 or 1']);
        disp(['Rank: ', num2str(rank(X))]);
    end
    
    % --- always zero
    [c,cm] = confusion((ynew>0.5)', allzero);
    acc(i,1) = 1 - c;
    cmt{i,1} = cm;
    auc(i,1) = fastAUC(ynew, allzero',1);
    
    % --- generalized linear
    tt = tic;
    % mdl = fitglm(X, y, 'linear', 'Distribution','binomial', 'Link','logit');
    B = glmfit(X, y, 'binomial');
    % mdl = stepwiseglm(X,y, 'constant','upper','linear', 'Distribution','binomial');
    yfitL = glmval(B, Xnew, 'logit');
    %yfitL = predict(mdl, Xnew);
    tti(i,2) = toc(tt);
    [c,cm] = confusion((ynew>0.5)', (yfitL>0.5)');
    acc(i,2) = 1 - c;
%     [xx,yy,~,aucc] = perfcurve(logical(ynew), yfitL, 'true');
%     auc(i,2) = aucc;
%     xx(i,2) = 
    auc(i,2) = fastAUC(ynew, yfitL, 1);
    cmt{i,2} = cm;
    
%     tic;
%     [BL, FitInfo] = lassoglm(X, y, 'binomial', 'NumLambda', size(X,2)+1, ...
%                    'CV', 10,  'Alpha', 1e-5, 'Options', statset('UseParallel',true));
%     indx = FitInfo.Index1SE;
%     B0 = BL(:, indx);
%     cnst = FitInfo.Intercept(indx);
%     
%     yfitLasso = glmval([cnst; B0], Xnew, 'logit');
%     tti(i,3) = toc(tt);
%     [c,cm] = confusion((ynew>0.5)', (yfitLasso>0.5)');
%     auc(i,3) = fastAUC(ynew, yfitLasso, 1);
%     acc(i,3) = 1 - c;
%     cmt{i,3} = cm;
   
    
%     % --- simple tree
%     tt = tic;
%     ctree = fitctree(X, y);
%     yfitT = predict(ctree, Xnew);
%     tti(i,3) = toc(tt);
%     [c,cm] = confusion((ynew>0.5)', (yfitT>0.5)');
%     auc(i,3) = fastAUC(ynew, yfitT, 1);
%     acc(i,3) = 1 - c;
%     cmt{i,3} = cm;
    
    
    % --- neural net
    tt = tic;
    noNeurons1 = ceil(winWidth * noNeighbors);
    net = patternnet(winWidth);
    net.trainParam.showWindow = 0;
    net = train(net, X', [y,~y]', 'useParallel','yes');
    yfitN = net(Xnew');
    tti(i,4) = toc(tt);
    [c,cm] = confusion((ynew>0.5)', (yfitN(1,:)>0.5));
    auc(i,4) = fastAUC(ynew', yfitN(1,:), 1);
    acc(i,4) = 1 - c;
    cmt{i,4} = cm;
    
    
%     % --- LDA / QDA
%     tt = tic;
%     mdlLDA = fitcdiscr(X, y);%, 'DiscrimType','quadratic');
%     yfitLDA = predict(mdlLDA, Xnew);
%     tti(i,5) = toc(tt);
%     [c,cm] = confusion((ynew>0.5)', (yfitLDA>0.5)');
%     auc(i,5) = fastAUC(ynew, yfitLDA, 1);
%     acc(i,5) = 1 - c;
%     cmt{i,5} = cm;
%     
%     % --- QDA
%     tt = tic;
%     mdlQDA = fitcdiscr(X, y, 'DiscrimType','pseudoQuadratic');
%     yfitQDA = predict(mdlQDA, Xnew);
%     tti(i,6) = toc(tt);
%     [c,cm] = confusion((ynew>0.5)', (yfitQDA>0.5)');
%     auc(i,6) = fastAUC(ynew, yfitQDA, 1);
%     acc(i,6) = 1 - c;
%     cmt{i,6} = cm;
%     
%     
%     % --- RUSBoost
%     tt = tic;
%     te = templateTree('MinLeafSize',5);
%     rusTree = fitensemble(X,y,'RUSBoost', 1000,te, 'LearnRate',0.1);
%     yfitB = predict(rusTree, Xnew);
%     tti(i,6) = toc(tt);
%     [c,cm] = confusion((ynew>0.5)', (yfitB>0.5)');
%     auc(i,6) = fastAUC(ynew, yfitB, 1);
%     acc(i,6) = 1 - c;
%     cmt{i,6} = cm;
%     
%     
%     % --- kNN
%     tt = tic;
%     knns = fitcknn(X, y, 'NumNeighbors',3 ,'Standardize',1 , 'Distance','correlation');
%     yfitK = predict(knns, Xnew);
%     tti(i,7) = toc(tt);
%     [c,cm] = confusion((ynew>0.5)', (yfitK>0.5)');
%     auc(i,7) = fastAUC(ynew, yfitK,1);
%     acc(i,7) = 1 - c;
%     cmt{i,7} = cm;
%     
% 
%     % --- SVM RBF
%     tt = tic;
%     mdlSVM = fitcsvm(X, y, 'KernelFunction','RBF', ...
%         'KernelScale','auto', 'Standardize',true, 'IterationLimit', 1e4);
%     [yfitS, score] = predict(mdlSVM, Xnew);
%     tti(i,8) = toc(tt);
%     [c,cm] = confusion((ynew>0.5)', (yfitS>0.5)');
%     auc(i,8) = fastAUC(ynew, yfitS, 1);
%     acc(i,8) = 1 - c;
%     cmt{i,8} = cm;
%     
%     
%     % --- Naive Bayes
%     tt = tic;
%     mdlNB = fitcnb(X, y);
%     [yfitNB, score] = predict(mdlNB, Xnew);
%     tti(i,9) = toc(tt);
%     [c,cm] = confusion((ynew>0.5)', (yfitNB>0.5)');
%     auc(i,9) = fastAUC(ynew, yfitNB, 1);
%     acc(i,9) = 1 - c;
%     cmt{i,9} = cm;
    

    fprintf('\n #Accuracies:\n');
    fprintf('%f, ', acc(i,:));
    
    fprintf('\n #Timing:\n');
    fprintf('%f, ', tti(i,:));
    fprintf('\n');
    
    timet = sum(tti(i,:));
        
    fprintf('\n #==============================================');
    fprintf('\n # %4.2f percent | All models took %02d mins %05.2fs ', ...
        i/noSensors*100, floor(timet/60), rem(timet,60));
    fprintf('\n #==============================================\n');
end
fprintf('\n### Finished in ');
[hrs, scs, mns] = sec2hms(toc(tStart));
fprintf('%02d hours %02d mins and %05.2f secs \n', hrs, scs, mns);
% -------------------------------------------------------------------------

save(strcat(filename, '.mat'), 'acc*', 'auc*', 'cmt*', 'tti*', 'i', 'models');
fprintf('#Finished saving: %s', filename);
diary off;

