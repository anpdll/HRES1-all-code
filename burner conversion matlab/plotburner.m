load('ceramics.mat');
load("chemical.mat");
load("fandd.mat");
load("glass.mat");
load("vehicle.mat");


x = linspace(0, 60, 500);

ceramics = burner_conversion_calculator(x, ceramicsfit.a, ceramicsfit.b, ceramicsfit.c);
plot(x, ceramics)

hold on

chemical = burner_conversion_calculator(x, chemicaldryersfit.a, chemicaldryersfit.b, chemicaldryersfit.c);
plot(x, chemical)

glass = burner_conversion_calculator(x, glassfit.a, glassfit.b, glassfit.c);
plot(x, glass)

vehicle = burner_conversion_calculator(x, vehiclemanfit.a, vehiclemanfit.b, vehiclemanfit.c);
plot(x, vehicle)


fandd = burner_conversion_calculator(x, fanddfit.a, fanddfit.b, fanddfit.c);
plot(x, fandd)

hold off

