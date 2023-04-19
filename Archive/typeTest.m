% File: ophysConvertSession.m
% Author: Brennan Lagasse
% Purpose: Implements the convertOphysToRaster function to convert an ophys
% session into the raster format.

% Import all ophys sessions
ophysSessions = bot.fetchSessions('ophys');

% Get the natural scenes ones
filteredSessions = ophysSessions(ophysSessions.stimulus_name == "three_session_B", :);

% Import all ephys sessions
ephysSessions = bot.fetchSessions('ephys')

filteredSessions = ephysSessions(ephysSessions.stimulus_name == "three_session_B", :);
