function vtkCellID = vtkCellTypeFromElemType(elemType)
% vtkCellTypeFromElemType
% Map solver element types to VTK cell IDs

switch lower(elemType)
    case {'q4','quad4'}
        vtkCellID = 9;    % VTK_QUAD
    case {'t3','tri3'}
        vtkCellID = 5;    % VTK_TRIANGLE
    case {'tet4'}
        vtkCellID = 10;   % VTK_TETRA
    case {'h8'}
        vtkCellID = 12;   % VTK_HEXAHEDRON
    otherwise
        error('Unsupported element type for VTK: %s', elemType);
end
end
