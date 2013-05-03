% Profiler extension for Sliding-Window Kernel Recursive Least Squares
% Author: Steven Van Vaerenbergh, 2013
%
% This file is part of the Kernel Adaptive Filtering Toolbox for Matlab.
% http://sourceforge.net/projects/kafbox/

classdef swkrls_profiler < swkrls
    
    methods
        
        function flops = lastflops(kaf) % flops for last iteration
            m = size(kaf.dict,1);
            if ~kaf.prune
                m1 = m;
                m2 = m - 1;
                floptions = struct(...
                    'sum', m2^2 + m2^2 - m2 + m2^2 + m^2 - m, ...
                    'mult', m2^2 + m2 + m2^2 + m^2, ...
                    'div', 1, ...
                    'kernel', [kaf.kerneltype,m1,size(kaf.dict,2)]);
            else
                m1 = m + 1;
                m2 = m;
                m3 = m;
                floptions = struct(...
                    'sum', m2^2 + m2^2 - m2 + m2^2 + m3^2 + m^2 - m, ...
                    'mult', m2^2 + m2 + m2^2 + m3^2 + m3 + m^2, ...
                    'div', 1 + 1, ...
                    'kernel', [kaf.kerneltype,m1,size(kaf.dict,2)]);
            end

            flops = kflops(floptions);
        end
        
        %% flops breakdown
        
        % k = kernel(kaf.dict,x,kaf.kerneltype,kaf.kernelpar); % grow Kinv
        % kernel: m1
        
        % d = k(end) + kaf.c; % grow Kinv
        % sum: 1
        
        % g_inv = d - b'*kaf.Kinv*b; % grow Kinv
        % sum: m2^2
        % mult: m2^2 + m2
        
        % g = 1/g_inv; % grow Kinv
        % div: 1
        
        % f = -kaf.Kinv*b*g; % grow Kinv
        % sum: m2^2 - m2
        % mult: m2^2 + m2
        
        % E = kaf.Kinv - kaf.Kinv*b*f'; % grow Kinv
        % sum: m2^2
        % mult: m2^2
        
        % kaf.Kinv = G - f*f'/e; % prune Kinv
        % sum: m3^2
        % mult: m3^2 + m3
        % div: 1
        
        % kaf.alpha = kaf.Kinv*kaf.dicty; % end of training
        % sum: m^2 - m
        % prod: m^2
        
        %%
        
        function bytes = lastbytes(kaf) % bytes used in last iteration
            m = size(kaf.dict,1);
            bytes = 8*m*(m + 2 + size(kaf.dict,2)); % 8 bytes for double precision
        end
        
    end
end
