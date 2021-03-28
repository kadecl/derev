function M = LowRankMtx( row, col, rank )
% 低ランク行列をランダム行列から作成する

M = rand( row, rank ) * rand( rank, col );