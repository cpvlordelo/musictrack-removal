load 'mixture1.mat'

x1 = initialSample;
x2 = finalSample;


y1 = delay{1};
y2 = y1 + (x2-x1);

figure;
plot([x1 x2], [y1 y2], 'k');
hold on;

x1_e = est_initialSample;
x2_e = est_finalSample;

y1_e = est_delay;
y2_e = y1_e + (x2_e - x1_e);
plot([x1_e x2_e],[y1_e, y2_e],'y');

%y2 = delay{2};
%y3 = delay{3};

%x1_e = est_delay