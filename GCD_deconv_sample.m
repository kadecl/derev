% load and resample
fsResample = 16000;
[sig, fs] = audioread('./input/strings_dry.wav');
sig_resample = resample(sig(1:fs,1), fsResample, fs, 100); % resampling for reducing computational cost

% observation 1
len_ir1 = 1260; %length of IR1
h1 = exp( [0:-1:-len_ir1+1]/(len_ir1) );
y1 = conv( sig_resample, h1);
y1 = y1 / max( abs( y1 ) );
len_ir_str = sprintf('%d', len_ir1);
audiowrite(sprintf('./input/string_con_ir%s.wav', len_ir_str), y1, fsResample);

% observation 2
len_ir2 = 1980;
h2 = exp( [0:-1:-len_ir2+1]/(len_ir2) );
h2(1:15) = 0;
y2 = conv( sig_resample, h2);
y2 = y2 / max( abs( y2 ) );
len_ir_str = sprintf('%d', len_ir2);
audiowrite(sprintf('./input/string_con_ir%s.wav', len_ir_str), y2, fsResample);

% IR estimation
Y1 = convmtx( y1, len_ir2 );
Y2 = convmtx( y2, len_ir1 );
G = [Y1, Y2];
%{
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

audiowrite(sprintf('./input/string_recov.wav'), z_hat, fsResample);
%}