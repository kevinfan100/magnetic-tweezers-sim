function c = mt_constants()
% MT_CONSTANTS  Hung hexapole design constants
%   WP center at origin (0,0,0) — no SPH_OFST offset

    c.R_norm    = 500e-6;                      % working radius [m]
    c.R_norm_xy = c.R_norm * sqrt(2/3);        % 408.2 um
    c.R_norm_z  = c.R_norm / sqrt(3);          % 288.7 um
    c.SPH_OFST  = 0;                           % Hung WP = origin

    % Pole angles
    c.TILT_UP = 35.0;       % degrees
    c.TILT_DN = 5.71;       % degrees
    c.magic_angle = 54.74;  % degrees

    % Pole geometry
    c.POLE_R         = 3.175e-3;
    c.POLE_CONE_LEN  = 15.875e-3;
    c.POLE_TOTAL_LEN = 43.0e-3;

    % 6 pole tip positions (Hung: on sphere R=0.5mm at origin)
    fc_h = cosd(c.magic_angle) * c.R_norm;
    fc_r = sind(c.magic_angle) * c.R_norm;
    azim = [0, 180, 120, 300, 60, 240];  % P1-P6
    layer = [-1, 1, -1, 1, 1, -1];       % -1=lower, +1=upper
    c.tip_x = zeros(1,6);
    c.tip_y = zeros(1,6);
    c.tip_z = zeros(1,6);
    for i = 1:6
        c.tip_x(i) = cosd(azim(i)) * fc_r;
        c.tip_y(i) = sind(azim(i)) * fc_r;
        c.tip_z(i) = layer(i) * fc_h;
    end

    % Yoke geometry (for wide-view plot)
    c.YOKE_RI = 38.0e-3;
    c.YOKE_RO = 62.5e-3;
end
