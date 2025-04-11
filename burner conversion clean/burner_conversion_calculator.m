function y = burner_conversion_calculator(x, a, b, c)
    EuroToDollar = 1.26; % as of 4/7/2024
    y = max(0,a * x.^b + c);
    y = y.*EuroToDollar;
end

1.26*(a * x.^b + c)