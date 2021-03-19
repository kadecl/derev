% 畳み込み行列を横に並べたものの特異値特異ベクトルの摂動解析
fsResample = 8000;
flag_noise = 1;
fn1 = sprintf('./in_2sig/org_%d.wav', 1);
fn2 = sprintf('./in_2sig/org_%d.wav', 2);
[s1, fs] = audioread(fn1);
s1_resample = resample(s1(:,1), fsResample, fs, 100); % resampling for reducing computational cost
[s2, fs] = audioread(fn2);
s2_resample = resample(s2(:,1), fsResample, fs, 100); % resampling for reducing computational cost
len_s1 = max( size( s1_resample ) );
len_s2 = max( size( s2_resample ) );

% observation 1
len_ir1 = 64; %length of IR1
t = 0:len_ir1-1;
h1 = exp( -10*t/len_ir1 ) .* randn( size(t,1), 1);
y1 = conv( s1_resample, h1);
y2 = conv( s2_resample, h1);

Y1 = convmtx( y1, len_s2 );
Y2 = convmtx( y2, len_s1 );
G0 = [Y1, Y2];
[ ~, S, V ] = svd( G0 );
sing = diag( S );
s0 = sing( end ); %min sing val
u0 = V(:,end);    %min sing vector
sing_pair = [s0, norm( u0 )];
sprintf("%f: minimum singular val. of G_0", s0)

% additive noise
P_noise = 10;
n1 = rand( size(y1) )/P_noise;
n2 = rand( size(y2) )/P_noise;

ret = zeros(10,2);
snratio = zeros(10,1);
for i=1:10
    P_noise = P_noise * 10;
    n1 = n1 / 10;
    n2 = n2 / 10;
    N = [convmtx( n1, len_s2), convmtx( n2, len_s1 ) ];
    ret(i,:) = d_sing( u0, G0, N ) ./ sing_pair; 
    snratio(i) = 20* ( log10(norm(s1)) - log10(norm(n1)) );
end
figure
subplot( 2,1,1 ); semilogy(snratio, ret(:,1));
title("Diff of sing. val."); xlabel("snr");
subplot( 2,1,2 ); semilogy(snratio, ret(:,2)); 
title("Diff of sing. vec (norm)."); xlabel("snr");

function d = d_sing( u0, G0, N )
% 特異値と特異ベクトルの微分を計算する
 T = ( G0' + N' ) * N;
 d_l = u0'*T*u0;
 d_u = norm( pinv( G0'*G0 ) * T * u0 );
 d = [d_l, d_u];
end