function [ parents,flag ] = SelectChromosome( seeds_accumulate_probability,model,chromosome )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %每次选择2个不同染色体
    
   
     
       %根据概率随机选择一个为父
       select =rand;
       index =1;
       while select > seeds_accumulate_probability(index) && index < model.NP
           index =index+1;
       end
       parents(1) = chromosome(index);
       %根据概率随机选择一个为母
       select =rand;
       index =1;
       while select > seeds_accumulate_probability(index) && index < model.NP
           index =index+1;
       end
       parents(2) = chromosome(index);
       %选择后比较两者染色体是否一样,为了简单起见之比较适应度值
       if parents(1).cost == parents(2).cost
           flag =0;
       else
           flag =1;
       end
    
     

end

