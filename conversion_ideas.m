% Test with info formatting
stimulus_info_names = fieldnames(testSessionData.info)





for iInfo = 1:(length(stimulus_info_names))

    %eval(['raster_site_info.' stimulus_info_names{iInfo} ' = table2array(raster_site_info.' stimulus_info_names{iInfo} ');']);
    curr_site_info_is_a_string = eval(['isstring(raster_site_info.' stimulus_info_names{iInfo} ');']);
    curr_site_info_is_a_datetime = eval(['isdatetime(raster_site_info.' stimulus_info_names{iInfo} ');']);
    curr_site_info_is_a_categorical = eval(['iscategorical(raster_site_info.' stimulus_info_names{iInfo} ');']);
    curr_site_info_is_a_struct = eval(['isstruct(raster_site_info.' stimulus_info_names{iInfo} ');']);
    curr_site_info_is_a_table = eval(['istable(raster_site_info.' stimulus_info_names{iInfo} ');']);
    
    % convert to chars which works better with the NDT
    if (curr_site_info_is_a_string || curr_site_info_is_a_datetime || curr_site_info_is_a_categorical)
        eval(['raster_site_info.' stimulus_info_names{iInfo} ' = char(raster_site_info.' stimulus_info_names{iInfo} ');']);
    end

    % Convert structs
    if (curr_site_info_is_a_struct || curr_site_info_is_a_table)
        eval(['raster_site_info.' stimulus_info_names{iInfo} ' = "Not imported yet";']);
    end
   
end

% formatStruct(raster_site_info)

function formatStruct(s)
    names = fieldnames(s);

    for i = 1:length(names)

        names{i}

        curr_site_info_is_table = eval(['istable(s.' names{i} ') > 1;']);

        if (curr_site_info_is_table)
            eval(['s.' names{i} ' = "not yet processed";']);
        else
            curr_site_info_is_a_string = eval(['isstring(s.' names{i} ');']);
            curr_site_info_is_a_datetime = eval(['isdatetime(s.' names{i} ');']);
            curr_site_info_is_a_categorical = eval(['iscategorical(s.' names{i} ');']);
            curr_site_info_is_a_struct = eval(['isstruct(s.' names{i} ');']);
            
            % convert to chars which works better with the NDT
    
            if (curr_site_info_is_a_string || curr_site_info_is_a_datetime || curr_site_info_is_a_categorical)
                eval(['s.' names{i} ' = char(s.' names{i} ');']);
            elseif (curr_site_info_is_a_struct && eval(['height(s.' names{i} ') > 1;']) && eval(['width(s.' names{i} ') > 1;']))
    
                "Expanding"
    
                names{i}
    
                eval(['formatStruct(s.' names{i} ');']);
            elseif curr_site_info_is_a_struct
                eval(['s.' names{i} ' = "not yet processed";']);
            end
        end
    end
end
