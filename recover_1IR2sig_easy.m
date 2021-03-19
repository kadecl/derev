% 1 IR 2 sig の場合
% 正しいサイズがわかった時にsigを復元できるか
fsResample = 16000;
%fn1 = sprintf('./in_2sig/org_%d.wav', 4);
%fn2 = sprintf('./in_2sig/org_%d.wav', 6);
fn1 = './in_2sig/trp_2.wav';
fn2 = './in_2sig/synth_1.wav';
[s1, fs] = audioread(fn1);
s1_resample = resample(s1(:,1), fsResample, fs, 100); % resampling for reducing computational cost
[s2, fs] = audioread(fn2);
s2_resample = resample(s2(:,1), fsResample, fs, 100); % resampling for reducing computational cost
flag = 2;

% observation 1
len_ir1 = 1200; %length of IR1
t = 0:len_ir1-1;
h1 = exp( -10*t/len_ir1 ) .* randn( size(t,1), 1);
y1 = conv( s1_resample, h1);
y1 = y1 / max( abs( y1 ) );
y2 = conv( s2_resample, h1);
y2 = y2 / max( abs( y2 ) );

len_s1 = max( size( s1_resample ) );
len_s2 = max( size( s2_resample ) );
Y1 = convmtx( y1, len_s2 );
Y2 = convmtx( y2, len_s1 );
G = [Y1, Y2];

% recovering (svd)
tic
%[ ~, S, V ] = svd( G );
sig_hat = null( G );
toc
%sing = diag( S );
%disp( sing(end) );


% recovering (LU decomposition)
tic
[L,U] = lu( G);
sig_hat2 = nullOfU( U );
toc

sig_hat = sig_hat / max(abs(sig_hat));
sig_hat2 = sig_hat2 / max(abs(sig_hat2));
figure
subplot( 3,1,1 );plot(sig_hat);title('estimated signal using svd')
subplot( 3,1,2 );plot(sig_hat2);title('estimated signal using LU')
subplot( 3,1,3 ); plot([s2_resample;s1_resample]);title('true signal')
