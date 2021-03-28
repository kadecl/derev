function [L,U,P,sgn,rank] = myRank( A, myEps )

switch nargin
    case 1
        myEps  = 1.0e-13;
end        

[r,c] = size( A );
P = eye(r,r);
L = vpa(zeros(r,r));
U = vpa(A);
sgn = 1;
rank = min(r,c);

for i=1:rank %行と列のうち小さい方という意味．
    % search max pivot
    % ここfindmaxとかでk書き換えられるはず
    maxval = abs( U(i,i) );
    maxpos = i;
    for j=i+1:c
        % i列において、i行以降で絶対値が最大の場所を探し、
        % そのインデックスを maxpos に格納
        if (maxval < abs(U(i,j)))
            maxpos = j;
        end
    end
    
    % ランク落ちしている場合の対処
    if maxval < myEps
        rank = i-1;
        fprintf( "rank(A) = %d\n", rank );
        warning( "input matrix is  singular" )
        return
    end
    
    % row exchange
    if( maxpos ~= i )
        % U, P, L のそれぞれで、所定の行交換
        vec_exchange = [i,j];
        P(vec_exchange,:) = P(vec_exchange([2,1]),:);
        U(vec_exchange,:) = U(vec_exchange([2,1]),:);
        L(vec_exchange,:) = L(vec_exchange([2,1]),:);
        % https://jp.mathworks.com/matlabcentral/answers/493271-swapping-rows-in-a-matrix
        % sg の符号を反転
        sgn = sgn * -1;
    end
    
    % elimination
    pivot = U(i,i);
    if( abs( pivot ) < myEps )
        return;
    end
    
    for j=i+1:r
        L(j,i) = U(j,i) / pivot;
        U(j,:) = U(j,:) - L(j,i) * U(i,:);
    end
    
end
% 行交換のときに邪魔になるので、L の対角要素(1)は
% 最後に付加する。(Pの行交換を工夫すれば、最初から
% 対角要素に1を入れておくことも可能)
L = L + eye(r,r);

end
