function [SoCFin, VbattFin, IbattFin, Isat, Igs] = modelPuissance(mode, dt, Vbatt, SoC, alpha, T, jour)

%Calcul le State of Charge (SoC) et les parametres batterie en prenant pour
%entr�e une dur�e pass� dans un mode et les caract�ristiques batteries initiaux

%% INPUTS
    %mode: (String) Mode satellite actuel : 'Tempo', 'Survie', 'Veille', 'PDV', 'Vidage', 'Ralliement' ou erreur
    %dt: (float) Dur�e de l'intervalle de temps -min-
    %SoC: (float) State of Charge initial de la batterie -%-
    %alpha: (float) -optionnel- Angle au soleil -rad-
    %T: (float) -optionnel- Temp�rature en d�but d'it�ration -�C-
    %jour: (float) -optionnel- Jour actuel de la mission
    
%% OUTPUTS
    %SoCFin: (float) State of Charge � la fin du pas -%-
    %VbattFin: (float) Tension batterie � la fin de la dur�e -V-
    %Ibatt: (float) Courant batterie -A-
    
    
%% DONNEES - VARIABLES - PARAMETRES

    %% Variables gloables
    
    global VmaxShunt

    %% Parametres

    %Pas de puissance -W- pour le calcul de la puissance la plus proche pour
    %le passage NonShunt => Shunt et Shunt => NonShunt
    %(fais varier grandement le temps de simulation)
    deltaPuiss = 1;
    %Nbre panneaux solaires 
    Nbre_panneau=1;

    %% Tests Parametres

    %Attribution des parametres si tous ne sont pas donn�es
    if nargin < 7
        jour = 0;
    end
    if nargin < 6
        T = 25;
    end
    if nargin < 5
        alpha = 0;
    end


%% FONCTION DE CALCUL DU SOC ET DE VBATT

    %% Calcul de la puissance n�cessaire au satellite
    
    %Prendre en compte les marges instruments? (0%, 10% ou 20% en fonction des instruments, voir Bilan de puissance IDM CIC)
    %0 pour non, 1 pour oui
    margeI = 1;
    
    %Prendre en compte les pertes des cartes de puissance?
    %0 pour non, 1 pour oui
    pertePuiss = 1;
    
    if strcmp(mode, 'CT')
        puiss = Puissance_necessaire('Veille', margeI);
%         perteCI = PerteCI('Veille')*pertePuiss;
%         perteCP = PerteCP (Vbatt)*pertePuiss;
%         perteGS = PerteGS(Vbatt/4, alpha, T)*pertePuiss;
    else
        puiss = Puissance_necessaire(mode, margeI);
%         perteCI = PerteCI(mode)*pertePuiss;
%         perteCP = PerteCP (Vbatt)*pertePuiss;
%         perteGS = PerteGS(Vbatt/4, alpha, T)*pertePuiss;
    end
    

    puissOutCP = puiss;%+perteCI+perteGS+perteCP;
    Isat = puissOutCP/Vbatt;
    
    %% Calcul de l'energie produite par les GS
    
    %Appel � la fonction de calcul du courant produit par les GS
    %Igs = Nbre_panneau*Calculics(Vbatt/4, alpha, T);
    Igs=0;
    
    %Calcul de la puissance produite par les GS   
    %puissGS = Igs * Vbatt;
     if strcmp(mode, 'Eclipse')
        puissGS = 0;
     else 
        puissGS=3.5; 
     end
     
    
    %% Puissance �quivalente Pack batterie (+ si d�charge, - si recharge)
 
    %Puissance avec GS
    puissBatt = puissOutCP - puissGS;
    
    %Puissance sans les GS (shunt actif)
    puissBattShunt = puissOutCP;
    
    %% Utilisation du modele de batterie pour le calcul des parametres

    %Si la tension initiale est sup�rieur � la tension limite des shunts,
    %le courant des GS est dissip� (puissBattShunt)
    if Vbatt > 2*VmaxShunt 
        [SoCFin, VbattFin, IbattFin] = modelBatt(dt, SoC, T, jour, puissBattShunt);
        
        %Si la tension finale est repass� sous la barre des shunts, la
        %puissance des GS est fourni pendant un pourcentage de temps du pas.
        %Pour cela une boucle est faite pour trouver la puissance effective
        %pour que la tension reste la plus proche de VmaxShunt.
        %Parametr� par deltaPuiss.
        if VbattFin < 2*VmaxShunt
            [SoCFin, VbattFin, IbattFin] = modelBatt(dt, SoC, T, jour, puissBatt);

            while VbattFin > 2*VmaxShunt
                puissBatt = puissBatt + deltaPuiss;
                [SoCFin, VbattFin, IbattFin] = modelBatt(dt, SoC, T, jour, puissBatt);
            end
        end
        
    %Si la tension initiale est inf�rieur � la tension limite des shunts,
    %le courant des GS n'est pas dissip� (puissBatt
    else
        [SoCFin, VbattFin, IbattFin] = modelBatt(dt, SoC, T, jour, puissBatt);

        %Si la tension finale est repass� au dessus de la barre des shunts, la
        %puissance des GS est fourni pendant un pourcentage de temps du pas.
        %Pour cela une boucle est faite pour trouver la puissance effective
        %pour que la tension reste la plus proche de VmaxShunt.
        %Parametr� par deltaPuiss.
        if VbattFin > 2*VmaxShunt
            [SoCFin, VbattFin, IbattFin] = modelBatt(dt, SoC, T, jour, puissBattShunt);
            
            while VbattFin < 2*VmaxShunt
                puissBattShunt = puissBattShunt - deltaPuiss;
                [SoCFin, VbattFin, IbattFin] = modelBatt(dt, SoC, T, jour, puissBattShunt);
            end
        end
    end



%% SORTIES
    %oVbatt = VbattFin


end

