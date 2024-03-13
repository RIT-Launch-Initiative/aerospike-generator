function [AR] = areaRatio(gam,M)
    % term1=(gam+1)/(2*(gam-1));
    % AR = ((gam+1)./2).^(-term1).*(1+((gam-1)./2).*M.^2).^(term1).*(1./M);

    AR = 1./M .* ( (2/(gam+1)).* (1+ ((gam-1)/2).*M.^2)).^((gam+1)/(2.*(gam-1)));
end

