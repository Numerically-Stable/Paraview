function writePVD(filename, vtuFiles, timeValues)
% writePVD  Write ParaView PVD time collection file
%
% INPUTS:
%   filename   : e.g. 'results.pvd'
%   vtuFiles   : cell array of VTU filenames (can include paths)
%   timeValues : array of time values (same length)

%% ------------------ checks ------------------
assert(iscell(vtuFiles), 'vtuFiles must be a cell array');
assert(numel(vtuFiles) == numel(timeValues), ...
    'vtuFiles and timeValues must have same length');

timeValues = timeValues(:); % ensure column

%% ------------------ open file ------------------
fid = fopen(filename,'w');
assert(fid > 0, 'Cannot open PVD file');

%% ------------------ header ------------------
fprintf(fid,'<?xml version="1.0"?>\n');
fprintf(fid,'<VTKFile type="Collection" version="0.1" byte_order="LittleEndian">\n');
fprintf(fid,'  <Collection>\n');

%% ------------------ datasets ------------------
for i = 1:numel(vtuFiles)

    % ✅ FIX: strip any folder path → keep only filename
    [~, name, ext] = fileparts(vtuFiles{i});
    fname = [name ext];

    fprintf(fid,'    <DataSet timestep="%.16g" group="" part="0" file="%s"/>\n', ...
        timeValues(i), fname);
end

%% ------------------ footer ------------------
fprintf(fid,'  </Collection>\n');
fprintf(fid,'</VTKFile>\n');

fclose(fid);

end