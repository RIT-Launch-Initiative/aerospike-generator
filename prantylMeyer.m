function [PM] = prantylMeyer(gam,M)
    % Outputs in DEGREES
    term1 = sqrt( (gam+1)/(gam-1) );
    term2 = atand( sqrt( ((gam-1)/(gam+1))*(M.^2 - 1) ) );
    term3 = atand( sqrt(M.^2 - 1) );

    PM = term1.*term2-term3;
end

