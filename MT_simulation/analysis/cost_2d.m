function J = cost_2d(params, p_wp, b_fem, I_vec, K_I, c)
% COST_2D  2D cost function for point-charge model fitting
%   J = cost_2d([ell, R_a], p_wp, b_fem, I_vec, K_I, c)
    ell = params(1);
    R_a = params(2);
    if ell <= 0 || R_a <= 0
        J = 1e30;
        return;
    end
    [bx, by, bz] = point_charge_model(p_wp, ell, R_a, I_vec, K_I, c);
    b_mod = [bx; by; bz];
    res = b_mod - b_fem;
    J = sum(res.^2);
end
