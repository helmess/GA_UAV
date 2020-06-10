clc;
clear;
close all;
tic;
model =CreateModel();
plotmap(model);
Algrithm_Choose(model);
toc;





% for i=4: (numel(m_x)-1)
%    startp=[300 800 280];
%    endp =[700 350 260];
%     %GAPSO(startp,endp,model);
%     Algrithm_Choose(startp,endp,model);
%     %state_prob=[state_prob,Global_Chromosome(i).sol.MarkovState];
% end
% state_bar =figure(2);
% b=bar(state_prob','stack');
% legend('U','D','T','E','H');m_y
% b(1).FaceColor='w';b(2).FaceColor='y';b(3).FaceColor='m';b(4).FaceColor='r';b(5).FaceColor='k';
toc;


