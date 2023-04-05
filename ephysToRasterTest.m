% File: ephysToRasterTest.m
% Author: Dr. Ethan Meyers
% Purpose: Converts a single session from an ephys experiment into raster

% session number for the natural scenes to convert
% should be a number from 1 to 58 since there are 58 ephys sessions - but
% only 32 of these are brain observator 1.1 sessions that have natural
% scene stimuli

% valid brain observatory session numbers are:   1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20
% 21    22    23    24    25    26    27    33    42    45    46    47

session_number_to_convert = 11 %to do: 3, 18    %complete: 11, 1, 2

% add the BOT to the path
BOTdirName = '/vast/palmer/home.grace/em939/research/brain_observatory_analysis/github_BOT/Brain-Observatory-Toolbox' %'Brain-Observatory-Toolbox';
addpath(BOTdirName);

% create a directory to store raster data
mkdir("EphysData");

% prepare for the tutorial
%warning('off');

% add the path to the NDT so add_ndt_paths_and_init_rand_generator can be called
%toolboxBaseDirName = 'ndt.1.0.4/';
%addpath(toolboxBaseDirName);
%add_ndt_paths_and_init_rand_generator();

% obtain information about all sessions in the ephys dataset
allSessionInfo = bot.fetchSessions('ephys')

if (allSessionInfo.session_type(session_number_to_convert) ~= "brain_observatory_1.1")

    session_nums = 1:58; 
    valid_session_nums = session_nums(allSessionInfo.session_type == "brain_observatory_1.1")
    
    error(['session_number_to_convert ' num2str(session_number_to_convert) ' is not a brain_observatory_1.1 session so that code will likely crash'])

end

%% Obtain the session to observe


% obtain a single experimental session
oneEphysSessionData = bot.session(allSessionInfo(session_number_to_convert, :))

%% Review the session


oneEphysSessionData.stimulus_names

presentations = oneEphysSessionData.stimulus_presentations 

%% 


unitsTable = oneEphysSessionData.units;
head(unitsTable)

% where the raster files should be saved
rasterDirectoryBaseName = 'EphysData';

% call the conversion function
%convertEphysToRaster(oneEphysSessionData, 'natural_scenes', 300, 700, unitsVISp, rasterDirectoryBaseName);
convertEphysToRaster(oneEphysSessionData, 'natural_scenes', 300, 700, [], rasterDirectoryBaseName);