clear all; close all; clc

% assumed force-velocity properties(roughly based on human quadriceps)
vmax = 12; % [lopt/s]
lceopt = 0.09; % [m]
Fmax = 4000; % [N]
a = 0.25; % curvature
ft = 0.5; % fraction fast-twitch

% estiate muscle mass (Umberger et al., 2003)
sigma = 0.25 * 10^6; % [N/m^2]
rho = 1059.7; % [kg / m^3]
PSCA = Fmax / sigma; % [m^2]
mass = rho * PSCA * lceopt; % [kg]

% force-velocity
vrel = linspace(0,vmax,100);
Frel = (1+a)./(vrel/(a*vmax)+1) - a;
vce = vrel*lceopt;
Fce = Frel*Fmax;

%% Evaluate two models: Bhargava et al. (2004) and Umberger et al. (2003)
for j = 1:2
    %% Calculations
    % mechanical power
    Pdot = Fce.*vce; % [W]

    if j == 1 % Bhargava et al. (2004)
        % heat terms
        Mdot = mass * ft*111 + (ft-1)*74; % [W] (Table 1)
        Sdot = (0.16 * Fmax + 0.18*Fce) .* vce; % [W] (Eq. 8-9)
        Bdot = mass * .0225; % [W] (Eq. 11)

    elseif j == 2 % Umberger et al. (2003)
        as = 100 / (vmax/2.5); % (Eq. 9)
        af = 153 / vmax; % (Eq. 10)

        S = 1.5; % aerobic (in text)

        % heat terms
        Mdot = S*mass * (ft * 128 + 25); % [W] (Eq. 8)
        Sdot = S*mass * (as * (1-ft) + af*ft) * vrel; % [W] (Eq. 11)
        Bdot = 0; % [W] no basal, but a minimum of 1 W/kg
    end

    % total energy rate
    Edot = Mdot + Sdot + Bdot + Pdot; % [W]

    %% Plotting
    figure(1)
    color = get(gca,'colororder');
    subplot(221); 
    plot(vce,Fce); hold on
    ylabel('Force (N)')

    subplot(222);
    plot(vce, Edot/mass,'color',color(j,:)); hold on
    plot([0 max(vce)], Mdot/mass * [1 1], ':','color',color(j,:))
    ylabel('Energy rate (W/kg)')
    ylim([0 700])

    subplot(223)
    plot(vce, Pdot/mass); hold on
    ylabel('Work rate (W/kg)')

    subplot(224)
    plot(vce, Pdot./Edot); hold on
    ylabel('Efficiency')
end

% rough maximal empirical value (e.g., Margaria 1968; Pugh et al., 1974)
plot([0 max(vce)], [.25 .25],'k--')

titles = {'Force-velocity','Energy-velocity','Power-velocity','Efficiency-velocity'};
for i = 1:4
    subplot(2,2,i); box off
    xlabel('Velocity (m/s)')
    title(titles{i});
    xlim([0 max(vce)])
end

legend('Bhargava','Umberger','Max. empirical','location','best')
legend boxoff
saveas(gcf,'Fig1.jpg')
