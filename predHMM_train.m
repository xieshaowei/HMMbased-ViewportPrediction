
O = 1;  % Dimensionality
T = 4;
user_num = 40;
M = 2;  % the number of Gaussian functions
Q = 18;   % the number of hidden states
%%%% 5-fold Cross Validation %%%%
numofmat = 5;
numofval = 10;
user_random = randperm(50);
user_test = zeros(5, 10);
for i = 1 : numofmat
    user_test(i, : ) = user_random((i-1)*numofval+1 : i*numofval);
end

for cross_count=1 : 5  % 5-fold Cross Validation
    cov_type = 'full';
    load('Gaussian_init.mat');
    
    i_end = (885-21)/2;
    num = 40;
    vid = 10;
    data_hiden = zeros(1, T, vid*num*i_end);
    data_pitch = zeros(1, T, vid*num*i_end);
    data_roll = zeros(1, T, vid*num*i_end);
    data_yaw = zeros(1, T, vid*num*i_end);

    for vid = 1 : 10
        num_count = 0;
        for num = 1 : 50
            if ismember(num, user_test(cross_count, : ))
                continue;
            else
                num_count = num_count + 1;
                load(['video', int2str(vid), '_user', int2str(num), '.mat']);
                for i = 1 : i_end
                    data_hiden( : , : , (vid-1)*40*i_end+(num_count-1)*i_end+i) = distan_ang(i : 7 : i+21, 1);  % 7 is the number of frames
                    data_pitch(1, : , (vid-1)*40*i_end+(num_count-1)*i_end+i) = user_speed_pitch(i : 7 : i+21, 1);
                    data_roll(1, : , (vid-1)*40*i_end+(num_count-1)*i_end+i) = user_speed_roll(i : 7 : i+21, 1);
                    data_yaw(1, : , (vid-1)*40*i_end+(num_count-1)*i_end+i) = user_speed_yaw(i : 7 : i+21,1);
                end
            end
        end
    end
    
    %%%% Inialization of GMM and HMM parameters %%%%
    prior0 = normalise(rand(Q, 1));
%     transmat0 = mk_stochastic(rand(Q, Q));
    transmat_raw = zeros(Q, Q);
    for vid = 1 : 10
        for num = 1 : 40
            for pa = 1: i_end
                 transmat_raw(data_hiden(1, 1, (vid-1)*40*i_end+(num-1)*i_end+pa), data_hiden(1, 2, (vid-1)*40*i_end+(num-1)*i_end+pa)) = ...
                     transmat_raw(data_hiden(1, 1, (vid-1)*40*i_end+(num-1)*i_end+pa), data_hiden(1, 2, (vid-1)*40*i_end+(num-1)*i_end+pa))+1;
            end
        end
    end
    transmat0 = mk_stochastic(transmat_raw);
    
    mu0_yaw = mu_yaw;
    mu0_pitch = mu_pitch;
    mu0_roll = mu_roll;
    Sigma0_yaw = Sigma_yaw;
    Sigma0_pitch = Sigma_pitch;
    Sigma0_roll = Sigma_roll;
    mixmat0_yaw = mixmat_yaw;
    mixmat0_pitch = mixmat_pitch;
    mixmat0_roll = mixmat_roll;

    [LL_yaw, prior1_yaw, transmat1_yaw, mu1_yaw, Sigma1_yaw, mixmat1_yaw] = ...
        mhmm_em(data_yaw, prior0, transmat0, mu0_yaw, Sigma0_yaw, mixmat0_yaw, 'max_iter', 20);
    [LL_pitch, prior1_pitch, transmat1_pitch, mu1_pitch, Sigma1_pitch, mixmat1_pitch] = ...
        mhmm_em(data_pitch, prior0, transmat0, mu0_pitch, Sigma0_pitch, mixmat0_pitch, 'max_iter', 20);
    [LL_roll, prior1_roll, transmat1_roll, mu1_roll, Sigma1_roll, mixmat1_roll] = ...
        mhmm_em(data_roll, prior0, transmat0, mu0_roll, Sigma0_roll, mixmat0_roll, 'max_iter', 20);

    save(['paramHMM_', num2str(cross_count), '.mat'], 'user_test', 'prior1_pitch', 'transmat1_pitch', 'mu1_pitch',...
        'Sigma1_pitch', 'mixmat1_pitch', 'prior1_yaw', 'transmat1_yaw', 'mu1_yaw', 'Sigma1_yaw', 'mixmat1_yaw');
end

% loglik = mhmm_logprob(data_pitch, prior1_pitch, transmat1_pitch, mu1_pitch, Sigma1_pitch, mixmat1_pitch);
