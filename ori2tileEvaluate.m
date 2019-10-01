function [TP, TN, FP, FN] = ori2tileEvaluate(yaw_orig, pitch_orig, yaw_pred, pitch_pred)

% ori2tile_test constant definition
W = 3840;
H = 1920;
delta_phi = 100;  % yaw
delta_theta = 100;  % pitch
delta_h = H*delta_phi/180;
delta_w = W*delta_theta/360;
circle_r = delta_h/2;
h = [96, 96];  % the size of each spatial tile
correction = 1;  % correction coefficient, for determining if the tile is covered by FoV

TP = 0;  % True Positive
TN = 0;  % True Negative
FP = 0;  % False Positive
FN = 0;  % False Negative
nullCount = 0;
tile_Distrib_orig = zeros(10, 20);
if (pitch_orig>90) || (pitch_orig<-90)  % ignore the outliers
    nullCount = nullCount+1;
else
    % transfer from (yaw, pitch) to plane coordinate (w, h)
    w_center = W * (yaw_orig + 180)/360;
    h_center = H * (pitch_orig + 90)/180;
    circle_center = [w_center, h_center];

    % outer square
    w_min = w_center - circle_r;
    w_max = w_center + circle_r;
    h_min = h_center - circle_r;
    h_max = h_center + circle_r;

    h_start = max(1, ceil(h_min/192));
    h_end = min(ceil(h_max/192), 10);
    % circle is in the ERP canvas
    if (w_max < W) && (w_min > 0)
        w_start = ceil(w_min/192);
        w_end = ceil(w_max/192);
        for i = h_start : h_end
            for j = w_start : w_end
                current_test = [96+192*(j-1), 96+192*(i-1)];
                v = abs(circle_center - current_test);
                u = max(v-h, 0);
                judge = correction * dot(u, u) <= circle_r * circle_r;
                if judge==1
                    tile_Distrib_orig(i, j) = 1;
                end
            end
        end
    end

    % circle exceeds left
    if w_min < 0
        w1_start = 1;
        w1_end = ceil(w_max/192);
        for i = h_start : h_end
            for j = w1_start : w1_end
                current_test = [96+192*(j-1), 96+192*(i-1)];
                v = abs(circle_center - current_test);
                u = max(v-h, 0);
                judge = correction * dot(u, u) <= circle_r * circle_r;
                if judge==1
                    tile_Distrib_orig(i, j) = 1;
                end
            end
        end

        % calculation in compensation circle
        circle_center2 = [w_center+W, h_center];
        w2_start = ceil((w_min+W)/192);
        w2_end = 20;
        for i = h_start : h_end
            for j = w2_start : w2_end
                current_test = [96+192*(j-1), 96+192*(i-1)];
                v = abs(circle_center2 - current_test);
                u = max(v-h, 0);
                judge = correction * dot(u, u) <= circle_r * circle_r;
                if judge==1
                    tile_Distrib_orig(i, j) = 1;
                end
            end
        end
    end

    % circle exceeds right
    if w_max > W
        w1_start = ceil(w_min/192);
        w1_end = 20;
        for i = h_start : h_end
            for j = w1_start : w1_end
                current_test = [96+192*(j-1), 96+192*(i-1)];
                v = abs(circle_center - current_test);
                u = max(v-h, 0);
                judge = correction * dot(u, u) <= circle_r * circle_r;
                if judge==1
                    tile_Distrib_orig(i, j) = 1;
                end
            end
        end

        % calculation in compensation circle
        circle_center2 = [w_center-W, h_center];
        w2_start = 1;
        w2_end = ceil((w_max-W)/192);
        for i = h_start : h_end
            for j = w2_start : w2_end
                current_test = [96+192*(j-1), 96+192*(i-1)];
                v = abs(circle_center2 - current_test);
                u = max(v-h,0);
                judge = correction * dot(u, u) <= circle_r * circle_r;
                if judge==1
                    tile_Distrib_orig(i, j) = 1;
                end
            end
        end
    end
    
    
    % ori2tile_test
    % transfer from (yaw, pitch) to plane coordinate (w, h)
    w_center = W * (yaw_pred + 180)/360;  % pre-processing
    h_center = H * (pitch_pred + 90)/180;
    circle_center = [w_center, h_center];

    % outer square
    w_min = w_center - circle_r;
    w_max = w_center + circle_r;
    h_min = h_center - circle_r;
    h_max = h_center + circle_r;

    h_start = max(1, ceil(h_min/192));
    h_end = min(ceil(h_max/192), 10);
    % circle is in the ERP canvas
    if (w_max < W) && (w_min > 0)
        w_start = ceil(w_min/192);
        w_end = ceil(w_max/192);
        TN = TN + 200 - (w_end - w_start + 1) * (h_end - h_start + 1);
        for i = h_start : h_end
            for j = w_start : w_end
                current_test = [96+192*(j-1), 96+192*(i-1)];
                current_real_tile = tile_Distrib_orig(i, j);
                v = abs(circle_center - current_test);
                u = max(v-h, 0);
                judge = correction * dot(u, u) <= circle_r * circle_r;

                if (judge==1) && (current_real_tile==1)
                    TP=TP+1;
                end
                if (judge==0) && (current_real_tile==0)
                    TN=TN+1;
                end
                if (judge==1) && (current_real_tile==0)
                    FP=FP+1;
                end
                if (judge==0) && (current_real_tile==1)
                    FN=FN+1;
                end
            end
        end
    end

    % circle exceeds left
    if w_min < 0
        w1_start = 1;
        w1_end = ceil(w_max/192);
        for i = h_start : h_end
            for j = w1_start : w1_end
                current_test = [96+192*(j-1), 96+192*(i-1)];
                current_real_tile = tile_Distrib_orig(i, j);
                v = abs(circle_center - current_test);
                u = max(v-h, 0);
                judge = correction * dot(u, u) <= circle_r * circle_r;

                if (judge==1) && (current_real_tile==1)
                    TP=TP+1;
                end
                if (judge==0) && (current_real_tile==0)
                    TN=TN+1;
                end
                if (judge==1) && (current_real_tile==0)
                    FP=FP+1;
                end
                if (judge==0) && (current_real_tile==1)
                    FN=FN+1;
                end
            end
        end

        % calculation in compensation circle
        circle_center2 = [w_center+W, h_center];
        w2_start = ceil((w_min+W)/192);
        w2_end = 20;
        TN = TN + 200 - (w1_end - w1_start + 1) * (h_end - h_start + 1) - (w2_end - w2_start + 1) * (h_end - h_start + 1);
        for i = h_start : h_end
            for j = w2_start : w2_end
                current_test = [96+192*(j-1), 96+192*(i-1)];
                current_real_tile = tile_Distrib_orig(i, j);
                v = abs(circle_center2 - current_test);
                u = max(v-h, 0);
                judge = correction * dot(u, u) <= circle_r * circle_r;

                if (judge==1) && (current_real_tile==1)
                    TP=TP+1;
                end
                if (judge==0) && (current_real_tile==0)
                    TN=TN+1;
                end
                if (judge==1) && (current_real_tile==0)
                    FP=FP+1;
                end
                if (judge==0) && (current_real_tile==1)
                    FN=FN+1;
                end
            end
        end
    end

    % circle exceeds right
    if w_max > W
        w1_start = ceil(w_min/192);
        w1_end = 20;
        for i = h_start : h_end
            for j = w1_start : w1_end
                current_test = [96+192*(j-1), 96+192*(i-1)];
                current_real_tile = tile_Distrib_orig(i, j);
                v = abs(circle_center - current_test);
                u = max(v-h, 0);
                judge = correction * dot(u, u) <= circle_r * circle_r;
                if (judge==1) && (current_real_tile==1)
                    TP=TP+1;
                end
                if (judge==0) && (current_real_tile==0)
                    TN=TN+1;
                end
                if (judge==1) && (current_real_tile==0)
                    FP=FP+1;
                end
                if (judge==0) && (current_real_tile==1)
                    FN=FN+1;
                end
            end
        end

        % calculation in compensation circle
        circle_center2 = [w_center-W, h_center];
        w2_start = 1;
        w2_end = ceil((w_max-W)/192);
        TN = TN + 200 - (w1_end - w1_start + 1) * (h_end - h_start + 1) - (w2_end - w2_start + 1) * (h_end - h_start + 1);
        for i = h_start : h_end
            for j = w2_start : w2_end
                current_test = [96+192*(j-1), 96+192*(i-1)];
                current_real_tile = tile_Distrib_orig(i, j);
                v = abs(circle_center2 - current_test);
                u = max(v-h,0);
                judge = correction * dot(u, u) <= circle_r * circle_r;

                if (judge==1) && (current_real_tile==1)
                    TP=TP+1;
                end
                if (judge==0) && (current_real_tile==0)
                    TN=TN+1;
                end
                if (judge==1) && (current_real_tile==0)
                    FP=FP+1;
                end
                if (judge==0) && (current_real_tile==1)
                    FN=FN+1;
                end
            end
        end
    end
end

