% Time-series prediction with a kernel adaptive filtering algorithm.
% Author: Steven Van Vaerenbergh, 2013
%
% This file is part of the Kernel Adaptive Filtering Toolbox for Matlab.
% http://sourceforge.net/projects/kafbox/

close all;
clear all;

%% PARAMETERS
% Instructions: 1. Uncomment one datafile and one kaf algorithm; 2. Execute.

datafile = 'lorenz.dat'; L = 6; horizon = 1; % 10000 points
% kaf = krlst(struct('lambda',1,'M',100,'sn2',1E-6,'kerneltype','gauss','kernelpar',32)); % achieves -65.07 dB
% kaf = fbkrls(struct('lambda',1E-6,'M',100,'kerneltype','gauss','kernelpar',32)); % achieves -54.71 dB
% kaf = kapcc(struct('mu0',0.995,'eta',0.95,'eps',1E-6,'p',8,'kerneltype','gauss','kernelpar',32)); % achieves -40.40 dB
kaf = aldkrls(struct('nu',1E-4,'kerneltype','gauss','kernelpar',32)); % achieves -40.17 dB
% kaf = swkrls(struct('c',1E-6,'M',100,'kerneltype','gauss','kernelpar',32)); % achieves -37.85dB
% kaf = exkrls(struct('alphaf',1,'beta',.99,'lambda',1E-6,'q',1E-6,'M',500,'kerneltype','gauss','kernelpar',32)); % achieves -22.48 dB
% kaf = qklms(struct('eta',0.6,'epsu',2,'kerneltype','gauss','kernelpar',32)); % achieves -10.73 dB
% kaf = klms(struct('eta',0.1,'M',5000,'kerneltype','gauss','kernelpar',32)); % achieves -3.07 dB
% kaf = knlmscc(struct('mu0',0.9,'eta',0.5,'eps',1E-6,'kerneltype','gauss','kernelpar',32)); % achieves -1.17 dB
% kaf = norma(struct('lambda',1E-4,'tau',500,'eta',0.1,'kerneltype','gauss','kernelpar',32)); % achieves 10.96 dB

% datafile = 'mg30.dat'; L = 11; horizon = 1; % 5000 points
% kaf = aldkrls(struct('nu',5E-3,'kerneltype','gauss','kernelpar',.6)); % achieves -45.61 dB
% kaf = krlst(struct('lambda',1,'M',200,'sn2',1E-5,'kerneltype','gauss','kernelpar',.6)); % achieves -44.26 dB
% kaf = fbkrls(struct('lambda',1E-6,'M',200,'kerneltype','gauss','kernelpar',.6)); % achieves -41.09 dB
% kaf = swkrls(struct('c',1E-6,'M',200,'kerneltype','gauss','kernelpar',.6)); % achieves -35.43 dB
% kaf = norma(struct('lambda',1E-2,'tau',500,'eta',0.5,'kerneltype','gauss','kernelpar',.6)); % achieves -20.08 dB

% datafile = 'santafe.dat'; L = 20; horizon = 1;
% kaf = krlst(struct('lambda',1,'M',100,'sn2',1E-5,'kerneltype','gauss','kernelpar',100)); % achieves 15.83 dB
% kaf = aldkrls(struct('nu',9E-1,'kerneltype','gauss','kernelpar',50)); % achieves 22.06 dB
% kaf = fbkrls(struct('lambda',1E-5,'M',150,'kerneltype','gauss','kernelpar',50)); % achieves 23.68 dB
% kaf = knlmscc(struct('mu0',.1,'eta',0.5,'eps',1E-6,'kerneltype','gauss','kernelpar',50)); % achieves 27.36 dB

%% PROGRAM
tic

data = load(datafile); data = data(:); N = length(data)-horizon;
X = zeros(N,L);
for i = 1:L, X(i:N,i) = data(1:N-i+1); end % time embedding
Y = data(1+horizon:N+horizon); % desired output

fprintf(1,'Running prediction algorithm')
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
