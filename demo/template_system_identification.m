% Online system identification with a kernel adaptive filtering algorithm.
% Author: Steven Van Vaerenbergh, 2013
%
% This file is part of the Kernel Adaptive Filtering Toolbox for Matlab.
% http://sourceforge.net/projects/kafbox/

close all;
clear all;

%% PARAMETERS
% Instructions: 1. Uncomment one datafile and one algorithm; 2. Execute.

datafile = 'mimotestbed8K.dat'; L = 4; N = 8000;
kaf = swkrls(struct('c',0.015,'M',70,'kerneltype','gauss','kernelpar',3.1));
% kaf = norma(struct('lambda',1E-4,'tau',500,'mu',0.1,'kerneltype','gauss','kernelpar',3));

%% PROGRAM
tic

data = load(datafile); % input and output data are 2 columns
x = data(1:N,1); X = zeros(N,L);
for i = 1:L, X(i:N,i) = x(1:N-i+1); end % time-embedding
Y = data(:,2); % desired output

fprintf(1,'Running system identification algorithm')
Y_est = zeros(N,1);
for i=1:N,
    if ~mod(i,floor(N/10)), fprintf('.'); end
    
    Y_est(i) = kaf.evaluate(X(i,:)); % make prediction
    kaf = kaf.train(X(i,:),Y(i)); % train
end
fprintf('\n');

SE = (Y-Y_est).^2; % test error

toc
%% OUTPUT

fprintf('MSE after first 1000: %.2fdB\n\n',10*log10(mean(SE(1001:end))));

figure; plot(10*log10(SE)); xlabel('samples'); ylabel('squared error (dB)');
title(sprintf('%s on %s',upper(class(kaf)),datafile));

figure; hold all; plot(Y); plot(Y_est);
legend('original','prediction');
title(sprintf('%s on %s',upper(class(kaf)),datafile));