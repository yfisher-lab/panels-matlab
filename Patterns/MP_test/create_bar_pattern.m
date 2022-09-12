% Simple Bar stim

% 11 x 2 arena

npix = 8;
pattern = struct();
pattern.x_num = 12*npix; % 12 panels (1 virtual), 8 pixels per panels
pattern.y_num = 1; % no y control
pattern.num_panels = 22;
pattern.gs_val = 1; % 1 bit patterns
pattern.Pats = zeros(npix*2, 11*npix, 12*npix, 1);

for i = 1:10*npix
    pattern.Pats(:, i:i+8, i, 1) = 1;
end

for i = 10*npix:2:12*npix
    k = i-10*npix;
    pattern.Pats(:, 10*npix + k/2:end, i:i+1, 1) = 1;
    
    
    j = mod(i+8,11*npix);
    pattern.Pats(:, 1:j/2, i:i+1, 1) = 1;
%     figure; imagesc(pattern.Pats(:,:,i,:));
    
    
    
end

pattern.Panel_map = [22 21 20 19 18 17 16 15 14 13 12;
                     11 10 9 8 7 6 5 4 3 2 1];

pattern.BitMapIndex = process_panel_map(pattern);

pattern.data = Make_pattern_vector(pattern);

dir_name = 'C:\Users\fisherlab\Documents\GitHub\panels-matlab\Patterns\MP_test';
filename = [dir_name '\Pattern_bar_example'];

save(filename, 'pattern');



