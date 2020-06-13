clc;
clear;
close all;
tic;
model =CreateModel();
plotmap(model);
startp =[model.sx,model.sy,model.sz];
endp=[model.ex,model.ey,model.ez];
% 
 Algrithm_Choose(startp,endp,model);

m_x=[model.sx,model.mission_x,model.ex];
m_y=[model.sy,model.mission_y,model.ey];
m_z=[model.sz,model.mission_z,model.ez];



% for i=2: (numel(m_x)-1)
%    startp=[m_x(i),m_y(i),m_z(i)];
%    endp =[m_x(i+1),m_y(i+1),m_z(i+1)];
%     %GAPSO(startp,endp,model);
%     Algrithm_Choose(startp,endp,model);
%     %state_prob=[state_prob,Global_Chromosome(i).sol.MarkovState];
% end
toc;
% state_bar =figure(2);
% b=bar(state_prob','stack');
% legend('U','D','T','E','H');m_y
% b(1).FaceColor='w';b(2).FaceColor='y';b(3).FaceColor='m';b(4).FaceColor='r';b(5).FaceColor='k';
toc;


