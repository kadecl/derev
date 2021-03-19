
fsResample = 8000;
T = 5; d = 2;
result = zeros( T, 1 );
ratio = zeros( T, 1 );

for k=1:1
    for kk = k+1:2
        % load and resample
        fn1 = sprintf('./in_2sig/org_%d.wav', k);
        fn2 = sprintf('./in_2sig/org_%d.wav', kk);
        [s1, fs] = audioread(fn1);
        s1_resample = resample(s1(:,1), fsResample, fs, 100); % resampling for reducing computational cost
        [s2, fs] = audioread(fn2);
        s2_resample = resample(s2(:,1), fsResample, fs, 100); % resampling for reducing computational cost
        
        
        % observation 1
        len_ir1 = 512; %length of IR1
        t = [0:len_ir1-1]/len_ir1;
        h1 = exp( -t/len_ir1 ) .* randn( size(t,1), 1);
        y1 = conv( s1_resample, h1);
        y1 = y1 / max( abs( y1 ) );
        y2 = conv( s2_resample, h1);
        y2 = y2 / max( abs( y2 ) );
        
        %{
        % 音程を変えただけだが極はバラけてくれるのか
         -> 音程が違うだけでもわりと極はばらけてくれる
        r1 = roots( s1_resample );
        r2 = roots( s2_resample );
        figure
        scatter( real( r1 ), imag( r1 ) , 'x');
        hold on
        scatter( real( r2 ), imag( r2 ) , '.');
        %}
        
        len_s1 = max( size( s1_resample ) );
        len_s2 = max( size( s2_resample ) );
        
        figure
        
        for i= 0:T-1
            j = i - d;
            Y1 = convmtx( y1, len_s2 - j );
            Y2 = convmtx( y2, len_s1 - j );
            G = [Y1, Y2];
            [ ~, S, V ] = svd( G );
            sing = diag( S );
            
            subplot(6,2,i*2+1)
            plot( V(1:len_s2,end) ); 
            title(sprintf('estimated signal corresponding to min. sing. val(%0.5g). l=%d',sing(end),j))
            subplot(6,2,i*2+2)
            plot( V(1:len_s2,end-1) );
            title(sprintf('estimated signal corresponding to 2nd min. sing. val.(%0.5g)l=%d',sing(end-1),j))
            
            %result(i+1) = sing(end);
            %if( i>0 )
            %    ratio( i+1 ) = ratio( i+1 ) +  result( i+1 ) / result( i );
            %end
        end
    end
end
subplot(6,2,11); plot(s2_resample); title('original signal (org2.wav)');
subplot(6,2,12); plot(y2); title(sprintf('convoluted signal (IR len = %d)', 512))

%{
ratio = ratio/(9*8/2);
ratio(1) = 1;
figure
subplot(2,1,1)
plot([-d:T-d-1], result, 'b*' );
title( sprintf('min sing val; IR = %d', len_ir1) );
subplot(2,1,2)
semilogy(-d:T-d-1, ratio);
title( 'ratio of minimum singular val.');
%}