
threshold_20 = 20;
threshold_10 = 10;

TP_all = zeros(6,1);  % True Positive
TN_all = zeros(6,1);  % True Negative
FP_all = zeros(6,1);  % False Positive
FN_all = zeros(6,1);  % False Negative
frame = [1, 3, 6, 9, 12, 15];

for cross_count = 1 : 5
    load(['paramHMM_', num2str(cross_count), '.mat']);

    Sigma1 = Sigma1_pitch;
    mixmat1 = mixmat1_pitch;
    mu1 = mu1_pitch;
    prior1 = prior1_pitch;
    transmat1 = transmat1_pitch;

    T = 4;    % 4 past output tokens for prediction the one coming
    Q = 18;   % hidden states

    i_end = 885-21-10; % the number of valid frames
    num = 10;  
    vid = 10;
    data_yaw = zeros(1,T,vid*num*i_end/2);
    data_pitch = zeros(1,T,vid*num*i_end/2);
    % data_roll = zeros(1,T,vid*num*i_end/2);
    data_yaw_ori_past = zeros(1,1,vid*num*i_end/2);
    data_pitch_ori_past = zeros(1,1,vid*num*i_end/2);
    % data_roll_ori_past = zeros(1,1,vid*num*i_end/2);
    data_yaw_ori_next = zeros(1,15,vid*num*i_end/2);
    data_pitch_ori_next = zeros(1,15,vid*num*i_end/2);
    % data_roll_ori_next = zeros(1,15,vid*num*i_end/2);
    symbol_yaw = zeros(1,1,vid*num*i_end/2);
    symbol_pitch = zeros(1,1,vid*num*i_end/2);
    % symbol_roll = zeros(1,1,vid*num*i_end/2);

    for vid = 1 :  10
        num_count = 0;
        if vid == 1
            videoname = 'coaster_user';
        elseif vid == 2
            videoname = 'coaster2_user';
        elseif vid == 3
            videoname = 'diving_user';
        elseif vid == 4
            videoname = 'drive_user';
        elseif vid == 5
            videoname = 'game_user';
        elseif vid == 6
            videoname = 'landscape_user';
        elseif vid == 7
            videoname = 'pacman_user';
        elseif vid == 8
            videoname = 'panel_user';
        elseif vid == 9
            videoname = 'ride_user';
        elseif vid == 10
            videoname = 'sport_user';
        end

        for num = 1 : 50
            if ismember(num, user_test(cross_count, : ))
                num_count = num_count + 1;
                orien_raw_yaw = xlsread([videoname, num2str(num, '%02d'), '_orientation.xls'], [videoname, num2str(num, '%02d'), '_orientation'], 'H2:H1801');
                orien_raw_pitch = xlsread([videoname, num2str(num,'%02d'), '_orientation.xls'], [videoname,num2str(num, '%02d'), '_orientation'], 'I2:I1801');
    %             orien_raw_roll = xlsread([videoname, num2str(num_, '%02d'), '_orientation.xls'], [videoname, num2str(num_, '%02d'), '_orientation'], 'J2:J1801');
                orien_yaw = orien_raw_yaw(1 : 2 : end , : ); 
                orien_pitch = orien_raw_pitch(1 : 2 : end, : );
    %             orien_roll = orien_raw_roll(1 : 2 : end, : );

                load(['video', int2str(vid), '_user', int2str(num), '.mat']);
                symbol_yaw_ = zeros(size(orien_yaw, 1) - 1, 1) - 1;
                symbol_yaw_(orien_yaw(2 : end, 1) - orien_yaw(1 : end - 1) > 0) = 1;
                symbol_pitch_ = zeros(size(orien_pitch, 1) - 1, 1) - 1;
                symbol_pitch_(orien_pitch(2 : end, 1) - orien_pitch(1 : end - 1) > 0) = 1;
    %                 symbol_roll_ = zeros(size(orien_roll, 1) - 1, 1) - 1;
    %                 symbol_roll_(orien_roll(2 : end, 1) - orien_roll(1 : end - 1) > 0) = 1;

                for i = 1 : i_end/2
                    data_yaw(1, : , (vid-1)*10*i_end/2+(num_count-1)*i_end/2+i) = user_speed_roll(i*2-1 : 7 : i*2-1+21, 1);
                    data_pitch(1, : , (vid-1)*10*i_end/2+(num_count-1)*i_end/2+i) = user_speed_pitch(i*2-1 : 7 : i*2-1+21, 1);
    %                 data_roll(1, : , (vid-1)*6*i_end/2+(num-1)*i_end/2+i)=user_speed_roll(i*2-1 : 7 : i*2-1+21, 1);

                    data_yaw_ori_past(1, 1, (vid-1)*10*i_end/2+(num_count-1)*i_end/2+i) = orien_yaw(i*2-1+27, 1);               
                    data_pitch_ori_past(1, 1, (vid-1)*10*i_end/2+(num_count-1)*i_end/2+i) = orien_pitch(i*2-1+27, 1);
    %                 data_roll_ori_past(1, 1, (vid-1)*6*i_end/2+(num-1)*i_end/2+i) = orien_roll(i*2-1+27, 1);

                    %%%%%%%%%%%%%%%%%%%%%% The followings are variable when prediction window changes %%%%%%%%%%%%%%%%%%%%%%
                    data_yaw_ori_next(1, : , (vid-1)*10*i_end/2+(num_count-1)*i_end/2+i) = orien_yaw(i*2-1+27+1 : i*2-1+27+15, 1);
                    data_pitch_ori_next(1, : , (vid-1)*10*i_end/2+(num_count-1)*i_end/2+i) = orien_pitch(i*2-1+27+1 : i*2-1+27+15, 1);
    %                 data_roll_ori_next(1, : , (vid-1)*6*i_end/2+(num-1)*i_end/2+i) = orien_roll(i*2-1+27+1 : i*2-1+27+15, 1);

                    symbol_yaw(1, 1, (vid-1)*10*i_end/2+(num_count-1)*i_end/2+i) = symbol_yaw_(i*2-1+27, 1);
                    symbol_pitch(1, 1, (vid-1)*10*i_end/2+(num_count-1)*i_end/2+i) = symbol_pitch_(i*2-1+27, 1);
    %                 symbol_roll(1, 1, (vid-1)*6*i_end/2+(num-1)*i_end/2+i) = symbol_roll_(i*2-1+27, 1);
                end
            end
        end
    end

    data_len = size(data_pitch, 3);
    hiden_state_yaw = zeros(data_len, 4);
    hiden_state_pitch = zeros(data_len, 4);
    % hiden_state_roll = zeros(data_len, 4);
    hiden_state = zeros(data_len, 3);
    result_speed = zeros(data_len, 3);
    result_orientation = zeros(data_len, 3);

    %%%%%%%%%%%%%% Initialization of Acceleration Matrix %%%%%%%%%%%%%%%%%%%%
    x = [-50 : 0.001 : 50];
    obs_out_pitch = zeros(Q, size(x, 2));
    obs_out_yaw = zeros(Q,size(x, 2));
    % obs_out_roll = zeros(Q,size(x, 2));
    for q = 1 : Q   % fit the GMM for each hidden state, following GMM parameters.
        obs_out_1 = (1/(2*pi*Sigma1(1,1,q,1)*Sigma1(1,1,q,1))^0.5)*exp(-((x-mu1(1,q,1)).*(x-mu1(1,q,1)))/(2*Sigma1(1,1,q,1)*Sigma1(1,1,q,1)));
        obs_out_2 = (1/(2*pi*Sigma1(1,1,q,2)*Sigma1(1,1,q,2))^0.5)*exp(-((x-mu1(1,q,1)).*(x-mu1(1,q,1)))/(2*Sigma1(1,1,q,2)*Sigma1(1,1,q,2)));
        obs_out_pitch(q,:) = obs_out_1(1,:)*mixmat1(q,1)+obs_out_2(1,:)*mixmat1(q,2);
        speed_max_pitch(q,1) = max(obs_out_pitch(q,:));
    %     mu(q,:)=mu1(1,q,:);
    %     Sigma(q,:)=Sigma1(1,1,q,:);

        obs_out_1_yaw=(1/(2*pi*Sigma1_yaw(1,1,q,1)*Sigma1_yaw(1,1,q,1))^0.5)*exp(-((x-mu1_yaw(1,q,1)).*(x-mu1_yaw(1,q,1)))/(2*Sigma1_yaw(1,1,q,1)*Sigma1_yaw(1,1,q,1)));
        obs_out_2_yaw=(1/(2*pi*Sigma1_yaw(1,1,q,2)*Sigma1_yaw(1,1,q,2))^0.5)*exp(-((x-mu1_yaw(1,q,1)).*(x-mu1_yaw(1,q,1)))/(2*Sigma1_yaw(1,1,q,2)*Sigma1_yaw(1,1,q,2)));
        obs_out_yaw(q,:)=obs_out_1_yaw(1,:)*mixmat1_yaw(q,1)+obs_out_2_yaw(1,:)*mixmat1_yaw(q,2);
        speed_max_yaw(q,1)=max(obs_out_yaw(q,:));
    %     mu_yaw(q,:)=mu1_yaw(1,q,:);
    %     Sigma_yaw(q,:)=Sigma1_yaw(1,1,q,:);
    %     obs_out_pitch(q,:)=mvncdf(x,mu(q,:),Sigma1(q,:));

    %     obs_out_1_roll=(1/(2*pi*Sigma1_roll(1,1,q,1)*Sigma1_roll(1,1,q,1))^0.5)*exp(-((x-mu1_roll(1,q,1)).*(x-mu1_roll(1,q,1)))/(2*Sigma1_roll(1,1,q,1)*Sigma1_roll(1,1,q,1)));
    %     obs_out_2_roll=(1/(2*pi*Sigma1_roll(1,1,q,2)*Sigma1_roll(1,1,q,2))^0.5)*exp(-((x-mu1_roll(1,q,1)).*(x-mu1_roll(1,q,1)))/(2*Sigma1_roll(1,1,q,2)*Sigma1_roll(1,1,q,2)));
    %     obs_out_roll(q,:)=obs_out_1_roll(1,:)*mixmat1_roll(q,1)+obs_out_2_roll(1,:)*mixmat1_roll(q,2);
    %     speed_max_roll(q,1)=max(obs_out_roll(q,:));
    %     mu_roll(q,:)=mu1_roll(1,q,:);
    %     Sigma_roll(q,:)=Sigma1_roll(1,1,q,:);
    end
    accele_yaw = zeros(18,18);
    accele_pitch = zeros(18,18);
    % accele_roll = zeros(18,18);
    accele_result=zeros(data_len,3);

    for p=1:Q
        for q=1:Q
            accele_yaw(p,q)=speed_max_yaw(q,1)-speed_max_yaw(p,1);
            accele_pitch(p,q)=speed_max_pitch(q,1)-speed_max_pitch(p,1);
    %         accele_roll(p,q)=speed_max_roll(q,1)-speed_max_roll(p,1);
        end
    end

    for count = 1 : data_len
        B_pitch = mixgauss_prob(data_pitch(:,:,count), mu1, Sigma1, mixmat1);
        hiden_state_pitch(count,:) = viterbi_path(prior1, transmat1, B_pitch);
        accele_pitch_=((count-1)*accele_pitch(hiden_state_pitch(count,1),hiden_state_pitch(count,2))+data_pitch(:,2,count)-data_pitch(:,1,count))/count;
        accele_pitch(hiden_state_pitch(count,1),hiden_state_pitch(count,2))=min(accele_pitch(hiden_state_pitch(count,1),hiden_state_pitch(count,2)),accele_pitch_);
        accele_pitch_=((count-1)*accele_pitch(hiden_state_pitch(count,2),hiden_state_pitch(count,3))+data_pitch(:,3,count)-data_pitch(:,2,count))/count;
        accele_pitch(hiden_state_pitch(count,2),hiden_state_pitch(count,3))=min(accele_pitch_,accele_pitch(hiden_state_pitch(count,2),hiden_state_pitch(count,3)));
        accele_pitch_=((count-1)*accele_pitch(hiden_state_pitch(count,3),hiden_state_pitch(count,4))+data_pitch(:,4,count)-data_pitch(:,3,count))/count;
        accele_pitch(hiden_state_pitch(count,3),hiden_state_pitch(count,4))=min(accele_pitch_,accele_pitch(hiden_state_pitch(count,3),hiden_state_pitch(count,4)));

        B_yaw = mixgauss_prob(data_yaw(:,:,count), mu1_yaw, Sigma1_yaw, mixmat1_yaw);
        hiden_state_yaw(count,:) = viterbi_path(prior1_yaw, transmat1_yaw, B_yaw);
        accele_yaw_=((count-1)*accele_yaw(hiden_state_yaw(count,1),hiden_state_yaw(count,2))+data_yaw(:,2,count)-data_yaw(:,1,count))/count;
        accele_yaw(hiden_state_yaw(count,1),hiden_state_yaw(count,2))=min(accele_yaw(hiden_state_yaw(count,1),hiden_state_yaw(count,2)),accele_yaw_);
        accele_yaw_=((count-1)*accele_yaw(hiden_state_yaw(count,2),hiden_state_yaw(count,3))+data_yaw(:,3,count)-data_yaw(:,2,count))/count;
        accele_yaw(hiden_state_yaw(count,2),hiden_state_yaw(count,3))=min(accele_yaw_,accele_yaw(hiden_state_yaw(count,2),hiden_state_yaw(count,3)));
        accele_yaw_=((count-1)*accele_yaw(hiden_state_yaw(count,3),hiden_state_yaw(count,4))+data_yaw(:,4,count)-data_yaw(:,3,count))/count;
        accele_yaw(hiden_state_yaw(count,3),hiden_state_yaw(count,4))=min(accele_yaw_,accele_yaw(hiden_state_yaw(count,3),hiden_state_yaw(count,4)));

    %     B_roll = mixgauss_prob(data_roll(:,:,count), mu1_roll, Sigma1_roll, mixmat1_roll);
    %     hiden_state_roll(count,:) = viterbi_path(prior1_roll, transmat1_roll, B_roll);
    %     accele_roll_=((count-1)*accele_roll(hiden_state_roll(count,1),hiden_state_roll(count,2))+data_roll(:,2,count)-data_roll(:,1,count))/count;
    %     accele_roll(hiden_state_roll(count,1),hiden_state_roll(count,2))=min(accele_roll(hiden_state_roll(count,1),hiden_state_roll(count,2)),accele_roll_);
    %     accele_roll_=((count-1)*accele_roll(hiden_state_roll(count,2),hiden_state_roll(count,3))+data_roll(:,3,count)-data_roll(:,2,count))/count;
    %     accele_roll(hiden_state_roll(count,2),hiden_state_roll(count,3))=min(accele_roll_,accele_roll(hiden_state_roll(count,2),hiden_state_roll(count,3)));
    %     accele_roll_=((count-1)*accele_roll(hiden_state_roll(count,3),hiden_state_roll(count,4))+data_roll(:,4,count)-data_roll(:,3,count))/count;
    %     accele_roll(hiden_state_roll(count,3),hiden_state_roll(count,4))=min(accele_roll_,accele_roll(hiden_state_roll(count,3),hiden_state_roll(count,4)));

        [non,hiden_state(count,3)]=max(transmat1_yaw(hiden_state_yaw(count,4),:));
        [non,hiden_state(count,1)]=max(transmat1(hiden_state_pitch(count,4),:));
    %     [non,hiden_state(count,2)]=max(transmat1_roll(hiden_state_roll(count,4),:));

        accele_result(count,3)=accele_yaw(hiden_state_yaw(count,4),hiden_state(count,3));
        accele_result(count,1)=accele_pitch(hiden_state_pitch(count,4),hiden_state(count,1));
    %     accele_result(count,2)=accele_roll(hiden_state_roll(count,4),hiden_state(count,2));

        result_speed(count,3)=data_yaw(:,4,count)+accele_result(count,3);
        result_speed(count,1)=data_pitch(:,4,count)+accele_result(count,1);
    %     result_speed(count,2)=data_roll(:,4,count)+accele_result(count,2);

    end
    result_speed(result_speed<0)=0;

    %%%%%%%%%%%%%% Prediction Process %%%%%%%%%%%%%%%%%%%%%
    for count = 1 : data_len
        disp(count);

        result_orientation_yaw(count,1)=result_speed(count,3)*symbol_yaw(1,1,count)/15+data_yaw_ori_past(1,1,count);
        result_orientation_yaw(count,2)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,1);
        result_orientation_yaw(count,3)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,2);
        result_orientation_yaw(count,4)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,3);
        result_orientation_yaw(count,5)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,4);
        result_orientation_yaw(count,6)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,5);
        result_orientation_yaw(count,7)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,6);
        %%%%%%%%%% Prediction Window after 0.5s %%%%%%%%%
        result_orientation_yaw(count,8)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,7);
        result_orientation_yaw(count,9)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,8);
        result_orientation_yaw(count,10)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,9);
        result_orientation_yaw(count,11)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,10);
        result_orientation_yaw(count,12)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,11);
        result_orientation_yaw(count,13)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,12);
        result_orientation_yaw(count,14)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,13);
        result_orientation_yaw(count,15)=result_speed(count,3)*symbol_yaw(1,1,count)/15+result_orientation_yaw(count,14);

        result_orientation_pitch(count,1)=result_speed(count,1)*symbol_pitch(1,1,count)/15+data_pitch_ori_past(1,1,count);
        result_orientation_pitch(count,2)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,1);
        result_orientation_pitch(count,3)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,2);
        result_orientation_pitch(count,4)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,3);
        result_orientation_pitch(count,5)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,4);
        result_orientation_pitch(count,6)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,5);
        result_orientation_pitch(count,7)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,6);
        %%%%%%%%% Prediction Window after 0.5s %%%%%%%%%
        result_orientation_pitch(count,8)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,7);
        result_orientation_pitch(count,9)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,8);
        result_orientation_pitch(count,10)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,9);
        result_orientation_pitch(count,11)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,10);
        result_orientation_pitch(count,12)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,11);
        result_orientation_pitch(count,13)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,12);
        result_orientation_pitch(count,14)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,13);
        result_orientation_pitch(count,15)=result_speed(count,1)*symbol_pitch(1,1,count)/15+result_orientation_pitch(count,14);

    %     result_orientation_roll(count,1)=result_speed(count,2)*symbol_roll(1,1,count)/15+data_roll_ori_past(1,1,count);
    %     result_orientation_roll(count,2)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,1);
    %     result_orientation_roll(count,3)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,2);
    %     result_orientation_roll(count,4)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,3);
    %     result_orientation_roll(count,5)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,4);
    %     result_orientation_roll(count,6)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,5);
    %     result_orientation_roll(count,7)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,6);
    %     %%%%%%%%%% Prediction Window after 0.5s %%%%%%%%%
    %     result_orientation_roll(count,8)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,7);
    %     result_orientation_roll(count,9)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,8);
    %     result_orientation_roll(count,10)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,9);
    %     result_orientation_roll(count,11)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,10);
    %     result_orientation_roll(count,12)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,11);
    %     result_orientation_roll(count,13)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,12);
    %     result_orientation_roll(count,14)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,13);
    %     result_orientation_roll(count,15)=result_speed(count,2)*symbol_roll(1,1,count)/15+result_orientation_roll(count,14);

        accuracy_yaw(count, : ) = result_orientation_yaw(count, : ) - data_yaw_ori_next(1, : , count);
        accuracy_pitch(count, : ) = result_orientation_pitch(count, : ) - data_pitch_ori_next(1, : , count);
        
        % Convert the orientation in each frame into the corresponding tiles covered by FoV, and calculate the 4 metrics: TP, TN, FP, FN
        for fff = 1 : length(frame)
            f = frame(fff);
            yaw_orig = data_yaw_ori_next(1, f, count);
            pitch_orig = data_pitch_ori_next(1, f, count);
            yaw_pred = result_orientation_yaw(count, f );
            pitch_pred = result_orientation_pitch(count, f );
            [TP, TN, FP, FN] = ori2tileEvaluate(yaw_orig, pitch_orig, yaw_pred, pitch_pred);
            TP_all(fff, 1) = TP_all(fff, 1) + TP;
            TN_all(fff, 1) = TN_all(fff, 1) + TN;
            FP_all(fff, 1) = FP_all(fff, 1) + FP;
            FN_all(fff, 1) = FN_all(fff, 1) + FN;
        end
    end
    accuracy_yaw_=abs(accuracy_yaw);
    accuracy_yaw_=min(accuracy_yaw_, 360-accuracy_yaw_);
    accuracy_pitch_=abs(accuracy_pitch);
    accuracy_pitch_=min(accuracy_pitch_, 360-accuracy_pitch_); 
    % accuracy_roll_=abs(accuracy_roll);
    % accuracy_roll_=min(accuracy_roll_,360-accuracy_roll_);

    accuracy_final_1_thre10=zeros(data_len,15);
    accuracy_final_2_thre10=zeros(data_len,15);
    accuracy_final_1_thre20=zeros(data_len,15);
    accuracy_final_2_thre20=zeros(data_len,15);
    accuracy_total_thre10=zeros(data_len,1);
    accuracy_total_thre20=zeros(data_len,1);

    accuracy_final_1_thre10(accuracy_yaw_>-threshold_10&accuracy_yaw_<threshold_10)=1;
    accuracy_final_2_thre10(accuracy_pitch_>-threshold_10&accuracy_pitch_<threshold_10)=1;
    accuracy_final_1_thre20(accuracy_yaw_>-threshold_20&accuracy_yaw_<threshold_20)=1;
    accuracy_final_2_thre20(accuracy_pitch_>-threshold_20&accuracy_pitch_<threshold_20)=1;

    accuracy_total_thre10=accuracy_final_1_thre10.*accuracy_final_2_thre10;
    accuracy_total_thre20=accuracy_final_1_thre20.*accuracy_final_2_thre20;
    % accuracy_result=sum(accuracy_total)/data_len;

	for vid = 1 : 10
		accuracy_pitch_distance(cross_count,vid,:)=mean(accuracy_pitch_((vid-1)*10*i_end/2+1:vid*10*i_end/2,:));
		accuracy_yaw_distance(cross_count,vid,:)=mean(accuracy_yaw_((vid-1)*10*i_end/2+1:vid*10*i_end/2,:));
		accuracy_pitch_distance_std(cross_count,vid,:)=std(accuracy_pitch_((vid-1)*10*i_end/2+1:vid*10*i_end/2,:),1,1);
		accuracy_yaw_distance_std(cross_count,vid,:)=std(accuracy_yaw_((vid-1)*10*i_end/2+1:vid*10*i_end/2,:),1,1);
		accuracy_result_thre10(cross_count,vid,:)=mean(accuracy_total_thre10((vid-1)*10*i_end/2+1:vid*10*i_end/2,:));
		accuracy_result_thre20(cross_count,vid,:)=mean(accuracy_total_thre20((vid-1)*10*i_end/2+1:vid*10*i_end/2,:));
    end
end
Recall = TP_all ./ (TP_all + FN_all);
Precision = TP_all ./ (TP_all + FP_all);
F_score = 2 .* Precision .* Recall ./ (Precision + Recall);
Accuracy = (TP_all + TN_all) ./ (TP_all + TN_all + FP_all + FN_all);
Accuracy_cross = TP_all ./ (TP_all + FN_all + FP_all);
for fff = 1 : length(frame)
    f = frame(fff);
    fprintf('Frame %2d: Recall=%.4f, Precision=%.4f, F_score=%.4f, Accuracy=%.4f, Accuracy_cross=%.4f \n',...
        f, Recall(fff), Precision(fff), F_score(fff), Accuracy(fff), Accuracy_cross(fff));
end
