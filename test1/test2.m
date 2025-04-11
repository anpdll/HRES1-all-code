limit = 2;
num1 = 6;
num2 = 6;
diff = num1 - num2;
num1 = max(diff, limit);
diff = num1 == limit ? num2 - limit : diff;

