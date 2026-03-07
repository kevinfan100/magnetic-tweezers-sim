function c = mt_constants()
% MT_CONSTANTS  Shared geometry constants for magnetic tweezers analysis
%   c = mt_constants() returns struct with all geometry parameters,
%   pole naming conventions, and coordinate transforms.
%   Must match values in APDL scripts.

    % Working radius
    c.R_norm    = 500e-6;                              % [m]
    c.R_norm_xy = c.R_norm * sqrt(2/3);                % ~408 um
    c.R_norm_z  = c.R_norm / sqrt(3);                  % ~289 um

    % Yoke and protrusion geometry
    c.PROT_H    = 7.0e-3;                              % protrusion height [m]
    c.PROT_R    = 10.0e-3 / 2;                         % protrusion radius [m]
    c.YOKE_IN_R  = 84e-3 / 2;                          % yoke inner radius [m]
    c.YOKE_OUT_R = 106e-3 / 2;                         % yoke outer radius [m]
    c.YOKE_MID_R = (c.YOKE_IN_R + c.YOKE_OUT_R) / 2;  % ~47.5 mm

    % Working point offset from APDL origin (yoke base center)
    c.SPH_OFST = -c.PROT_H - 6e-3 + c.R_norm_z;       % ~ -12.711 mm

    % Pole naming: Paper convention
    %   Paper index:  P1    P2     P3     P4     P5    P6
    %   Angle (deg):  0     180    120    300    60    240
    %   Layer:        Lower Upper  Lower  Upper  Upper Lower
    c.pole_angles = [0, 180, 120, 300, 60, 240];        % degrees, indexed P1-P6
    c.pole_labels = {'P1','P2','P3','P4','P5','P6'};

    % APDL coil index -> Paper pole name
    %   Coil1->P1, Coil2->P3, Coil3->P6, Coil4->P5, Coil5->P2, Coil6->P4
    c.apdl_to_paper = {'P1','P3','P6','P5','P2','P4'};

    % Pole tip positions in WP-centered coordinates [m]
    %   x_wp = R_norm_xy * cos(angle), y_wp = R_norm_xy * sin(angle)
    %   z_wp = -R_norm_z for lower, +R_norm_z for upper
    c.pole_tip_x = c.R_norm_xy * cosd(c.pole_angles);   % [m]
    c.pole_tip_y = c.R_norm_xy * sind(c.pole_angles);   % [m]
    c.pole_tip_z_wp = [-1, +1, -1, +1, +1, -1] * c.R_norm_z;  % [m] P1-P6
end
