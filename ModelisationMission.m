close all;
clear all;
%Lance une mission donnée en entrée par un excel et affiche l'écolution du SoC

%% DONNEES - PARAMETRES - VARIABLES
    
    %% Parametres utilisateur
    SoCinit = 100; %Valeure initiale de charge de la batterie
    TInit = 23;  %Temperature initiale, tant que le model thermique n'est pas fait, elle reste constante sur toute la mission    
    jour = 1; %Jour actuel de la mission

    NBpoints = 1000; %Nombre de points de la boucle de calcul (1000 points pour 10s)
    
    %Choisir le fichier mission souhaité
    mission = 'MissionNom.xlsx';
    
    %% Donnees
    %Données Datasheet des Piles LithiumIon 18650 Samsung (idéalement il faudrait les mettre en varaibles globales)
    VpileMin = 2.75;    % V
    VpileNom = 3.63;    % V
    VpileMax = 4.2;     % V
    capaPile = 2.6;     % Ah

    %Pack Batterie
    VbattMin = VpileMin*2;                  % V
    VbattNom = VpileNom*2;                  % V
    VbattMax = VpileMax*2;                  % V
    capaBattAh = capaPile*2;                % Ah
    capaBattW = capaBattAh*VbattNom;        % Wh

        
    %% Variables globales
    
    %Courbe tension en fonction du SoC (courbe obtenue avec le test 1, à ameliorer si possible)
    global mVaccuSoC
    mVaccuSoC = xlsread('Courbe_accu.xlsx');
    
    %Valeur de tension maximale de coupure des shunts GS
    global VmaxShunt
    VmaxShunt = 4; %V, Mesuré avec LTSpice, à confirmer avec du test
    global SoCMaxShunt %Calcul du SoC correspondant
    SoCMaxShunt = interp1(mVaccuSoC(:,2), mVaccuSoC(:,1), VmaxShunt, 'spline');
    

    

    %% Variables

    T = TInit;
    
    %Import des données de l'excel mission
    [valeur, texte] = xlsread(mission);
    [NBligne, NBcolonne] = size(valeur);
    tempsFinSimu = valeur(NBligne,3);
    duree = tempsFinSimu/NBpoints;
    nMaxOrb= valeur(NBligne, 1);

    %Matrice pour les plots
    mt = zeros(NBpoints,1);
    mSoC = zeros(NBpoints,1);
    mVbatt = zeros(NBpoints,1);
    mIbatt = zeros(NBpoints,1);
    mIsat = zeros(NBpoints,1);
    mIgs = zeros(NBpoints,1);
    %mSoCODB = zeros(NBpoints,1);
    %mEcartSoC = zeros(NBpoints,1);

    j = 5;
    %Calcul de variables initiales
    tempsFin = valeur(j, 3); %tempsFin est le temps du prochain changement de mode
    mode = texte(j, 7);
    alpha = valeur(j, 8);

    %Affichage de la suite des 14 orbites (valable uniquement si le txt est mis à jour => pas opti)
    orbites = readtable('Orbites_Mission_Nom.txt');


%% BOUCLE DE CALCUL AVEC LE MODELE PUISSANCE

    for i=1 : 1 : NBpoints

        mt(i) = i*tempsFinSimu/NBpoints;

        %Si t depasse tempsFin, les variables sont mises à jour
        if mt(i) > tempsFin
            j = j+1;
            tempsFin = valeur(j, 3);
            mode = texte(j, 7);
            alpha = valeur(j, 8);
        end

        if i == 1 %Premier pas
            mSoC(i) = SoCinit;
            mVbatt(i) = VbattMax;
            mIbatt(i) = 0;
            mIsat(i) = 0;
            mIgs(i) = 0;
        else
            %Appelle de la fonction modelPuissance pour le calcul sur le pas
            [mSoC(i), mVbatt(i), mIbatt(i), mIsat(i), mIgs(i)]  = modelPuissance(mode, duree, mVbatt(i-1), mSoC(i-1), alpha, T, jour);
        end

        %Calcul d'un SoC linéaire sur les valeurs max des accumulateurs
%         mSoCODB(i) = (mVbatt(i)-VbattMin)/(VbattMax-VbattMin)*100;
%         mEcartSoC(i) = mSoCODB(i) - mSoC(i);
        
        nb = i;
    end


%% PLOTS

%     %% Figure 2
%     figure(2)
%     title('Evolution de lecart SoC reel et SoC ODB')
%     xlabel('temps (minute)')
%     plot(mt, mEcartSoC)
%     xlabel('t (min)')
%     ylabel('Ecart entre le SoC ODB et le SoC reel (%)')
% 
% 
%     %% Figure 1
%     fig = figure(1);
%     title('Evolution des caractéristiques Batteries en fonction du temps')
%     xlabel('temps (minute)')
% 
%      v = [0.2 0.7 0.2];
% 
%     subplot(2,1,1);
%     plot(mt, mVbatt, 'b')
%     hold on
%     plot([0 mt(NBpoints)], [2*VmaxShunt 2*VmaxShunt], '--b')
%     ylabel('Tension Batterie (V)')
% 
%     subplot(2,1,2)
%     plot(mt, mIbatt, 'r')
%     hold on
%     plot([0 mt(NBpoints)], [0 0], ':r')
%     hold on
%     plot(mt, mIsat, 'Color', v)
%     hold on
%     plot(mt, mIgs, 'y')
%     xlabel('t (min)')
%     ylabel('Courant Batterie (rouge) et courant sortant CP (vert) (A)')

    
    %% Figure 3
    v = [0.2 0.7 0.2];
    figure(3)
    plot(mt, mSoC, 'Color', v)
    hold on
    plot(mt, ones(size(mt))*50, '--r')
    hold on 
    %plot(mT, mSoCODB, ':r')
    hold on 
    plot([0 mt(NBpoints)], [SoCMaxShunt*100 SoCMaxShunt*100], '--b')

    nOrb = 1;
    gris = [0.1 0.1 0.1];
    while nOrb <= nMaxOrb 
        hold on
        plot([nOrb*tempsFinSimu/nMaxOrb nOrb*tempsFinSimu/nMaxOrb], [0 100], ':', 'Color', gris)
        str = [orbites{nOrb,2}];
        text(nOrb*tempsFinSimu/nMaxOrb-140/2, 5, str);
        nOrb = nOrb+1;
    end

    xlabel('t (min)')
    ylabel('SoC (%)')


