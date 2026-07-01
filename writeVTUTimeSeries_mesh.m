function writeVTUTimeSeries_mesh(baseName, mesh, pointData, cellData, time)
% writeVTUTimeSeries_mesh
% Supports:
%   point scalar : (nNodes x nSteps)
%   point vector : (nNodes x nComp x nSteps)
%   cell data    : (nElem  x nComp x nSteps)

%% ------------------ sanity ------------------
time = time(:);
nSteps = numel(time);

assert(all(diff(time) > 0), ...
    'time must be strictly increasing for ParaView');

vtuFiles = cell(nSteps,1);

%% ------------------ loop over steps ------------------
for k = 1:nSteps

    %% --- extract nodal data ---
    pd_k = struct();
    fn = fieldnames(pointData);

    for i = 1:numel(fn)
        data = pointData.(fn{i});

        if ndims(data) == 2
            % (nNodes × nSteps) → scalar
            assert(size(data,2) == nSteps, ...
                'PointData.%s has wrong time dimension', fn{i});

            pd_k.(fn{i}) = data(:,k);

        elseif ndims(data) == 3
            % (nNodes × nComp × nSteps) → vector/tensor
            assert(size(data,3) == nSteps, ...
                'PointData.%s has wrong time dimension', fn{i});

            pd_k.(fn{i}) = data(:,:,k);

        else
            error('PointData.%s has invalid dimensions', fn{i});
        end
    end

    %% --- extract cell data ---
    cd_k = struct();
    fn = fieldnames(cellData);

    for i = 1:numel(fn)
        data = cellData.(fn{i});

        assert(ndims(data) == 3, ...
            'CellData.%s must be (nElem x nComp x nSteps)', fn{i});

        assert(size(data,3) == nSteps, ...
            'CellData.%s has wrong time dimension', fn{i});

        cd_k.(fn{i}) = data(:,:,k);
    end

    %% --- filename ---
    fname = sprintf('%s_%04d.vtu', baseName, k);
    vtuFiles{k} = fname;

    %% --- write VTU ---
    writeVTU_mesh(fname, mesh, pd_k, cd_k);
end

%% ------------------ write PVD ------------------
writePVD([baseName '.pvd'], vtuFiles, time);

end