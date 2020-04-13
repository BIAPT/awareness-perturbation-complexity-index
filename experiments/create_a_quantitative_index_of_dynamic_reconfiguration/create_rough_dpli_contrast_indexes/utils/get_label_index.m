function [label_index] = get_label_index(label, location)
    label_index = 0;
    for i = 1:length(location)
       if(strcmp(label,location{i}))
          label_index = i;
          return
       end
    end
end