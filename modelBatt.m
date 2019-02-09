function [SoCFin, VbattOut, IbattOut] = modelBatt(dt, SoC, T, jour, puissBatt)
%Modele de la batterie d'EyeSat

    %Cette fonction répartit juste la puissance demandée sur les 4 accu.
    %Elle fait appel à modelAccu qui est un model générique d'accumulateur
    %qui pourrait être utilisé avec un autre pack batterie.
    %Si la puissance est négative, on est en recharge.
    %Cela permet d'avoir les caractéristiques du bloc batterie.

    %La gestion temperature devrait être implemente dans cette fonction.


%% INPUTS
    %dt : intervale de temps du pas -min-
    %SoC : Etat de charge debut -%-
    %T : Température -°C-
    %jour : Jour actuelle de la mission
    %puissBatt : puissance que le bloc batterie doit fournir -W-

%% OUTPUTS
    %SoCFin : Etat de Charge en fin -%-
    %VbattOut : Tension de sortie de la batterie -V-
    %IbattOut : Courant de sortie de la batterie -I-


%% DONNEES - VARIABLES


%% FONCTION

    %% Répartition de la puissance sur les accumulateurs
    
    %La puissance est répartie sur les 4 accus (peut être améliorer pour prendre en compte
    % les differences de capacites)
    puissAccu = puissBatt/4;
    nSoC = SoC/100;
    
    [nSoCFin, VaccuOut, IaccuOut] = modelAccu(dt, nSoC, T, jour, puissAccu);
    
    SoCFin = nSoCFin*100;
    VbattOut = 2*VaccuOut;
    IbattOut = 2*IaccuOut;


end


