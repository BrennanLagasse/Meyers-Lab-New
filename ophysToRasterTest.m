% File: ophysConvertSession.m
% Author: Brennan Lagasse
% Purpose: Implements the convertOphysToRaster function to convert an ophys
% session into the raster format.

% Import all ophys sessions
ophysSessions = bot.fetchSessions('ophys');

% Start by selecting only the sessions with three_session_B where the
% natural scenes stimulus is shown for part of the time
filteredSessions = ophysSessions(ophysSessions.stimulus_name == "three_session_B", :);

% Grab a test session from the filtered data
testSession = filteredSessions(1,:);

% Grab the data for that test session
testSessionData = bot.session(testSession);

% Convert the data
convertOphysToRaster(testSessionData, 300, 700, "OphysData");
