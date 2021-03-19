% 1 IR 2 sig の場合
% G = LU と分解したときにLとUのランクを調べる
fsResample = 8000;
fn1 = sprintf('./in_2sig/org_%d.wav', 4);
fn2 = sprintf('./in_2sig/org_%d.wav', 6);
[s1, fs] = audioread(fn1);
s1_resample = resample(s1(:,1), fsResample, fs, 100); % resampling for reducing computational cost
[s2, fs] = audioread(fn2);
s2_resample = resample(s2(:,1), fsResample, fs, 100); % resampling for reducing computational cost
flag = 2;

% observation 1
len_ir1 = 64; %length of IR1
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

[L, U] = lu( G );
NullOfU = null( U );
[Q, R] = qr( G );
NullOfR = null( R );
figure
subplot(2,1,1)
plot( NullOfU )
title( 'Null( U )' )
subplot(2,1,2)
plot( NullOfR )
title( 'Null( R )' )