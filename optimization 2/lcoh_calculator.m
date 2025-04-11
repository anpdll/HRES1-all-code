function [lcoh]= lcoh_calculator(r,Stack_dr,N, Capex, Opex, mh2_year)

%defining symbolic variable
syms n

% Making LCOH Equation
one = symsum(Opex./((1+r).^n),n,1,N);
two = symsum((mh2_year.*((1-Stack_dr).^n))./((1+r).^n),n,1,N);
lcoh = (Capex + one)./two;

lcoh = vpa(subs(lcoh),3);  % subs converts symbolic result to numeric, vpa roundoff to 3 decimal place
end