% load and resample
fsResample = 8000;
[sig, fs] = audioread('./input/piano_longrelease.wav');
sig_resample = resample(sig(1:fs,1), fsResample, fs, 100); % resampling for reducing computational cost
% r_sig = roots( sig_resample );

% observation 1
len_ir1 = 64; %length of IR1
x = (1:len_ir1)/10;
h1 = exp(x) .* randn( size(x,1), 1);
y1 = conv( sig_resample, h1);
y1 = y1 / max( abs( y1 ) );
% audiowrite( sprintf('./input/piano_long_con_ir%d.wav', len_ir1), y1, fsResample);

% observation 2
len_ir2 = len_ir1;
%a = exp( [0:-1:-len_ir2+1] ); b = randn(1,len_ir2);
% a = exp(x) .* randn( size(x,1), 1);
T = 13;
d = 3;
result = zeros( T, 1 );
figure

for k=1:3
    % observation 2
    h2 = [ zeros(1,5*k), h1 ];
    y2 = conv( sig_resample, h2);
    y2 = y2 / max( abs( y2 ) );
    len_ir2_hat = size( h2, 2 );
    for i= 0:T-1
        j = i - d;
        Y1 = convmtx( y1, len_ir2_hat - j );
        Y2 = convmtx( y2, len_ir1 - j );
        G = [Y1, Y2];
        [ ~, S, ~ ] = svd( G );
        sing = diag( S );
        result(i+1) = sing(end);
    end

    subplot(3,2,2*k-1)
    plot([-d:T-d-1], result, 'b*' );
    title( sprintf('min sing val; IR = %d, delay = %d', len_ir1, k*5) );

    % roots
    subplot(3,2,2*k)
    r_h1 = roots( h1 );
    r_h2 = roots( h2 );
    scatter( real(r_h1) , imag( r_h1 ) )
    hold on
    scatter( real(r_h2) , imag( r_h2 ) )
    %hold on
    %scatter( real(r_sig), imag(r_sig ) )
    title( sprintf('roots %d, %d', len_ir1, len_ir2_hat) );
end