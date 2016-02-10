% MATLAB uses a system commonly called "copy-on-write" to avoid making 
% a copy of the input argument inside the function workspace until 
% or unless you modify the input argument. 
% If you do not modify the input argument, MATLAB will avoid making a copy. 
% (equivalent to pass by reference)
% For instance, in this code:
%       function y = functionOfLargeMatrix(x)
%        y = x(1);
% MATLAB will not make a copy of the input in the workspace of 
% functionOfLargeMatrix, as x is not being changed in that function. 
% If on the other hand, you called this function:
%       function y = functionOfLargeMatrix2(x)
%       x(2) = 2;
%       y = x(1);
% then x is being modified inside the workspace of functionOfLargeMatrix2,
% and so a copy must be made.

%
% Returns the data slice in the format created by the construct_sliding_dataset.m
%
% Input parameters:
%   train - the training data
%   test - the testing data
%   winWidth - the size of the sliding window used to slice
%   sensorIdx - the sensor for which the data is requested
%
% Output:
%   X - the input data
%   Y - the target data
%

function [X, Y] = get_data_slice(train, target, winWidth, sensorIdx)

i2 = sensorIdx*(winWidth-1);
i1 = i2 - (winWidth-2);
ii = i1:i2;

% extract data train
X = train(:,ii);
Y = target(:,sensorIdx);

% remove zero-valued entries
idxzero = sum(X,2)==0;
X(idxzero,:) = [];
Y(idxzero,:) = [];

% remove entries with nans
idxnan = isnan(sum(X,2));
X(idxnan,:) = [];
Y(idxnan,:) = [];

end
