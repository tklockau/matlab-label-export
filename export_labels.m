%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab script for converting Mathworks Video Labeler bounding boxes of %
% image sequences into the YOLO-format                                   %
%                                                                        %
% AUTHOR:           Tobias Klockau                                       %
% DATE:             June 30th 2021                                       %
% MATLAB VERSION:   R2021a                                               %
% GITHUB:           https://github.com/tklockau/matlab-label-export      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Receives and transforms the label data from the gTrth variable
data = timetable2table(gTruth.LabelData);
data = table2array(removevars(data, 'Time'));

imgs_dir = uigetdir('F:\fire_png\');
imgs_file_data = dir(fullfile(imgs_dir, '*.png'));
imgs_file_names = transpose(extractfield(imgs_file_data, 'name'));

% Receives the image pixel size of the first image
[y_img, x_img, c] = size(imread(strcat(imgs_dir, '\', imgs_file_names{1})));

% Checks if the bounding boxes match the number of PNG images in the folder
% and displays a warning if not
if length(imgs_file_names) == height(data)
    
    % For every PNG-image in the folder
    for img = 1:length(imgs_file_names)
        
        % Generates the .txt filename
        label_file_name = strcat(                                       ...
            imgs_dir,                                                   ...
            '\',                                                        ...
            imgs_file_names{img}(1:strlength(imgs_file_names{img})-4),  ...
            '.txt'                                                      ...
        );
        
        % Creates the file
        label_file = fopen(label_file_name, 'wt');
        
        % For every class in the data
        for class = 1:size(data, 2)
            
            % For every class instance
            for bbox = 1:size(data{img, class}, 1)
                
                % Calculates the normalized bbox parameters
                bbox_width = data{img, class}(bbox, 3) / x_img;
                bbox_height = data{img, class}(bbox, 4) / y_img;
                bbox_x = (data{img, class}(bbox, 1) + data{img, class}(bbox, 3) / 2) / x_img;
                bbox_y = (data{img, class}(bbox, 2) + data{img, class}(bbox, 4) / 2) / y_img;
                
                % Writes the bounding box into the file
                fprintf(label_file, '%1$i %2$.16f %3$.16f %4$.16f %5$.16f\n', class-1, bbox_x, bbox_y, bbox_width, bbox_height);
            end
        end
        
        % Closes the file
        fclose(label_file);
    end
    
else
    uiwait(warndlg('The annotation data and the images in the folder do not Match!'));
end