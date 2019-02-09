function [SoCFin, VbattOut, IbattOut] = modelBatt(dt, SoC, T, jour, puissBatt)
%Modele de la batterie d'EyeSat

    %Cette fonction r�partit juste la puissance demand�e sur les 4 accu.
    %Elle fait appel � modelAccu qui est un model g�n�rique d'accumulateur
    %qui pourrait �tre utilis� avec un autre pack batterie.
    %Si la puissance est n�gative, on est en recharge.
    %Cela permet d'avoir les caract�ristiques du bloc batterie.

    %La gestion temperature devrait �tre implemente dans cette fonction.


%% INPUTS
    %dt : intervale de temps du pas -min-
    %SoC : Etat de charge debut -%-
    %T : Temp�rature -�C-
    %jour : Jour actuelle de la mission
    %puissBatt : puissance que le bloc batterie doit fournir -W-

%% OUTPUTS
    %SoCFin : Etat de Charge en fin -%-
    %VbattOut : Tension de sortie de la batterie -V-
    %IbattOut : Courant de sortie de la batterie -I-


%% DONNEES - VARIABLES


%% FONCTION

    %% R�partition de la puissance sur les accumulateurs
    
    %La puissance est r�partie sur les 4 accus (peut �tre am�liorer pour prendre en compte
    % les differences de capacites)
    puissAccu = puissBatt/4;
    nSoC = SoC/100;
    
    [nSoCFin, VaccuOut, IaccuOut] = modelAccu(dt, nSoC, T, jour, puissAccu);
    
    SoCFin = nSoCFin*100;
    VbattOut = 2*VaccuOut;
    IbattOut = 2*IaccuOut;


end


