function [f_matrix] = filter_matrix(matrix, location, new_location)
    num_channels = length(new_location);
    
    good_index = zeros(1, num_channels);
    for l = 1:length(new_location)
        label = new_location{l};
        
        m_index = get_label_index(label, location);
        
        good_index(l) = m_index;
    end
    
    f_matrix = matrix(good_index, good_index);
end