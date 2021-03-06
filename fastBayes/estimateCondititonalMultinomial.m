function logPr_ItemInCategory = estimateCondititonalMultinomial(R, Pr_UratedC, priorC)
    Nitems = size(R,2);     %number of items
    Nusers = size(R,1);       %number of users
    Ncategories = size(Pr_UratedC, 2);  %number of genres

    available_memory = 2^30; %30
    
    div_coef = ceil(size(R,1) * size(R,2) * 8  / available_memory);
    Nusers_part = floor(Nusers/div_coef);
    
    % Estimate conditional probability of Item i given Class c
    logPr_ItemInCategory = zeros(Nitems, Ncategories); % allocate memory
    for c = 1:Ncategories
        %[r, c]
        logPr_ItemInCategory_part = 0;
        for j = 1:div_coef - 1
            %Rt = full(R_temp(((j - 1) * Nusers_part + 1):(j * Nusers_part), :)); % in case then data is too large 
            sliceOfUsers = ((j - 1) * Nusers_part + 1):(j * Nusers_part);
            Rt = R(sliceOfUsers, :);
            logPr_UratedC_temp_vec = log(Pr_UratedC(sliceOfUsers, c));
            logPr_ItemInCategory_part = logPr_ItemInCategory_part + sum(bsxfun(@times, Rt, logPr_UratedC_temp_vec));
        end
        %process the remainder part that is smaller than the block size Nusers_part
        sliceOfUsers = ((div_coef - 1) * Nusers_part + 1):Nusers;
        Rt = R(sliceOfUsers, :);
        logPr_UratedC_temp_vec = log(Pr_UratedC(sliceOfUsers, c));
        logPr_ItemInCategory(:, c) = logPr_ItemInCategory_part + sum(bsxfun(@times, Rt, logPr_UratedC_temp_vec));
    end
end
