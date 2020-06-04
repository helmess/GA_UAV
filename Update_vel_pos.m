function [ vel,alpha,beta,T ] = Update_vel_pos( next_chromosome,model )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    w=1;
    c1=1.5;
    c2=1.5;
    vel=zeros(3,model.dim);
    alpha=zeros(model.dim,1);
    beta=zeros(model.dim,1);
    T=zeros(1,model.dim);
    %更新航偏角速度
    vel(1,:) =  w*next_chromosome.vel(1,:)+...
        c1*rand(1,model.dim).*(next_chromosome.best.alpha' - next_chromosome.alpha')+...
        c2*rand(1,model.dim).*(model.p_global.alpha' - next_chromosome.alpha');
    %更新俯仰角速度
     vel(2,:) =  w*next_chromosome.vel(2,:)+...
        c1*rand(1,model.dim).*(next_chromosome.best.beta' - next_chromosome.beta')+...
        c2*rand(1,model.dim).*(model.p_global.beta' - next_chromosome.beta');
    %跟新时间速度
    vel(3,:) =  w*next_chromosome.vel(3,:)+...
        c1*rand(1,model.dim).*(next_chromosome.best.T - next_chromosome.T)+...
        c2*rand(1,model.dim).*(model.p_global.T - next_chromosome.T);
    %速度约束
    vel_alpha_max =0.1*(model.alpha_max-model.alpha_min);
    vel_alpha_min =-vel_alpha_max;
    vel_beta_max =0.1*(model.beta_max-model.beta_min);
    vel_beta_min =-vel_beta_max;
    vel_T_max =0.1*(model.Tmax-model.Tmin);
    vel_T_min =-vel_T_max;
    %约束
    vel(1,:) =max(vel(1,:),vel_alpha_min);
    vel(1,:) =min(vel(1,:),vel_alpha_max);
    
    vel(2,:) =max(vel(2,:),vel_beta_min);
    vel(2,:) =min(vel(2,:),vel_beta_max);

    vel(3,:) =max(vel(3,:),vel_T_min);
    vel(3,:) =min(vel(3,:),vel_T_max);    
    %跟新alpha,beta,T
    alpha = next_chromosome.alpha + vel(1,:)';
    beta = next_chromosome.beta + vel(2,:)';
    T = next_chromosome.T + vel(3,:);
    
    
end

