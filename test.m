clear; clc; close all
%% INPUTS
% From NASA CEA Design
AeAt = 4.567; % [-]
AcAt = 15.3713; % [-]
M_e = 2.889; % [-]
gam = 1.2982;
% Other
pts = 100; % [-] Number of points on aerospike curve
r_ch = 1; % [in]
n_b = 0.2;

%% SPIKE CALCULATIONS
r_b_mat = linspace(0,r_ch,10000); % [in]
r_th_mat = ((r_ch^2)/AcAt+r_b_mat.^2).^(1/2); % [in]
r_e_mat = (AeAt.*(r_th_mat.^2-r_b_mat.^2)+r_b_mat.^2).^(1/2); % [in]
n_b_mat = r_b_mat./r_e_mat; % [-]

[~,ind] = min(abs(n_b_mat - n_b));
r_b = r_b_mat(ind);
r_th = ((r_ch^2)/AcAt+r_b^2)^(1/2); % [in]
r_e = (AeAt*(r_th^2-r_b^2)+r_b^2)^(1/2); % [in]
r_b/r_e

plot(r_b_mat,n_b_mat); axis equal; grid on;