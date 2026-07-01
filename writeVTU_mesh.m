function writeVTU_mesh(filename, mesh, pointData, cellData)

%% ------------------ geometry ------------------
nodes = mesh.nodes.coord;
conn  = mesh.elem.conn;

nNodes = mesh.nodes.n;
nElem  = mesh.elem.n;

if size(nodes,2) == 2
    nodes = [nodes, zeros(nNodes,1)];
end

%% ------------------ VTK cell type ------------------
vtkCellID = vtkCellTypeFromElemType(mesh.meta.elemType);

%% ------------------ open file ------------------
fid = fopen(filename,'w');
assert(fid > 0, 'Cannot open VTU file');

fprintf(fid,'<VTKFile type="UnstructuredGrid" version="0.1" byte_order="LittleEndian">\n');
fprintf(fid,'<UnstructuredGrid>\n');
fprintf(fid,'<Piece NumberOfPoints="%d" NumberOfCells="%d">\n', nNodes, nElem);

%% ------------------ Points ------------------
fprintf(fid,'<Points>\n');
fprintf(fid,'<DataArray type="Float64" NumberOfComponents="3" format="ascii">\n');

for i = 1:nNodes
    fprintf(fid,'%g %g %g\n', nodes(i,:));
end

fprintf(fid,'</DataArray>\n');
fprintf(fid,'</Points>\n');

%% ------------------ Cells ------------------
conn0   = conn - 1;
offsets = (1:nElem) * size(conn,2);
types   = vtkCellID * ones(nElem,1);

fprintf(fid,'<Cells>\n');

fprintf(fid,'<DataArray type="Int32" Name="connectivity" format="ascii">\n');
fprintf(fid,'%d ', conn0');
fprintf(fid,'\n</DataArray>\n');

fprintf(fid,'<DataArray type="Int32" Name="offsets" format="ascii">\n');
fprintf(fid,'%d ', offsets);
fprintf(fid,'\n</DataArray>\n');

fprintf(fid,'<DataArray type="UInt8" Name="types" format="ascii">\n');
fprintf(fid,'%d ', types);
fprintf(fid,'\n</DataArray>\n');

fprintf(fid,'</Cells>\n');

%% ------------------ PointData ------------------
if nargin >= 3 && ~isempty(pointData)
    names = fieldnames(pointData);
    fprintf(fid,'<PointData>\n');

    for i = 1:numel(names)
        data = pointData.(names{i});

        if isvector(data)
            data = data(:);
        end

        nComp = size(data,2);

        fprintf(fid,'<DataArray type="Float64" Name="%s" NumberOfComponents="%d" format="ascii">\n', ...
                names{i}, nComp);

        % ✅ CORRECT ordering (point-wise)
        for p = 1:size(data,1)
            fprintf(fid,'%g ', data(p,:));
        end

        fprintf(fid,'\n</DataArray>\n');
    end

    fprintf(fid,'</PointData>\n');
end

%% ------------------ CellData ------------------
if nargin >= 4 && ~isempty(cellData)
    names = fieldnames(cellData);
    fprintf(fid,'<CellData>\n');

    for i = 1:numel(names)
        data = cellData.(names{i});

        if isvector(data)
            data = data(:);
        end

        nComp = size(data,2);

        fprintf(fid,'<DataArray type="Float64" Name="%s" NumberOfComponents="%d" format="ascii">\n', ...
                names{i}, nComp);

        % ✅ CORRECT ordering
        for e = 1:size(data,1)
            fprintf(fid,'%g ', data(e,:));
        end

        fprintf(fid,'\n</DataArray>\n');
    end

    fprintf(fid,'</CellData>\n');
end

%% ------------------ close ------------------
fprintf(fid,'</Piece>\n</UnstructuredGrid>\n</VTKFile>\n');
fclose(fid);

end