clc;
clear;
close all;

model =CreateModel();
plotmap(model);
miss_seq =[1 3 4 2 5];
m_x=[model.sx,model.mission_x,model.ex];
m_y=[model.sy,model.mission_y,model.ey];
m_z=[model.sz,model.mission_z,model.ez];
tic;
for i=1: (numel(m_x)-1)
   startp=[m_x(miss_seq(i)),m_y(miss_seq(i)),m_z(miss_seq(i))];
   endp =[m_x(miss_seq(i+1)),m_y(miss_seq(i+1)),m_z(miss_seq(i+1))];
   Global_Chromosome(i)=GA_Run(startp,endp,model);
end

toc;



