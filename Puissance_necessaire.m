function [conso] = Puissance_necessaire(mode, margeI)
%Calcul la puissance du satellite pour un mode donné
        
    conso = PuissSolarPannel(mode, margeI)+PuissPowerCard(mode)+PuissAOCS(mode)+PuissOBDH(mode)+PuissPayload1(mode)+PuissPayload2(mode);

end

function [Conso1] = PuissSolarPannel(mode, margeI)
    
    if strcmp(mode, 'Veille')
        Conso1= 0;
    end
    if strcmp(mode, 'Eclipse')
        Conso1 = 0;
    end
    if strcmp(mode, 'Recharge')
        Conso1 = 0;
    end
    if strcmp(mode, 'MissionG')
        Conso1 = 0;
    end
    if strcmp(mode, 'MissionI')
        Conso1 = 0;
    end
    if strcmp(mode, 'Transmission')
        Conso1= 0;
    end
    
    
end

function [Conso2] = PuissPowerCard(Mode)
    if strcmp(Mode, 'Eclipse')
        Conso2 = 0.160*2;
    end
    if strcmp(Mode, 'Recharge')
        Conso2 = 0.160*2;
    end
    if strcmp(Mode, 'MissionG')
        Conso2 = 0.160*2;
    end
    if strcmp(Mode, 'MissionI')
        Conso2 = 0.160;
    end
    if strcmp(Mode, 'Veille')
        Conso2 = 0.160;
    end
    if strcmp(Mode, 'Transmission')
        Conso2 = 0.160;
    end
end

function [Conso3] = PuissAOCS(Mode)
    if strcmp(Mode, 'Eclipse')
        Conso3 = 0;
    end
    if strcmp(Mode, 'Recharge')
        Conso3 = 0;
    end
    if strcmp(Mode, 'MissionG')
        Conso3 = 0.8;
    end
    if strcmp(Mode, 'MissionI')
        Conso3 = 0.8;
    end
    if strcmp(Mode, 'Veille')
        Conso3 = 0;
    end
    if strcmp(Mode, 'Transmission')
        Conso3 = 2.2;
    end
end

function [Conso4] = PuissOBDH(Mode)
    if strcmp(Mode, 'Eclipse')
        Conso4 = 0.4;
    end
    if strcmp(Mode, 'Recharge')
        Conso4 = 0.4;
    end
    if strcmp(Mode, 'MissionG')
        Conso4 = 0.9;
    end
    if strcmp(Mode, 'MissionI')
        Conso4 = 0.8;
    end
    if strcmp(Mode, 'Veille')
        Conso4 = 0.5;
    end
    if strcmp(Mode, 'Transmission')
        Conso4 = 2.1;
    end
end

function [Conso5] = PuissPayload1(Mode)
    if strcmp(Mode, 'Eclipse')
        Conso5 = 0;
    end
    if strcmp(Mode, 'Recharge')
        Conso5 = 0;
    end
    if strcmp(Mode, 'MissionG')
        Conso5 = 4;
    end
    if strcmp(Mode, 'MissionI')
        Conso5 = 0;
    end
    if strcmp(Mode, 'Veille')
        Conso5 = 0;
    end
    if strcmp(Mode, 'Transmission')
        Conso5 = 0;
    end
end

function [Conso6] = PuissPayload2(Mode)
    if strcmp(Mode, 'Eclipse')
        Conso6 = 0;
    end
    if strcmp(Mode, 'Recharge')
        Conso6 = 0;
    end
    if strcmp(Mode, 'MissionG')
        Conso6 = 0;
    end
    if strcmp(Mode, 'MissionI')
        Conso6 = 3.8;
    end
    if strcmp(Mode, 'Veille')
        Conso6 = 0;
    end
    if strcmp(Mode, 'Transmission')
        Conso6 = 0;
    end
end