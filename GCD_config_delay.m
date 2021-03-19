% load and resample
fsResample = 8000;
[sig, fs] = audioread('./input/piano_longrelease.wav');
sig_resample = resample(sig(1:fs,1), fsResample, fs, 100); % resampling for reducing computational cost

% observation 1
len_ir1 = 64; %length of IR1
x = (1:len_ir1)/10;
h1 = exp(x) .* randn( size(x,1), 1);
y1 = conv( sig_resample, h1);
y1 = y1 / max( abs( y1 ) );
audiowrite( sprintf('./input/piano_long_con_ir%d.wav', len_ir1), y1, fsResample);

% observation 2
len_ir2 = len_ir1;
h2 = exp( [0:-1:-len_ir2+1]/(len_ir2) );
% x = (1:len_ir2)/10;
% h2 = cos(x) .* randn( size(x,1), 1) + exp(x) .* randn( size(x,1), 1);;
% h2(1:4) = 0;
y2 = conv( sig_resample, h2);
y2 = y2 / max( abs( y2 ) );
audiowrite( sprintf('./input/piano_long_con_ir%s.wav', len_ir2), y2, fsResample);

T = 13;
d = 3;
result = zeros( T, 1 );
figure

for k=1:3
    for i= 0:T-1
        %j = (i-5) * 2;
        h2(1:k*5) = 0;
        y2 = conv( sig_resample, h2);
        y2 = y2 / max( abs( y2 ) );

        j = i - d;
        Y1 = convmtx( y1, len_ir2 - j );
        Y2 = convmtx( y2, len_ir1 - j );
        G = [Y1, Y2];
        [ ~, S, ~ ] = svd( G );
        [l, p] = size( S );
        q = min( l, p );
        result(i+1) = S( q, q );
    end

    subplot(3,2,2*k-1)
    plot([-d:T-d-1], result, 'b*' );
    title( sprintf('minimum singular value; IR len = %d, delay = %d', len_ir1, k*5) );

    % roots
    subplot(3,2,2*k)
    r_h1 = roots( h1 );
    r_h2 = roots( h2 );
    scatter( real(r_h1) , imag( r_h1 ) )
    hold on
    scatter( real(r_h2) , imag( r_h2 ) )
    title( sprintf('roots of h1=%d', len_ir1) );
end

%{
% IR estimation
Y1 = convmtx( y1, len_ir2 );
Y2 = convmtx( y2, len_ir1 );
G = [Y1, Y2];
[U,S,V] = svd(G);
v = V(len_ir1+len_ir2,:);
%h2_hat = v(1:len_ir2);
h1_hat = -v(len_ir2+1:end);
sig_hat = deconv( y1, h1 );

% normalize
z_hat = sig_hat / max( abs( sig_hat ) );
z = sig_resample / max( abs( sig_resample ) );

% plot
figure
subplot( 4,1,1); plot(z);
title( 'dry' );
subplot( 4,1,2); plot(y1(1:fsResample));
title( 'インパルス応答1を通した観測' );
subplot( 4,1,3); plot(y2(1:fsResample));
title( 'インパルス応答2を通した観測');
subplot( 4,1,4); plot(z_hat);
title( sprintf('recovered signal snr=%f', snr( z, z_hat-z )) );

audiowrite(sprintf('./input/piano_long_recov.wav'), z_hat, fsResample);
%}