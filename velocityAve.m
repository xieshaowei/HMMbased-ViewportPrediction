for vid = 1 : 10  % video number
    for num = 1 : 50  % user number
        if vid==1
            videoname='coaster_user';
        elseif vid==2
            videoname='coaster2_user';
        elseif vid==3
            videoname='diving_user';
        elseif vid==4
            videoname='drive_user';
        elseif vid==5
            videoname='game_user';
        elseif vid==6
            videoname='landscape_user';
        elseif vid==7
            videoname='pacman_user';
        elseif vid==8
            videoname='panel_user';
        elseif vid==9
            videoname='ride_user';
        elseif vid==10
            videoname='sport_user';
        end
        
        if exist([videoname, num2str(num,'%02d'), '_orientation.xls'], 'file')==2
            % read raw orientation data
            user_x_row = xlsread([videoname,num2str(num,'%02d'),'_orientation.xls'],[videoname,num2str(num,'%02d'),'_orientation'], 'B2:B1801');
            user_y_row = xlsread([videoname,num2str(num,'%02d'),'_orientation.xls'],[videoname,num2str(num,'%02d'),'_orientation'], 'C2:C1801');
            user_z_row = xlsread([videoname,num2str(num,'%02d'),'_orientation.xls'],[videoname,num2str(num,'%02d'),'_orientation'], 'D2:D1801');
            user_yaw_row = xlsread([videoname,num2str(num,'%02d'),'_orientation.xls'],[videoname,num2str(num,'%02d'),'_orientation'], 'H2:H1801');
            user_pitch_row = xlsread([videoname,num2str(num,'%02d'),'_orientation.xls'],[videoname,num2str(num,'%02d'),'_orientation'], 'I2:I1801');
            user_roll_row = xlsread([videoname,num2str(num,'%02d'),'_orientation.xls'],[videoname,num2str(num,'%02d'),'_orientation'],'J2:J1801');
            nFrames=size(user_yaw_row, 1)/2;  % the total number of valid frames
            % In the dataset we use, two consecutive frames have the same orientation data
            user_x = zeros(nFrames, 1);
            user_y = zeros(nFrames, 1);
            user_z= zeros(nFrames, 1);
            user_yaw = zeros(nFrames, 1);
            user_pitch = zeros(nFrames, 1);
            user_roll = zeros(nFrames, 1);
            for i = 0 : nFrames-1
				user_yaw(i+1, 1) = user_yaw_raw(i*2+1, 1);
				user_pitch(i+1, 1) = user_pitch_raw(i*2+1, 1);
				user_roll(i+1, 1) = user_roll_raw(i*2+1, 1);
                user_x(i+1, 1) = user_x_row(i*2+1, 1);
                user_y(i+1, 1) = user_y_row(i*2+1, 1);
                user_z(i+1, 1) = user_z_row(i*2+1, 1);
            end
            % calculate the velocity in each frame
            user_speed_yaw_raw = zeros(nFrames, 1);
            user_speed_pitch_raw = zeros(nFrames, 1);
            user_speed_roll_raw = zeros(nFrames, 1);
            for i= 2 : nFrames
                user_speed_yaw_raw(i,1) = user_yaw(i, 1) - user_yaw(i-1, 1);
                user_speed_pitch_raw(i,1) = user_pitch(i, 1) - user_pitch(i-1, 1);
                user_speed_roll_raw(i, 1) = user_roll(i,1) - user_roll(i-1, 1);
            end
            % get averaged velocities in every 15 frames
            user_speed_yaw = zeros(885,1);
            user_speed_pitch = zeros(885,1);
            user_speed_roll = zeros(885,1);
            for j = 1 : 15
                user_speed_yaw = user_speed_yaw + user_speed_yaw_raw(j : 885+j-1, 1);
                user_speed_pitch = user_speed_pitch + user_speed_pitch_raw(j : 885+j-1, 1);
                user_speed_roll = user_speed_roll + user_speed_roll_raw(j : 885+j-1, 1);
            end
            % output token is the scalar velocities after averaging
            user_speed_yaw = abs( user_speed_yaw ./ 15);
            user_speed_pitch = abs( user_speed_pitch ./ 15);
            user_speed_roll = abs( user_speed_roll ./ 15);

            radi_unsp=user_x.*user_x + user_y.*user_y + user_z.*user_z;
            radi = sqrt(radi_unsp);
            user_x = user_x./radi;
            user_y = user_y./radi;
            user_z = user_z./radi;

            % get the center of the initialization viewport
            load(['video', int2str(vid), '_heatcen.mat']);
            heat_sph_cen_raw = heat_sph_cen(2 : 900, : );
            heat_x=heat_sph_cen_raw(:,1);
            heat_y=heat_sph_cen_raw(:,2);
            heat_z=heat_sph_cen_raw(:,3);
            distan_x = (user_x - heat_x) .* (user_x - heat_x);
            distan_y = (user_y - heat_y) .* (user_y - heat_y);
            distan_z = (user_z - heat_z) .* (user_z - heat_z);
            distan_mid = sqrt(distan_x+distan_y+distan_z);
            distan_ang_row_new = (2*asin(distan_mid/2)) * 180 / pi;  % get the spherical distance

            % calculate the averaged spherical distances in every 15 Frames
            distan_sca = zeros(885,1);
            for j = 1 : 15
                distan_sca = distan_sca + distan_ang_row_new(j : 885+j-1, 1);
            end
            distan_sca = distan_sca ./ 15;
            % divived into 18 hidden states
            distan_ang=zeros(size(distan_sca, 1), 1);
            distan_ang(0<distan_sca & distan_sca<=10)=1;
            distan_ang(10<distan_sca & distan_sca<=20)=2;
            distan_ang(20<distan_sca & distan_sca<=30)=3;
            distan_ang(30<distan_sca & distan_sca<=40)=4;
            distan_ang(40<distan_sca & distan_sca<=50)=5;
            distan_ang(50<distan_sca & distan_sca<=60)=6;
            distan_ang(60<distan_sca & distan_sca<=70)=7;
            distan_ang(70<distan_sca & distan_sca<=80)=8;
            distan_ang(80<distan_sca & distan_sca<=90)=9;
            distan_ang(90<distan_sca & distan_sca<=100)=10;
            distan_ang(100<distan_sca & distan_sca<=110)=11;
            distan_ang(110<distan_sca & distan_sca<=120)=12;
            distan_ang(120<distan_sca & distan_sca<=130)=13; 
            distan_ang(130<distan_sca & distan_sca<=140)=14;
            distan_ang(140<distan_sca & distan_sca<=150)=15;
            distan_ang(150<distan_sca & distan_sca<=160)=16;
            distan_ang(160<distan_sca & distan_sca<=170)=17;
            distan_ang(170<distan_sca & distan_sca<=180)=18;
            distan_ang( : , 2) = distan_sca;

            save(['video', int2str(vid), '_user', int2str(num), '.mat'], 'distan_ang', 'user_speed_yaw', 'user_speed_pitch', 'user_speed_roll');
            disp(num);
        end
    end
end




