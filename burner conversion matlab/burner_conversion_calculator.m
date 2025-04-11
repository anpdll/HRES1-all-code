function y = burner_conversion_calculator(x, a, b, c)
    EuroToDollar = 1.09; % as of 3/23/2024
    y = a * x.^b + c;
    y = y.*EuroToDollar;
end