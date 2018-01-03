% authors: bohan

% Script for testing and debugging the new two level grating cell class
% comparing the new and old solvers

clear; close all;

% dependencies
addpath(['..' filesep 'main']);
addpath(['..' filesep 'auxiliary_functions']);

% initial settings
disc        = 10;
units       = 'nm';
lambda      = 1550; %1500;
index_clad  = 1.0;
domain      = [ 2000, 800 ];
numcells    = 10;

% Init a new object
GC = c_twoLevelGratingCell(  'discretization', disc, ...
                            'units', units, ...
                            'lambda', lambda, ...
                            'domain_size', domain, ...
                            'background_index', index_clad, ...
                            'numcells', numcells )

% draw cell
% draw two levels using two level builder function
% the inputs are organized [ top level, bottom level ]
fill            = 0.9;
ratio           = 1.0;
offset          = 0.0;
period          = domain(2);
wg_index        = [ 3.4, 3.4 ];
wg_thick        = [ 100, 100 ];
wg_min_y        = [ domain(1)/2, domain(1)/2-wg_thick(1) ];
wgs_duty_cycles = [ fill*ratio, fill ];
% wgs_offsets     = [ 0, offset*period ];
wgs_offsets     = [ 0, 200 ];
GC              = GC.twoLevelBuilder(   wg_min_y, wg_thick, wg_index, ...
                                        wgs_duty_cycles, wgs_offsets );
                                 
                                 
% DEBUG plot the index
GC.plotIndex();

% -------------------------------------------------------------------------
% Run new solver
% -------------------------------------------------------------------------

% run simulation
num_modes   = 10;
BC          = 0;     % 0 for PEC, 1 for PMC
guessk      = 2*pi*wg_index(1)*fill/lambda;
% PML_options(1): PML in y direction (yes=1 or no=0)
% PML_options(2): length of PML layer in nm
% PML_options(3): strength of PML in the complex plane
% PML_options(4): PML polynomial order (1, 2, 3...)
pml_options = [ 1, 200, 50, 2 ];

% run simulation
GC = GC.runSimulation( num_modes, BC, pml_options, guessk );

% DEBUG plot physical fields and all fields
k_all       = GC.debug.k_all;
neff_all    = k_all/(2*pi/lambda);

% % plot all fields
% for ii = 1:length( k_all )
%     % Plotting physical fields
%     % plot field, abs
%     figure;
%     imagesc( GC.x_coords, GC.y_coords, abs( GC.debug.phi_all(:,:,ii) ) );
%     colorbar;
%     set( gca, 'YDir', 'normal' );
%     title( sprintf( 'Field (abs) for mode %i, k = %f + i%f', ii, real( k_all(ii) ), imag( k_all(ii) ) ) );
% end

% plot real and imag k
k_labels = {};
for ii = 1:length( k_all )
    k_labels{end+1} = [ ' ', num2str(ii) ];
end
figure;
plot( real( k_all ), imag( k_all ), 'o' ); 
text( real( k_all ), imag( k_all ), k_labels );
xlabel('real k'); ylabel('imag k');
title('real vs imag k');
makeFigureNice();

% Plot the accepted mode
figure;
imagesc( GC.x_coords, GC.y_coords, abs( GC.Phi ) );
colorbar;
set( gca, 'YDir', 'normal' );
title( ['Field (abs) for accepted mode, k= ', num2str( GC.k  ) ] );

% display calculated k
fprintf('\nComplex k = %f + %fi\n', real(GC.k), imag(GC.k) );

% display radiated power
fprintf('\nRad power up = %e\n', GC.P_rad_up);
fprintf('Rad power down = %e\n', GC.P_rad_down);
fprintf('Up/down power directivity = %f\n', GC.directivity);

% display angle of radiation
fprintf('\nAngle of maximum radiation = %f deg\n', GC.max_angle_up);

% plot full Ez with grating geometry overlaid
GC.plotEz_w_edges();
axis equal;

% plot all modes
f_plot_all_modes_gui( GC.debug.phi_all, GC.x_coords, GC.y_coords );



% -------------------------------------------------------------------------
% Run old solver
% -------------------------------------------------------------------------

% run simulation
num_modes   = 10;
BC          = 0;     % 0 for PEC, 1 for PMC
guessk      = 2*pi*wg_index(1)*fill/lambda;
% PML_options(1): PML in y direction (yes=1 or no=0)
% PML_options(2): length of PML layer in nm
% PML_options(3): strength of PML in the complex plane
% PML_options(4): PML polynomial order (1, 2, 3...)
pml_options = [ 1, 200, 5, 2 ];

% run simulation
GC = GC.runSimulation( num_modes, BC, pml_options, guessk );

% DEBUG plot physical fields and all fields
k_all       = GC.debug.k_all;
neff_all    = k_all/(2*pi/lambda);

for ii = 1:length( k_all )
    % Plotting physical fields
    % plot field, abs
    figure;
    imagesc( GC.x_coords, GC.y_coords, abs( GC.debug.phi_all(:,:,ii) ) );
    colorbar;
    set( gca, 'YDir', 'normal' );
    title( sprintf( 'Field (abs) for mode %i, k = %f + i%f', ii, real( k_all(ii) ), imag( k_all(ii) ) ) );
end

% plot real and imag k
k_labels = {};
for ii = 1:length( k_all )
    k_labels{end+1} = [ ' ', num2str(ii) ];
end
figure;
plot( real( k_all ), imag( k_all ), 'o' ); 
text( real( k_all ), imag( k_all ), k_labels );
xlabel('real k'); ylabel('imag k');
title('real vs imag k');
makeFigureNice();

% Plot the accepted mode
figure;
imagesc( GC.x_coords, GC.y_coords, abs( GC.Phi ) );
colorbar;
set( gca, 'YDir', 'normal' );
title( ['Field (abs) for accepted mode, k= ', num2str( GC.k  ) ] );

% display calculated k
fprintf('\nComplex k = %f + %fi\n', real(GC.k), imag(GC.k) );

% display radiated power
fprintf('\nRad power up = %e\n', GC.P_rad_up);
fprintf('Rad power down = %e\n', GC.P_rad_down);
fprintf('Up/down power directivity = %f\n', GC.directivity);

% display angle of radiation
fprintf('\nAngle of maximum radiation = %f deg\n', GC.max_angle_up);

% plot full Ez with grating geometry overlaid
GC.plotEz_w_edges();
axis equal;























