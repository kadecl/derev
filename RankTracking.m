% load and resample
fsResample = 8000;
flag = 0; % 1でsvd, 0でLU
if( flag )
    fprintf( "rank tracking using SVD\n" );
else
    fprintf( "rank tracking using LU decomposition\n" );
end

% IRの長さの設定
len_ir1 = 512; %length of IR1
len_ir2 = len_ir1;
t = 0:len_ir1-1;
% 結果を格納する場所
T = 15; d = 5;
list = dir('in_2sig/*.wav');
num_data = length( list );
result = zeros( T, num_data );
ratio = ones( T, num_data );

for k=1:num_data
    % audio read
    filename = "in_2sig/" + list(k).name;
    [sig, fs] = audioread( filename );
    sig_resample = resample(sig(:,1), fsResample, fs, 100); % resampling for reducing computational cost
    
    % observation 1
    h1 = exp( -10*t/len_ir1 ) .* randn( size(t,1), 1);
    y1 = conv( sig_resample, h1);
    y1 = y1 / max( abs( y1 ) );
    
    % observation 2
    h2 = -exp( -5*t/len_ir1 )*rand().*sin(2*t);
    y2 = conv( sig_resample, h2);
    y2 = y2 / max( abs( y2 ) );
    
    for i= 0:T-1
        j = i - d;
        Y1 = convmtx( y1, len_ir2 - j );
        Y2 = convmtx( y2, len_ir1 - j );
        G = [Y1, Y2];
        if( flag == 1 )
            [~,S,~] = svd( G );
            singValue = diag( S );
            result(i+1,k) = singValue(end);
        else
            [~,U] = lu( G );
            result(i+1,k) = U(end,end);
        end
        if( i>0 )
            ratio( i+1,k ) = abs(result( i+1,k ) / result( i,k ));
        end
    end
end

figure
subplot(2,1,1)
plot([-d:T-d-1], result, 'b*' );
title( sprintf('last pivot of U; IR = %d', len_ir1) );
subplot(2,1,2)
semilogy([-d:T-d-1], ratio);
title( 'ratio of last pivot.');

%{
メモ
このやり方だと，ランクが二以上落ちてる行列では
最初の0pivot以降誤差がどんどん溜まっていくので
last pivotが0で亡くなるのは当然である．
pivotが0になった段階で処理を止めて，ランクがいくつ
落ちているかを調べるという方法がいいかも

大体のサイズをlu分解もどきで探って
正確なサイズを決定する時はSVD使うのは良さそう
%}