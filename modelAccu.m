function [nSoCFin, VoutFin, Iout] = modelAccu(dt, nSoCDebut, T, jour, puiss)
%Modele de calcul d'un accumulateur

    %Cette fonction calcule pour un intervale de temps, un SoC batterie initial
    %et une puissance demandée les caractéristiques batteries (SoC, courant,
    %tension, capacité,...) en fonction des paramétres influant la pile à
    %savoir : Temperature, courant et nombre de cycles. 
    
    %Si la puissance est négative, on est en recharge.
    
    %Pour le nombre de cycle, sauf si des moyens sont proposés pour faire des
    %tests, une solution a été proposé par Céline Cenac; en fonction du nombre
    %de jour de mission actuelle, une perte de capacité linéaire est proposée.

    %Les taux de capacité en fonction du courant ainsi que de la
    %température peuvent être tresté, pour l'instant, les valeurs de la
    %datasheet (surement pessimiste sont prises);
    
    %Un calcul de la résistance interne pourrait aussi être fait grâce à
    %des tests, pour l'instant une valeur moyenne du test 1 est choisie.
    
    %Le système de fin de décharge et fin de charge peut être amélioré.

%% INPUTS
    %dt : intervale de temps du pas -min-
    %nSoCDebut : Etat de charge debut -%/100-
    %T : Température -°C-
    %jour : Jour actuelle de la mission
    %puiss : puissance que l'accumulateur doit fournir ou de recharge si négative -W-

%% OUTPUTS
    %nSoCFin : Etat de Charge en fin -%/100-
    %VoutFin : Tension de sortie de l'accu, -V-
    %Iout : Courant de sortie de l'accu, -A-


%% DONNEES - VARIABLES - PARAMETRES

    %% Donnees 
    
    %Données Datasheet des Accu LithiumIon 18650 Samsung
    VaccuMin = 2.75;    % V
    VaccuNom = 3.63;    % V
    VaccuMax = 4.2;     % V
    capaMax = 2.6;     % Ah
    IrechMax = 2.6; %Courant de recharge maximum (A)
    IdechMax = 5.2; %Courant de decharge maximum (A)
    
    %Resistance interne de la pile (Ohm) valeur du test (voir Calcul_Rb
    %dans test accu) 0.135 
    Raccu = 0.20; 

    mTCapa = [-10 0.5; 0 0.8; 25 1; 40 0.8; 60 0.54]; %Matrice des données de capacité relative en fonction de la temperature (datasheet)
    mICapa = [-5.2 0.8; -2.6 0.9; -1.3 0.95; -0.52 1; 0.52 1; 1.3 0.95; 2.6 0.9; 5.2 0.8]; %Matrice des données de capacité relative en fonction du courant (datasheet)
    
    tauxMaxNdCMission = 0.8; %Taux de capacite en fin de mission (valeur prise avec marge par Céline Cenac, à tester ou consolider si possible)
    mNdCCapa = [1 1; 365 tauxMaxNdCMission]; %Matric des données capa pour le nombre de cycles
    
    %% Variables globales
    global mVaccuSoC

    %% Tests parametres
    if T < 0 || T > 60
        error('Temperature en dehors des limites');
    end
    if jour < 1
        error('Jour inférieur à 1');
    end


%% FONCTION

    %% Calcul des tensions internes et du courant de l'accu

    %VaccuInterne est la tension de l'element actif (avant la resistance interne), calculé à partir de la courbe 
    %caractéristique de l'accumulateur (test 1)
    VaccuDebut = interp1(mVaccuSoC(:,1), mVaccuSoC(:,2), nSoCDebut, 'spline');

    % Iaccu est calculé pour que Iaccu*Vout = P en sachant que Vout = Vaccu - Raccu*Iaccu
    % Si Iaccu est négatif on est en recharge, en décharge si positif
    valeursI = roots([Raccu -VaccuDebut puiss]);
    Iaccu = valeursI(2);
        
    % Une fois I connu, la tension mesurée en sortie de l'accu peut être calculee
    VoutDebut = puiss/Iaccu; 

    if Iaccu < -IrechMax
        error('Courant de charge trop important')
    elseif Iaccu > IdechMax
        error('Courant de decharge trop important')
    end
    if VoutDebut < VaccuMin
        error('Tension accu sous le seuil, batterie dechargee')
    elseif VaccuDebut > VaccuMax
        error('Tension accu supérieur a la valeur maximale')
    end


    %% Calcul des taux de capacite en fonction de la temperature, du courant et du nombre de cycle

    tauxT = interp1(mTCapa(:,1), mTCapa(:,2), T, 'linear');
    tauxI= interp1(mICapa(:,1), mICapa(:,2), Iaccu, 'linear');
    tauxNdC = interp1(mNdCCapa(:,1), mNdCCapa(:,2), jour, 'linear');

    tauxCapa = 1-((1-tauxT)+(1-tauxI)+(1-tauxNdC));

    if tauxT > 1 || tauxI > 1 || tauxNdC > 1 || tauxCapa > 1
        error('Un des rendements pile supérieur à 100% (voir les interpolations)')
    end

    capaTot = capaMax*tauxCapa;

    %Si la capacite totale change (les conditions d'utilisation changent), la capacité restante change d'autant (le SoC reste identique)
    capaRest = capaTot*nSoCDebut;


    %% Calcul en fin de pas

    capaRestFin = capaRest - Iaccu*dt/60;
    nSoCFin = capaRestFin/capaTot;
    
    VaccuFin = interp1(mVaccuSoC(:,1), mVaccuSoC(:,2), nSoCFin, 'spline');
    VoutFin = VaccuFin - Raccu*Iaccu;
    
    %Si l'accumulateur est trop chargé on considere qu'il est charge à fond
    %Pas parfait car cela devrait lever une erreur de surcharge.
    if nSoCFin > 1
        nSoCFin = 1;
    end
    
    %Si la tension accu passe en dessous de la limite inférieur    
    if VoutFin < VaccuMin
        error('Tension accu sous le seuil, batterie dechargee')
    end
      
    Iout = Iaccu;


end


