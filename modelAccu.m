function [nSoCFin, VoutFin, Iout] = modelAccu(dt, nSoCDebut, T, jour, puiss)
%Modele de calcul d'un accumulateur

    %Cette fonction calcule pour un intervale de temps, un SoC batterie initial
    %et une puissance demand�e les caract�ristiques batteries (SoC, courant,
    %tension, capacit�,...) en fonction des param�tres influant la pile �
    %savoir : Temperature, courant et nombre de cycles. 
    
    %Si la puissance est n�gative, on est en recharge.
    
    %Pour le nombre de cycle, sauf si des moyens sont propos�s pour faire des
    %tests, une solution a �t� propos� par C�line Cenac; en fonction du nombre
    %de jour de mission actuelle, une perte de capacit� lin�aire est propos�e.

    %Les taux de capacit� en fonction du courant ainsi que de la
    %temp�rature peuvent �tre trest�, pour l'instant, les valeurs de la
    %datasheet (surement pessimiste sont prises);
    
    %Un calcul de la r�sistance interne pourrait aussi �tre fait gr�ce �
    %des tests, pour l'instant une valeur moyenne du test 1 est choisie.
    
    %Le syst�me de fin de d�charge et fin de charge peut �tre am�lior�.

%% INPUTS
    %dt : intervale de temps du pas -min-
    %nSoCDebut : Etat de charge debut -%/100-
    %T : Temp�rature -�C-
    %jour : Jour actuelle de la mission
    %puiss : puissance que l'accumulateur doit fournir ou de recharge si n�gative -W-

%% OUTPUTS
    %nSoCFin : Etat de Charge en fin -%/100-
    %VoutFin : Tension de sortie de l'accu, -V-
    %Iout : Courant de sortie de l'accu, -A-


%% DONNEES - VARIABLES - PARAMETRES

    %% Donnees 
    
    %Donn�es Datasheet des Accu LithiumIon 18650 Samsung
    VaccuMin = 2.75;    % V
    VaccuNom = 3.63;    % V
    VaccuMax = 4.2;     % V
    capaMax = 2.6;     % Ah
    IrechMax = 2.6; %Courant de recharge maximum (A)
    IdechMax = 5.2; %Courant de decharge maximum (A)
    
    %Resistance interne de la pile (Ohm) valeur du test (voir Calcul_Rb
    %dans test accu) 0.135 
    Raccu = 0.20; 

    mTCapa = [-10 0.5; 0 0.8; 25 1; 40 0.8; 60 0.54]; %Matrice des donn�es de capacit� relative en fonction de la temperature (datasheet)
    mICapa = [-5.2 0.8; -2.6 0.9; -1.3 0.95; -0.52 1; 0.52 1; 1.3 0.95; 2.6 0.9; 5.2 0.8]; %Matrice des donn�es de capacit� relative en fonction du courant (datasheet)
    
    tauxMaxNdCMission = 0.8; %Taux de capacite en fin de mission (valeur prise avec marge par C�line Cenac, � tester ou consolider si possible)
    mNdCCapa = [1 1; 365 tauxMaxNdCMission]; %Matric des donn�es capa pour le nombre de cycles
    
    %% Variables globales
    global mVaccuSoC

    %% Tests parametres
    if T < 0 || T > 60
        error('Temperature en dehors des limites');
    end
    if jour < 1
        error('Jour inf�rieur � 1');
    end


%% FONCTION

    %% Calcul des tensions internes et du courant de l'accu

    %VaccuInterne est la tension de l'element actif (avant la resistance interne), calcul� � partir de la courbe 
    %caract�ristique de l'accumulateur (test 1)
    VaccuDebut = interp1(mVaccuSoC(:,1), mVaccuSoC(:,2), nSoCDebut, 'spline');

    % Iaccu est calcul� pour que Iaccu*Vout = P en sachant que Vout = Vaccu - Raccu*Iaccu
    % Si Iaccu est n�gatif on est en recharge, en d�charge si positif
    valeursI = roots([Raccu -VaccuDebut puiss]);
    Iaccu = valeursI(2);
        
    % Une fois I connu, la tension mesur�e en sortie de l'accu peut �tre calculee
    VoutDebut = puiss/Iaccu; 

    if Iaccu < -IrechMax
        error('Courant de charge trop important')
    elseif Iaccu > IdechMax
        error('Courant de decharge trop important')
    end
    if VoutDebut < VaccuMin
        error('Tension accu sous le seuil, batterie dechargee')
    elseif VaccuDebut > VaccuMax
        error('Tension accu sup�rieur a la valeur maximale')
    end


    %% Calcul des taux de capacite en fonction de la temperature, du courant et du nombre de cycle

    tauxT = interp1(mTCapa(:,1), mTCapa(:,2), T, 'linear');
    tauxI= interp1(mICapa(:,1), mICapa(:,2), Iaccu, 'linear');
    tauxNdC = interp1(mNdCCapa(:,1), mNdCCapa(:,2), jour, 'linear');

    tauxCapa = 1-((1-tauxT)+(1-tauxI)+(1-tauxNdC));

    if tauxT > 1 || tauxI > 1 || tauxNdC > 1 || tauxCapa > 1
        error('Un des rendements pile sup�rieur � 100% (voir les interpolations)')
    end

    capaTot = capaMax*tauxCapa;

    %Si la capacite totale change (les conditions d'utilisation changent), la capacit� restante change d'autant (le SoC reste identique)
    capaRest = capaTot*nSoCDebut;


    %% Calcul en fin de pas

    capaRestFin = capaRest - Iaccu*dt/60;
    nSoCFin = capaRestFin/capaTot;
    
    VaccuFin = interp1(mVaccuSoC(:,1), mVaccuSoC(:,2), nSoCFin, 'spline');
    VoutFin = VaccuFin - Raccu*Iaccu;
    
    %Si l'accumulateur est trop charg� on considere qu'il est charge � fond
    %Pas parfait car cela devrait lever une erreur de surcharge.
    if nSoCFin > 1
        nSoCFin = 1;
    end
    
    %Si la tension accu passe en dessous de la limite inf�rieur    
    if VoutFin < VaccuMin
        error('Tension accu sous le seuil, batterie dechargee')
    end
      
    Iout = Iaccu;


end


