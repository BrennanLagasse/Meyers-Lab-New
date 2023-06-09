            % File: convertOphysToRaster.m
% Author: Brennan Lagasse, uses code from convertEphysToRaster from Dr. Ethan
% Meyers
% Purpose: Converts data from the Allen Institue Two Photon Imaging experiment
% into raster format
% Date: 4/5/2023

% Does not currently support different stimuli types, only natural scenes

function convertOphysToRaster(ophysSession, ...
    baselinePeriodLength, stimulusPeriodLength, saveDirectoryBaseName)

% convertOphysToRaster - FUNCTION Converts data to NDT "raster format" 
%
% Usage: convertOphysToRaster(ephysSession, stimulusSetName, ...
%    baselinePeriodLength, stimulusPeriodLength <, unitsToUse, saveDirectoryBaseName>) 
%
% This function converts dff data for the natural scenes stimuli set into
% "raster format" that is used by the Neural Decoding Toolbox (NDT)
%
% The arguments to this function are:
%
% ophysSession: A session object from a single session that contains the data to be converted
%
% baselinePeriodLength: the amount of time to include before each stimulus presentation onset
%
% stimulusPeriodLength: the amount of time to include after each stimulus presentation onset
%
% saveDirectoryBaseName: The name of a directory where the raster data
% files are saved. Defaults to current directory

    % First, find/create the directory to save the data
    
    if nargin < 4
        saveDirectoryBaseName = pwd;
    end    

    saveDirectoryName = fullfile(saveDirectoryBaseName, ['session_' num2str(ophysSession.id)], "natural_scenes", '');

    if ~exist(saveDirectoryName, "dir")
        mkdir(saveDirectoryName);
    end

    % Get the dff values and measurement times
    session_dff = ophysSession.fluorescence_traces_dff;
    session_timestamps = ophysSession.fluorescence_timestamps;
    
    % Get the cell ids
    session_cell_id = ophysSession.cell_specimen_ids;

    % Get the stimulus presentation 
    natural_scenes_stimulus_times = ophysSession.getStimulusTable("natural_scenes");

    % Create an array to store all the data. Initialize with all zero
    % values. The array will automatically resize and zero any new values
    % if there are more observations in one time period than in another
    raster_data = zeros(width(session_dff), 1);

    % Iterate through all the cells

    for c = 1:width(session_dff)

        disp("Checking element " + c + " of " + width(session_dff))
    
        cell_dff = session_dff(:,c);
    
        % Iterate through all stimuli
        for stimulus = 1:height(natural_scenes_stimulus_times)
    
            % Get the time range around the presentation
            presentation_time = natural_scenes_stimulus_times.start_time(stimulus);
    
            raster_start = presentation_time - seconds(baselinePeriodLength/1000);
            raster_end = presentation_time + seconds(stimulusPeriodLength/1000);
        
            % Get dff values from that timerange
            dff_values = cell_dff(session_timestamps >= raster_start & ...
                session_timestamps <= raster_end);
    
            % Save the values for that cell and stimulus
            raster_data(stimulus, 1:length(dff_values)) = dff_values;
        end
    
        % Create the raster labels struct
        % I only handle natural scenes for now, and more info should likely be
        % added later
                   
        raster_labels.natural_scene_stimulus_id = natural_scenes_stimulus_times.frame;
    
        % Create the raster_site_info struct
        % Not all information is imported just yet. Fix this later

        stimulus_info_names = fieldnames(ophysSession.info);

        for iInfo = 1:(length(stimulus_info_names))
    
            %eval(['raster_site_info.' stimulus_info_names{iInfo} ' = table2array(raster_site_info.' stimulus_info_names{iInfo} ');']);
            curr_site_info_is_a_logical = eval(['islogical(ophysSession.info.' stimulus_info_names{iInfo} ');']);
            curr_site_info_is_a_number = eval(['isnumeric(ophysSession.info.' stimulus_info_names{iInfo} ');']);
            curr_site_info_is_a_string = eval(['isstring(ophysSession.info.' stimulus_info_names{iInfo} ');']);
            curr_site_info_is_a_datetime = eval(['isdatetime(ophysSession.info.' stimulus_info_names{iInfo} ');']);
            curr_site_info_is_a_categorical = eval(['iscategorical(ophysSession.info.' stimulus_info_names{iInfo} ');']);
            curr_site_info_is_a_struct = eval(['isstruct(ophysSession.info.' stimulus_info_names{iInfo} ');']);
            curr_site_info_is_a_table = eval(['istable(ophysSession.info.' stimulus_info_names{iInfo} ');']);

            % No changes needed
            if (curr_site_info_is_a_logical || curr_site_info_is_a_number)
                eval(['raster_site_info.' stimulus_info_names{iInfo} ' = ophysSession.info.' stimulus_info_names{iInfo} ';']);
            end
            
            % convert to chars which works better with the NDT
            if (curr_site_info_is_a_string || curr_site_info_is_a_datetime || curr_site_info_is_a_categorical)
                eval(['raster_site_info.' stimulus_info_names{iInfo} ' = char(ophysSession.info.' stimulus_info_names{iInfo} ');']);
            end
        
            % Convert structs
            if (curr_site_info_is_a_struct || curr_site_info_is_a_table)
                eval(['raster_site_info.' stimulus_info_names{iInfo} ' = char("Not imported yet");']);
            end
           
        end
    
        % Write all of the data to a matlab file
        saveRasterFormatFileName = fullfile(saveDirectoryName, [num2str(ophysSession.cell_specimen_ids(c)) '.mat']);
        save(saveRasterFormatFileName, 'raster_data', 'raster_labels', 'raster_site_info');
    
    end
end
    
    
