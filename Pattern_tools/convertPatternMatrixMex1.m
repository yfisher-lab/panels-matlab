function patVectorMatrix = convertPatternMatrixMex1(patMat)

% function patVectorMatrix = convertPatternMatrix(patMat)
%
% This function converts the 3D pattern matrix generated by
% createXXXProtocol functions into a vector format that can be dumped to
% the controller.
%
% INPUT
% patMat - 32X96XN matrix (32X96 is arena default and can be changed)
%
% OUTPUT
% patVectorMatrix -
%
% For now function works with a specific panelmap and assumes GS Level 3


% process panel map
pattern.Panel_map = [12 8 4 11 7 3 10 6 2  9 5 1; 24 20 16 23 19 15 22 18 14 21 17 13; 36 32 28 35 31 27 34 30 26 33 29 25; 48 44 40 47 43 39 46 42 38 45 41 37];

BitMapIndex = process_panel_map(pattern);

%whether the current pattern is row compression or not
if size(patMat,1)<8
    pattern.row_compression = 1;
else
    pattern.row_compression = 0;
end

% What is the gray scale of the current pattern
maxPatMat = max(patMat(:));
if maxPatMat <= 1
    pattern.gs_level = 1;
elseif maxPatMat <= 3
    pattern.gs_level = 2;
elseif maxPatMat <= 7
    pattern.gs_level = 3;
elseif matPatMat <= 15
    pattern.gs_level = 4;
else
    error('Pattern data are wrong, the maximum value is bigger than expected value.');
end


%convert the current pattern data
patVectorMatrix = zeros(1152, size(patMat,3));

for ii=1:size(patMat,3)
    patVectorMatrix(:, ii) = make_frame_vector_mex(patMat(:,:,ii), BitMapIndex, pattern.row_compression, pattern.gs_level);
end

end
