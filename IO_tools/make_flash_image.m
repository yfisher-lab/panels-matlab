function SD = make_flash_image(file_list)
% this is the gui-friendly version of the file prepare_flash_image
%% file_list is a structure with fields FileName and PathName

block_size = 512; % all data must be in units of block size
num_patterns = length(file_list);
Header_block = zeros(1, block_size);
SD.num_patterns = num_patterns;

%clean the temp folder
load('Pcontrol_paths.mat');
%dos(['del /Q ' temp_path '\*.pat']); % SS
dos(['del /Q "' temp_path '\*.pat"']); % SS

for j = 1:num_patterns
   
    % YF 2022: this update is intended to fix a bug where only 1 pattern can be
    % loaded if the variable was named pattern (expected old naming
    % convention) or panel_pattern (expected new naming convention)
    % now this code will now accept any name of the pattern variable as long as
    % there is one and only one variable in the loaded .mat file
    loadedPattern= load([file_list(j).PathName '\' file_list(j).FileName]); 
    fieldName = fieldnames(loadedPattern);

    if(length(fieldName)== 1) % check that loadedPattern has only one field
        panel_pattern = loadedPattern.(fieldName{1}); % update variable to be named panel_pattern
    else
        error(['The current Pattern.mat file number:' num2str(j) 'contained more than one variable, only one variable can be accepted.'])
    end
 
    % determine if row_compression is on
    row_compression(j) = 0;
    if isfield(panel_pattern, 'row_compression') % for backward compatibility
        if (panel_pattern.row_compression)
            row_compression(j) = 1;
        end
    end
    
    if (row_compression(j))
        current_frame_size(j) = panel_pattern.num_panels*panel_pattern.gs_val;
    else
        current_frame_size(j) = panel_pattern.num_panels*panel_pattern.gs_val*8;
    end
    
    blocks_per_frame(j) = ceil(current_frame_size(j)/block_size);
    current_num_frames(j) = panel_pattern.x_num*panel_pattern.y_num;
    num_blocks_needed(j) = blocks_per_frame(j)*current_num_frames(j);
    
    if (row_compression(j)) % hack - append 10 to gs_val to let controller know that it is a row_compressed pattern w/o adding more to header block
        Header_block(1:8) = [dec2char(panel_pattern.x_num,2), dec2char(panel_pattern.y_num,2), panel_pattern.num_panels, 10 + panel_pattern.gs_val, dec2char(current_frame_size(j),2)];
    else
        Header_block(1:8) = [dec2char(panel_pattern.x_num,2), dec2char(panel_pattern.y_num,2), panel_pattern.num_panels, panel_pattern.gs_val, dec2char(current_frame_size(j),2)];
    end
    % set up SD structure with pattern info
    SD.x_num(j) = panel_pattern.x_num;
    SD.y_num(j) = panel_pattern.y_num;
    SD.num_panels(j) = panel_pattern.num_panels;
    SD.gs_val(j) = panel_pattern.gs_val; % unclear if we should change this to reflect 11, 12, 13 hack
    SD.frame_size(j) = current_frame_size(j);
    SD.pattNames{j} = file_list(j).FileName;
    
    Pattern_Data = zeros(1, num_blocks_needed(j)*block_size);
    
    block_indexer = 1;  % points to the first block
    % now write all of the frame info
    for i = 1:current_num_frames(j)
        sd_start_address = (block_indexer - 1)*block_size + 1;
        sd_end_address = sd_start_address + current_frame_size(j) - 1;    
        % always forced to start frame at a block boundary
        pat_start_address = (i - 1)*current_frame_size(j) + 1;
        pat_end_address = pat_start_address + current_frame_size(j) - 1;    
        Pattern_Data(sd_start_address:sd_end_address) = panel_pattern.data(pat_start_address:pat_end_address);
        block_indexer = block_indexer + blocks_per_frame(j);
    end    

    Data_to_write = [Header_block Pattern_Data];
    
    
    switch length(num2str(j))
        case 1
            patFileName = ['pat000' num2str(j) '.pat'];
        case 2
            patFileName = ['pat00', num2str(j) '.pat'];
        case 3
            patFileName = ['pat0', num2str(j) '.pat'];
        case 4
            patFileName = ['pat', num2str(j) '.pat'];
        otherwise
            disp('The pattern number is too big.');
    end
    
    fid = fopen([temp_path '\' patFileName] , 'w');
    fwrite(fid, Data_to_write(:),'uchar');
    fclose(fid);
    disp([num2str(j) ' of ' num2str(num_patterns) ' patterns written to temporary folder ', patFileName, ', of size ' num2str(size(Data_to_write,2)) ' bytes']);
end

