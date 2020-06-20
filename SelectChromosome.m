function [ parents,flag ] = SelectChromosome( seeds_accumulate_probability,model,chromosome )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %每次选择2个不同染色体竞争
        flag=1;
       for j=1:2
       for i=1:2
       %根据概率随机选择一个为父
       select =rand;
       index(i) =1;
       while select > seeds_accumulate_probability(index(i)) && index(i) < model.NP
           index(i) =index(i)+1;
       end
       end
       if  chromosome(index(1)).cost <  chromosome(index(2)).cost
            parents(j) =  chromosome(index(1));
       else
            parents(j) =  chromosome(index(2));
       end
       
       end
    
    
     

end

