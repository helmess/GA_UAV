clc;
clear;
close all;

model =CreateModel();
plotmap(model);
startp =[model.sx,model.sy,model.sz];
endp=[model.ex,model.ey,model.ez];
Algrithm_Choose(startp,endp,model);


miss_seq =[1 3 4 2 5];
m_x=[model.sx,model.mission_x,model.ex];
m_y=[model.sy,model.mission_y,model.ey];
m_z=[model.sz,model.mission_z,model.ez];
tic;
state_prob=[];


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


