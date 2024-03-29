clc; clear; close all;
%% INPUTS
% From NASA CEA Design
AeAt = 4.567; % [-]
AcAt = 15.3713; % [-]
M_e = 2.889; % [-]
gam = 1.2982;
% Other
r_b = 0.1; % [in]
r_ch = 1; % [in]
pts = 1000; % [-] Number of points on aerospike curve

%% SPIKE CALCULATIONS
r_th = ((r_ch^2)/AcAt+r_b^2)^(1/2); % [in]
r_e = (AeAt*(r_th^2-r_b^2)+r_b^2)^(1/2); % [in]


n_b = r_b/r_e; % [-]

M=linspace(1,M_e,pts); % [-]
AR = areaRatio(gam,M); % [-]

PM = prantylMeyer(gam,M); % [deg]
PM_e = PM(end);
mu = asind(1./M); % [deg]
alpha = mu - PM; % [deg]


term1 = (AR.*(1-n_b).*M.*sind(alpha)./AeAt);
zeta = (1-(1-term1))./sind(alpha);

x_spike = zeta.*cosd(alpha+PM_e).*r_e;
y_spike = zeta.*sind(alpha+PM_e).*r_e - r_e;


x_trunc = [];
y_trunc = [];
if r_b > 0
    x_trunc = [x_spike(end) x_spike(end)];
    y_trunc = [y_spike(end) y_spike(end)+r_b];
end
%% UPSTREAM SPIKE CONTOUR
% RPE Upstream & Downstream Throat Curve Radius
flt_ex = 0.382*r_th;
flt_ent = 1.5*r_th;
upstream_angle = 30;

start_theta_ds = PM_e-90;
end_theta_ds = -90;
downstream_angles = linspace(end_theta_ds,start_theta_ds,pts);
center_x_ds = x_spike(1) - flt_ex*cosd(start_theta_ds);
center_y_ds = y_spike(1) - flt_ex*sind(start_theta_ds);
x_ds = flt_ex*cosd(downstream_angles) + center_x_ds;
x_ds = x_ds(1:end-1);
y_ds = flt_ex*sind(downstream_angles) + center_y_ds;
y_ds = y_ds(1:end-1);

start_theta_us = end_theta_ds;
end_theta_us = start_theta_us - upstream_angle;
upstream_angles = linspace(end_theta_us,start_theta_us);
center_x_us = x_ds(1) - flt_ent*cosd(start_theta_us);
center_y_us = y_ds(1) - flt_ent*sind(start_theta_us);
x_us = flt_ent*cosd(upstream_angles) + center_x_us;
x_us = x_us(1:end-1);
y_us = flt_ent*sind(upstream_angles) + center_y_us;
y_us = y_us(1:end-1);

ent_slope_end_x = x_us(1) + y_us(1)/tand(upstream_angle);
ent_slope_end_y = 0;

ent_slope_x = linspace(ent_slope_end_x, x_us(1),pts);
ent_slope_x = ent_slope_x(1:end-1);
ent_slope_y = linspace(ent_slope_end_y, y_us(1),pts);
ent_slope_y = ent_slope_y(1:end-1);

%% SHROUD & CHAMBER CONTOUR
L_ch = 3.1; % Create function which defines this parametrically. Using L_ch?
shroud_angle = 45; % Defined from -PM_e+90 to 60

shroud_start_x = x_spike(1) + zeta(1)*r_e*cosd(PM_e);
shroud_start_y = y_spike(1) - zeta(1)*r_e*sind(PM_e);

shroud_start_theta = start_theta_ds;
shroud_end_theta = -shroud_angle;
shroud_angles = linspace(shroud_end_theta,shroud_start_theta,pts);

shroud_center_x_ds = shroud_start_x - flt_ent*cosd(shroud_start_theta);
shroud_center_y_ds = shroud_start_y - flt_ent*sind(shroud_start_theta);
shroud_x_ds = flt_ent*cosd(shroud_angles) + shroud_center_x_ds;
shroud_y_ds = flt_ent*sind(shroud_angles) + shroud_center_y_ds;

ch_start_y = -r_ch + flt_ent*(1 - sind(shroud_end_theta));
ch_start_x = shroud_x_ds(1) - (ch_start_y - shroud_y_ds(1));

ch_start_theta = shroud_end_theta;
ch_end_theta = -90;
ch_angles = linspace(ch_end_theta,ch_start_theta,pts);

ch_center_y = -r_ch + flt_ent;
ch_center_x = ch_start_x - flt_ent*cosd(ch_start_theta);

ch_x = flt_ent*cosd(ch_angles) + ch_center_x;
ch_y = flt_ent*sind(ch_angles) + ch_center_y;

ch_slope_x = linspace(ch_start_x, shroud_x_ds(1), pts);
ch_slope_x = ch_slope_x(2:end-1);
ch_slope_y = linspace(ch_y(end), shroud_y_ds(1), pts);
ch_slope_y = ch_slope_y(2:end-1);

ch_len_end_x = ent_slope_x(1)-L_ch;
ch_len_end_y = ch_y(1);

ch_len_x = linspace(ch_len_end_x, ch_x(1), pts);
ch_len_x = ch_len_x(1:end-1);
ch_len_y = linspace(ch_len_end_y, ch_y(1), pts);
ch_len_y = ch_len_y(1:end-1);

%% COMBINING CURVES
spike_contour_x = [ent_slope_x x_us x_ds x_spike];
spike_contour_y = [ent_slope_y y_us y_ds y_spike];

shroud_inner_contour_x = [ch_len_x ch_x ch_slope_x shroud_x_ds];
shroud_inner_contour_y = [ch_len_y ch_y ch_slope_y shroud_y_ds];

%% SHROUD & CHAMBER WALL THICKNESS
wall_thickness = 0.15; % [in]
[shroud_outer_contour_x, shroud_outer_contour_y] = curve_offset(shroud_inner_contour_x,shroud_inner_contour_y,-wall_thickness);
while (shroud_outer_contour_x(end) > shroud_inner_contour_x(end))
         shroud_outer_contour_x(end) = [];
         shroud_outer_contour_y(end) = [];
end

% Shroud Wall Edge - Plotting Only
ds_wall_x = linspace(shroud_inner_contour_x(end),shroud_outer_contour_x(end),pts);
ds_wall_y = linspace(shroud_inner_contour_y(end),shroud_outer_contour_y(end),pts);

us_wall_x = linspace(shroud_inner_contour_x(1),shroud_outer_contour_x(1),pts);
us_wall_y = linspace(shroud_inner_contour_y(1),shroud_outer_contour_y(1),pts);
%% PLOTTING
aerospikeContour = figure('Name','Aerospike Contour');
% X-Lim Scale
scale = 1.1;
centerline_x = [-10 10];
centerline_y = [0 0];

hold on
plot(centerline_x,centerline_y,'--k')
% Spike
plot(spike_contour_x, spike_contour_y,'k', x_trunc, y_trunc,'k')
plot(spike_contour_x,-spike_contour_y,'k',x_trunc,-y_trunc,'k')
% Shroud & Chamber Wall
plot(shroud_inner_contour_x, shroud_inner_contour_y,'k')
plot(shroud_inner_contour_x, -shroud_inner_contour_y,'k')
plot(shroud_outer_contour_x,shroud_outer_contour_y,'k')
plot(shroud_outer_contour_x,-shroud_outer_contour_y,'k')
plot(ds_wall_x,ds_wall_y,'k')
plot(ds_wall_x,-ds_wall_y,'k')
plot(us_wall_x,us_wall_y,'k')
plot(us_wall_x,-us_wall_y,'k')
hold off

xlim([ch_len_x(1) spike_contour_x(end)]*scale)
axis equal
grid on;
set(gca,'TickLabelInterpreter','latex')
xticks(-4:1:1); yticks(-2:1:2);
title('\bf{Toroidal Aerospike Contour}','Interpreter','latex')
xlabel('Length $[in]$','Interpreter','latex'); ylabel('Radius $[in]$','Interpreter','latex')
lgd = legend('Line of Symmetry');
saveas(aerospikeContour,'aerospikeContour','png');
%% EXPORT DATA
spike_contour_z = zeros(1,length(spike_contour_x));
shroud_inner_contour_z = zeros(1,length(shroud_inner_contour_x));
shroud_outer_contour_z = zeros(1,length(shroud_outer_contour_x));
writematrix([spike_contour_x;spike_contour_y;spike_contour_z]','spike_contour.txt');
writematrix([shroud_inner_contour_x;shroud_inner_contour_y;shroud_inner_contour_z]','shroud_inner_contour.txt');
writematrix([shroud_outer_contour_x;shroud_outer_contour_y;shroud_outer_contour_z]','shroud_outer_contour.txt');