% 1 IR 2 sig の場合
% 正しいサイズがわかった時にsigを復元できるか
fsResample = 8000;
flag_noise = 1;
fn1 = sprintf('./in_2sig/org_%d.wav', 1);
fn2 = sprintf('./in_2sig/org_%d.wav', 2);
[s1, fs] = audioread(fn1);
s1_resample = resample(s1(:,1), fsResample, fs, 100); % resampling for reducing computational cost
[s2, fs] = audioread(fn2);
s2_resample = resample(s2(:,1), fsResample, fs, 100); % resampling for reducing computational cost


% observation 1
len_ir1 = 64; %length of IR1
t = 0:len_ir1-1;
h1 = exp( -10*t/len_ir1 ) .* randn( size(t,1), 1);
yy1 = conv( s1_resample, h1);
yy2 = conv( s2_resample, h1);


P_noise = 100000;
n1 = rand( size(yy1) )/P_noise;
n2 = rand( size(yy2) )/P_noise;
y1 = yy1 + n1;
y2 = yy2 + n2;
% ノーマライズ
y1 = y1 / max( abs( y1 ) );
y2 = y2 / max( abs( y2 ) );


len_s1 = max( size( s1_resample ) );
len_s2 = max( size( s2_resample ) );
Y1 = convmtx( y1, len_s2 );
Y2 = convmtx( y2, len_s1 );
G = [Y1, Y2];
[ ~, S, V ] = svd( G );
sing = diag( S );

%{
% recovering sig2 no noise
if( flag_noise == 0 )
    sig2_hat = V(1:len_s2,end);
    sig2_hat = sig2_hat/max(abs(sig2_hat));
    figure
    subplot( 3,1,1 ); plot(sig2_hat);title('estimated signal')
    subplot( 3,1,3 ); plot(s2_resample);title('true signal')
else
    %}
