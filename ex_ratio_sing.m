% load and resample
fsResample = 8000;
[sig, fs] = audioread('./input/piano_longrelease.wav');
sig_resample = resample(sig(1:fs,1), fsResample, fs, 100); % resampling for reducing computational cost


% observation 1
len_ir1 = 128; %length of IR1
x = (1:len_ir1)/10;
h1 = exp(x) .* randn( size(x,1), 1) + exp( [0:-1:-len_ir1+1]/(len_ir1) );
y1 = conv( sig_resample, h1);
y1 = y1 / max( abs( y1 ) );
% audiowrite( sprintf('./input/piano_long_con_ir%d.wav', len_ir1), y1, fsResample);

% observation 2
len_ir2 = len_ir1;
z = (1:len_ir2)/3;
a = exp(z) .* rand( size(z,1), 1);
delaySize = floor(10*rand(1,1));
h2 = [ zeros(1, delaySize), h1(1:end-delaySize) ] + h2;
y2 = conv( sig_resample, h2);
y2 = y2 / max( abs( y2 ) );
T = 13;
d = 3;
result = zeros( T, 1 );
ratio = zeros( T, 1 );

for i= 0:T-1
    j = i - d;
    Y1 = convmtx( y1, len_ir2 - j );
    Y2 = convmtx( y2, len_ir1 - j );
    G = [Y1, Y2];
    [ ~, S, ~ ] = svd( G );
    sing = diag( S );
    result(i+1) = sing(end);
    if( i>0 )
        ratio( i+1 ) = result( i+1 ) / result( i );
    end
end

figure
subplot(2,1,1)
plot([-d:T-d-1], result, 'b*' );
title( sprintf('min sing val; IR = %d', len_ir1) );
subplot(2,1,2)
plot([-d:T-d-1], ratio);
title( 'ratio of minimum singular val.');