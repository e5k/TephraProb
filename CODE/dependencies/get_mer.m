%{
???????????????????????? ???  ??????????  ?????? ??????? ???????  ??????? ??????? 
????????????????????????????  ????????????????????????????????????????????????????
   ???   ??????  ???????????????????????????????????????????????????   ???????????
   ???   ??????  ??????? ??????????????????????????????? ???????????   ???????????
   ???   ???????????     ???  ??????  ??????  ??????     ???  ????????????????????
   ???   ???????????     ???  ??????  ??????  ??????     ???  ??? ??????? ??????? 

Name:       get_mer.m
Purpose:    Calculates a mass flow rate verus height profile for a given set of 
            parameters 
Author:     W. Degruyter

This script is used in the TephraProb package

%}

function Mdot = get_mer(H, Vmax)

%{ 
Matlab script for "Improving on mass flow rate estimates of volcanic 
eruptions" by W. Degruyter and C. Bonadonna 

Calculates a mass flow rate verus height profile for a given set of 
parameters, which can be adjusted by the user. Other expressions are also 
plotted for reference. 

Remarks: 
- all heights are considered above the vent, so convert appropriately 
- the initial bulk specific heat capacity of the plume can be 
approximated by that of the solids as it is mass averaged and the mass 14 is 
determined for > 95% by the solids initial 
- the expression does not account for humidity effects, but provides an 
upper bound for humid conditions 
%} 

%constants 
g   = 9.81;         % gravitational acceleration (m s^-2) 22
z_1 = 2.8;          % maximum non-dimensional height (Morton et al. 23 1956) 24
R_d = 287;          % specific gas constant of dry air (J kg^-1 K^-25 1)1232 26
C_d = 998;          % specific heat capacity at constant pressure of dry 27 air (J kg^-1 K^-1) 28
C_s = 1250;         % specific heat capacity at constant pressure of 29 solids (J kg^-1 K^-1) 30
theta_0 = 1300;     % initial plume temperature (K) 
% entrainment 
alpha   = 0.1;      % radial entrainment coefficient 35
beta    = 0.5;      % wind entrainment coefficient 36

% height of the plume above vent (m)
dummyH = H; %0:10:40000;

% atmosphere temperature profile (Woods, 1988) 41
theta_a0 = 288;     % atmopshere temperature at the vent (K) 42
P_0      = 101325;  % atmopshere pressure at the vent (Pa) 43
rho_a0   = P_0/(R_d*theta_a0); % reference density atmosphere (kg m^-3) 44
H1 = 12000;         % height of the tropopause above the vent (m) 45
H2 = 20000;         % height of the stratosphere above the vent (m) 46
tempGrad_1 = -6.5/1000; % temperature gradient in the troposphere (K m^-47 1) 48
tempGrad_2 = 0;     % temperature gradient between troposphere and startosphere (K m^-1) 50
tempGrad_3 = 2/1000;% temperature gradient in the stratosphere (K m^-51 1) 52

% reduced gravity (m s^-2) 54
gprime = g*(C_s*theta_0-C_d*theta_a0)/(C_d*theta_a0);
% average square buoyancy frequency Nbar^2 = Gbar across height of 
% the plume (s^-2) 
G1 = g^2/(C_d*theta_a0)*(1+C_d/g*tempGrad_1); 
G2 = g^2/(C_d*theta_a0)*(1+C_d/g*tempGrad_2); 
G3 = g^2/(C_d*theta_a0)*(1+C_d/g*tempGrad_3); 
Gbar = G1.*ones(size(dummyH)); 
Gbar(dummyH>H1) = (G1.*H1 + G2.*(dummyH(dummyH>H1)-H1))./dummyH(dummyH>H1); 
Gbar(dummyH>H2) = (G1.*H1 + G2.*(H2-H1) + G3.*(dummyH(dummyH>H2)-H2))./dummyH(dummyH>H2); 
Nbar = Gbar.^(1/2); 
% atmosphere wind profile (Bonadonna and Phillips, 2003) 71
%Vmax = 0; % maximum wind speed at the tropopause (m/s), change to e.g. 30 to see effect of wind
% average wind speed across height of the plume (m/s) 
Vbar = Vmax.*dummyH./H1./2; 
Vbar(dummyH>H1) = 1./dummyH(dummyH>H1).*(Vmax.*H1./2 + Vmax.*(dummyH(dummyH>H1)-H1) -0.9.*Vmax./(H2-H1).*(dummyH(dummyH>H1)-H1).^2./2); 
Vbar(dummyH>H2) = 1./dummyH(dummyH>H2).*(Vmax.*H1./2 + 0.55.*Vmax.*(H2-H1) + 0.1.*Vmax.*(dummyH(dummyH>H2)-H2)); 
% equation (6) in manuscript 
Mdot = pi*rho_a0/gprime*((2^(5/2)*alpha^2.*Nbar.^3./z_1.^4).*dummyH.^4 +(beta^2.*Nbar.^2.*Vbar/6).*dummyH.^3); 


% figure(1),clf 
% plot(Mdot,dummyH.*1e-3,'black', 'LineWidth',2),hold on 
% axis([1e3 1e9 0 40])
% ylabel('Height (km)')
% xlabel('Mass flow rate (kg/s)')
% set(gca,'XScale','log')
% set(gca,'XTick',[1e3 1e4 1e5 1e6 1e7 1e8 1e9])
% % OTHER EXPRESSIONS 100
% 
% % Wilson et al. 1980, equation (38); Wilson and Walker 1987, equation 104
% % (16) 
% % scaling for fixed values 
% H = 0:0.01:40; 
% M0 = (H./0.236).^4; 
% figure(1) 
% plot(M0,H,'b--', 'LineWidth',2),hold on
% % Sparks et al. 1997, equation (5.1) 
% % fitting observations 
% rho_dre = 2500; 
% H = 0:0.01:40; 
% M0dot = rho_dre.*(H./1.67).^(1/0.259); 
% 
% figure(1) 
% plot(M0dot,H,'g--', 'LineWidth',2),hold on 
% 
% % Mastin et al. 2009, equation (1) 
% % fitting observations 
% rho_dre = 2500; 
% H = 0:0.01:40; 
% M0dot = rho_dre.*(H./2).^(1/0.241); 
% 
% figure(1) 
% plot(M0dot,H,'y--', 'LineWidth',2),hold on 
% % Dacre et al. 2011 equation (A1) 
% M0dot = 10.^(3:0.5:9); 
% H = 0.365.*M0dot.^0.225; 
% figure(1) 
% plot(M0dot,H,'r--', 'LineWidth',2) 
% legend('equation (6)','Wilson et al. 1980 / Wilson and Walker 137 1987','Sparks et al. 1997',... 
% 'Mastin et al. 2009', 'Dacre et al. 2011') 
% hold off 
% 
% figure(2),clf 
% plot(Mdot,dummyH.*1e-3,'black', 'LineWidth',2),hold on 
% 
% axis([1e3 1e9 0 40]) 
% ylabel('Height (km)') 
% xlabel('Mass flow rate (kg/s)') 
% set(gca,'XScale','log') 
% set(gca,'XTick',[1e3 1e4 1e5 1e6 1e7 1e8 1e9]) 
% % Carazzo et al. 2008, Table 4, polar 151
% % fitting to 1d model 
% H_1 = 0:0.01:10; 
% Q0_1 = 156.*H_1.^4; 
% H_2 = 10:0.01:23; 
% Q0_2 = 244.*H_2.^4 -5.3e5; % ????? -5.3e7 in paper 
% H_3 = 23:0.01:40; 
% Q0_3 = 386.*H_3.^4 -2.3e6; 
% figure(2) 
% plot([Q0_1 Q0_2 Q0_3],[H_1 H_2 H_3],'b--', 'LineWidth',2),hold on 
% % Carazzo et al. 2008, Table 4, intermediate 
% % fitting to 1d model 
% H_1 = 0:0.01:12; 
% Q0_1 = 74.*H_1.^4; 
% H_2 = 12:0.01:17; 
% Q0_2 = 258.*H_2.^4 -4.6e6; 
% H_3 = 17:0.01:40; 
% Q0_3 = 252.*H_3.^4; 
% figure(2) 
% plot([Q0_1 Q0_2 Q0_3],[H_1 H_2 H_3],'g--', 'LineWidth',2),hold on
% % Carazzo et al. 2008, Table 4, tropical 
% % fitting to 1d model 
% H_1 = 0:0.01:18; 
% Q0_1 = 70.*H_1.^4;
% H_2 = 18:0.01:25;
% Q0_2 = 278.*H_2.^4 -2.5e7; 
% H_3 = 25:0.01:40; 
% Q0_3 = 234.*H_3.^4; 
% 
% figure(2)
% plot([Q0_1 Q0_2 Q0_3],[H_1 H_2 H_3],'y--', 'LineWidth',2),hold on 
% % Kaminski et al. 2011, equation (17) and (18) 191
% % fitting to 1d model 192
% H_1 = 0:0.01:12; 
% Qf_1 = (H_1./0.3).^4; 
% H_2 = 12:0.01:40; 
% Qf_2 = ((H_2-5.53)./0.16).^4;
% figure(2)
% plot([Qf_1 Qf_2],[H_1 H_2],'r--', 'LineWidth',2),hold on 199
% legend('equation (6)','Carazzo et al. 2008 - polar','Carazzo et al. 2008 200 - intermediate',... 201
% 'Carazzo et al. 2008 - tropical', 'Kaminski et al. 2011')
% hold off