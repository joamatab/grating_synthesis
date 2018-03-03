% authors: bohan

% Plot transmitted power dependence of a unit cell

clear; close all;

% dependencies
addpath(['..' filesep 'main']);

% initial settings
disc        = 10;
units       = 'nm';
lambda      = 1550;
index_clad  = 1.0;
domain      = [ 4000, 800 ];

% directory to save data to
% unused for this script
data_dir        = '';
data_filename   = '';
data_notes      = '';

% number of parallel workers, unused
n_workers = 0;

% desired angle
optimal_angle = 15;

% coupling up/down
coupling_direction = 'down';

% make object
Q = c_synthGrating( 'discretization',   disc,       ...
                    'units',            units,      ...
                    'lambda',           lambda,     ...
                    'background_index', index_clad, ...
                    'domain_size',      domain,     ...
                    'optimal_angle',    optimal_angle,      ...
                    'coupling_direction', coupling_direction, ...
                    'data_directory',   data_dir, ...
                    'data_filename',    data_filename, ...
                    'data_notes',       data_notes, ...
                    'data_mode',        'new', ...
                    'num_par_workers',  n_workers ...
                     );
%                     'h_makeGratingCell', @f_makeGratingCell_45RFSOI ...


% start from waveguide mode and iterate towards the fill factor geometry i want to try
% make waveguide
waveguide = Q.h_makeGratingCell( Q.convertObjToStruct(), Q.discretization, 1.0, 1.0, 0.0 );

% run waveguide simulation
% sim settings
guess_n     = 0.7 * max( waveguide.N(:) );                                      % guess index. I wonder if there's a better guessk for this?
guessk      = guess_n * 2*pi/Q.lambda;                                          % units rad/'units'
num_modes   = 5;
BC          = 0;                                                                % 0 = PEC
pml_options = [0, 200, 20, 2];                                                  % now that I think about it... there's no reason for the user to set the pml options
% run sim
waveguide   = waveguide.runSimulation( num_modes, BC, pml_options, guessk );

% grab waveguide k
waveguide_k = waveguide.k;                                                      % units of rad/'units'     
guessk      = waveguide_k;

% DEBUG plot stuff
waveguide.plotEz_w_edges();

% calculate analytical period which would approximately phase
% match to desired output angle
k0      = Q.background_index * ( 2*pi/Q.lambda );
kx      = k0 * sin( (pi/180) * Q.optimal_angle );
period  = 2*pi/(waveguide_k- kx);                                               % units of 'units'

% snap period to discretization
guess_period    = Q.discretization * round(period/Q.discretization);


% now iterate towards the desired fill factor
des_ff  = 0.7;                                                                  % lets make the structure symmetric
ffs     = linspace( 0.95, des_ff, 10 );


% simulation settings
num_modes   = 1;
BC          = 0;                                                                % 0 = PEC
pml_options = [1, 200, 20, 2]; 


tic;
for ii = 1:length(ffs)
    % for each fill factor
    
    fprintf('fill factor loop %i of %i...\n', ii, length(ffs) );

    % pick some periods to sweep
    sweep_periods = guess_period : disc : guess_period*1.05;
    
    % init saving variables
    angles          = zeros( size(sweep_periods) );
    k_vs_period     = zeros( size(sweep_periods) );
    GC_vs_period    = cell( size(sweep_periods) );
    
    
    for i_period = 1:length(sweep_periods)
       
        % make grating coupler object
    	GC = Q.h_makeGratingCell( Q.convertObjToStruct(), sweep_periods(i_period), ffs(ii), ffs(ii), 0.0 );
        
        % run sim
        GC = GC.runSimulation( num_modes, BC, pml_options, guessk );

        % save angle
        if strcmp( Q.coupling_direction, 'up' )
            % coupling direction is upwards
            angles( i_period ) = GC.max_angle_up;
        else
            % coupling direction is downwards
            angles( i_period ) = GC.max_angle_down;
        end

        % update GC list
        GC_vs_period{i_period} = GC;

        % update k (units of rad/'units')
        k_vs_period(i_period)   = GC.k;
        guessk                  = GC.k;
        
    end
    
    % pick best period
    [angle_error, indx_best_period] = min( abs( Q.optimal_angle - angles ) );
    guess_period                    = sweep_periods( indx_best_period );
    guessk                          = k_vs_period( indx_best_period );
    best_GC                         = GC_vs_period{ indx_best_period };
    
    fprintf('...done\n');
    toc;
    
    
end

% save final results
best_period = guess_period;
bestk       = guessk;
    

% calc and plot power vs. x
best_GC.power_distribution();






























