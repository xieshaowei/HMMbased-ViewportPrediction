Q = 18;   % the number of hidden states
NumEnd = 885;   % the total number of valid frames
speedCount = ones(Q, 1);

for vid = 1 : 10
    for num = 1 : 50
		load(['video', int2str(vid), '_user', int2str(num), '.mat']);
		for pa = 1 : NumEnd
			HidState = distan_ang(pa,1);
			speedNum = speedCount(HidState, 1);
			speeds_state1{HidState}(speedNum, 1) = user_speed_pitch(pa, 1);
			speeds_state2{HidState}(speedNum, 1) = user_speed_roll(pa, 1);
			speeds_state3{HidState}(speedNum, 1) = user_speed_yaw(pa, 1);
			speedCount{HidState, 1} = speedNum + 1;
		end
    end
end

% GMM fitting
for i = 1 : Q
    [b1, a1] = ksdensity(speeds_state1{i});
    [fitresult1, gof1] = createFit(a1, b1);
    mixmat_pitch(i, 1) = fitresult1.a1;
    mixmat_pitch(i, 2) = fitresult1.a2;
    mu_pitch(i, 1) = fitresult1.b1;
    mu_pitch(i, 2) = fitresult1.b2;
    Sigma_pitch(i, 1) = fitresult1.c1;
    Sigma_pitch(i, 2) = fitresult1.c2;
    
    [b2, a2] = ksdensity(speeds_state2{i});
    [fitresult2, gof2] = createFit(a2,b2);
    mixmat_roll(i, 1) = fitresult2.a1;
    mixmat_roll(i, 2) = fitresult2.a2;
    mu_roll(i, 1) = fitresult2.b1;
    mu_roll(i, 2) = fitresult2.b2;
    Sigma_roll(i, 1) = fitresult2.c1;
    Sigma_roll(i, 2) = fitresult2.c2;
    
    [b3, a3] = ksdensity(speeds_state3{i});
    [fitresult3, gof3] = createFit(a3,b3);
    mixmat_yaw(i, 1) = fitresult3.a1;
    mixmat_yaw(i, 2) = fitresult3.a2;
    mu_yaw(i, 1) = fitresult3.b1;
    mu_yaw(i, 2) = fitresult3.b2;
    Sigma_yaw(i, 1) = fitresult3.c1;
    Sigma_yaw(i, 2) = fitresult3.c2;
end
save('Gaussian_init.mat','mixmat_yaw', 'mixmat_pitch', 'mixmat_roll', 'mu_yaw', 'mu_pitch', 'mu_roll', 'Sigma_yaw', 'Sigma_pitch', 'Sigma_roll')
