% load and resample
fsResample = 8000;
[sig, fs] = audioread('./input/strings_dry.wav');
sig_resample = resample(sig(1:fs,1), fsResample, fs, 100); % resampling for reducing computational cost

% IRの長さの設定
len_ir1 = 256; %length of IR1
len_ir2 = len_ir1;
t = 0:len_ir1-1;
% 結果を格納する場所
T = 5; d = 2;
result = zeros( T, 1 );
ratio = zeros( T, 1 );

for k=1:1
    % observation 1
    h1 = exp( -10*t/len_ir1 ) .* randn( size(t,1), 1);
    y1 = conv( sig_resample, h1);
    y1 = y1 / max( abs( y1 ) );
    
    % observation 2
    %h2 = -exp( -10*t/len_ir1 ).*sin(2*pi*t);
    h2 = -exp( -5*t/len_ir1 )*rand().*sin(2*t);
    y2 = conv( sig_resample, h2);
    y2 = y2 / max( abs( y2 ) );
    
    for i= 0:T-1
        j = i - d;
        Y1 = convmtx( y1, len_ir2 - j );
        Y2 = convmtx( y2, len_ir1 - j );
        G = [Y1, Y2];
        [ ~, S, ~ ] = svd( G );
        sing = diag( S );
        result(i+1) = sing(end);
        if( i>0 )
            ratio( i+1 ) = ratio(i+1) + result( i+1 ) / result( i );
        end
    end
end

ratio(1) = 1;
figure
subplot(2,1,1)
plot([-d:T-d-1], result, 'b*' );
title( sprintf('min sing val; IR = %d', len_ir1) );
subplot(2,1,2)
semilogy([-d:T-d-1], ratio);
title( 'ratio of minimum singular val.');