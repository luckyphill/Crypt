function phase = set_phase(cell)

    
   switch cell.age
       case cell.age < cell.g1_length
           phase = 'G1';
       case cell.age > cell.g1_length && cell.age < cell.g1_length + cell.s_length
           phase = 'S';
       case cell.age > cell.g1_length + cell.s_length && cell.age < cell.g1_length + cell.s_length + cell.g2_length
           phase = 'G2';
       case cell.age > cell.g1_length + cell.s_length + cell.g2_length
           phase = 'M';
       otherwise
           error('How did this error happen?')
   end
   
end