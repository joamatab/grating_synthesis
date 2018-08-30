% authors: bohan
% 
% script for testing the latest synthesis pipeline
% generate final design

clear; close all;

% dependencies
addpath(['..' filesep 'main']);                                             % main code
addpath(['..' filesep '45RFSOI']);                                          % 45rf functions

% synthesis object to load
filename = 'synth_obj_2018_08_24_17_15_00_lambda1300_optangle-20_box150_NO_GC.mat';
filepath = 'C:\Users\bz\Google Drive\research\popovic group\projects\grating synthesis\data\2018 02 19 gaussian grating synth\2018 08 28 15 08pm 5nm disc fixed';

% load synth_obj
load( [ filepath filesep filename ] );

% synthesize final design
MFD             = 10 * 1e3;                                                         % in nm
input_wg_type   = 'bottom';
synth_obj       = synth_obj.generate_final_design_gaussian( MFD, input_wg_type );