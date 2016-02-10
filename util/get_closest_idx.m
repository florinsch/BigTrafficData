% get_closest_idx
%
% Returns the Id of the closest sensor
% Input parameters:
%   - distMat - the distance matrix
%   - noNeighbors - the number of k nearest neighbors
%   - winWidth  - the width of the window used to slice
%   - sensorIdx - the query ID of the sensor
%   

function idx = get_closest_idx(distMat, noNeighbors, winWidth, sensorIdx)
    % get indices for the closest roads from distMat distance matrix
    [~, ids] = sort(distMat(sensorIdx,:));
    near = ids(1:noNeighbors);
    near = repmat(near, winWidth-1, 1);
    for k = 2:winWidth-1
        near(k,:) = near(k,:) + k-1;
    end
    idx = sort(near(:))'; 
end
