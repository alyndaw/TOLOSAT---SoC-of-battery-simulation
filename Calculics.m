function [Ics] = Calculics(Vcs, alpha, T)
%Fonction qui calcule le courant produit par une cellule solaire en fonction des paramétres

%% INPUTS
    %Vcs : Tension de la cellule (imposée par la batterie) -V-
    %alpha : angle au soleil -rad-
    %T : Température de la cellule solaire -°C-
    
%% OUTPUTS
    %Ics : Courant produit par une cellule solaire -A-


%% DONNEES - VARIABLES - PARAMETRES
    %% Donnees datasheet de la cellule azurspace
    Tmoyen = 28;
    VcsMax = 2.690;
    VcsOpti = 2.409; %V
    IcsMax = 0.5196;
    IcsOpti = 0.5029; %A
    dVTMax = -6.2e-3; %V/°C
    dVTOpti = -6.7e-3; %V/°C
    dITMax = 0.36e-3; %A/°C
    dITOpti = 0.24e-3; %A/°C

    %% Chute de tension de la diode de Schottky
    Vdiode = 0.1; 

    %% Calcul des paramétres correspondant à la température
    VcsMaxT = VcsMax+(T-Tmoyen)*dVTMax;
    VcsOptiT = VcsOpti+(T-Tmoyen)*dVTOpti;
    IcsMaxT = IcsMax+(T-Tmoyen)*dITMax;
    IcsOptiT = IcsOpti+(T-Tmoyen)*dITOpti;
    
    

%% CALCUL DU COURANT POUR UN ECLAIREMENT OPTIMAL
    
    VcsDiode = Vcs + Vdiode;

    if VcsDiode < VcsOptiT
        IcsMax = IcsMaxT+(IcsOptiT-IcsMaxT)/VcsOpti*VcsDiode;
    else
        IcsMax = IcsOptiT+(0-IcsOptiT)/(VcsMaxT-VcsOptiT)*(VcsDiode-VcsOptiT);
    end
    if IcsMax < 0
        IcsMax = 0;
    end

%% PRISE EN COMPTE DE L'ANGLE D'ENSOLEILLEMENT
    Ics = IcsMax*cos(alpha);

end

