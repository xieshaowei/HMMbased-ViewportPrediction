for vid=1:10
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
    feaMap1 = VideoReader(['video', int2str(vid), '_saliency.mp4']);
    feaMap2 = VideoReader(['video', int2str(vid), '_motion.mp4']);
    nFrames = video.NumberOfFrames;
    H = video.Height;
    W = video.Width;
    greymap=zeros(H,W);
    greymap1=zeros(H,W);
    greymap2=zeros(H,W);
    
    for i = 1 : nFrames/2
        rgbmap1 = read(feaMap1, i*2); 
        rgbmap2 = read(feaMap2, i*2);
        greymap1 = rgb2gray(rgbmap1);
        greymap2 = rgb2gray(rgbmap2);
        
        greymap1 = im2double(greymap1);
        a_min1 = min(min(greymap1));
        a1 = 10.0 / (max(max(greymap1)) - a_min1);  % 10.0 is an amplification coefficient 
        
        greymap2 = im2double(greymap2);
        sigma = 2;
        gausFilter = fspecial('gaussian', [35 35], sigma);  % parameters of Gaussian filter can be various
        blur=imfilter(greymap2, gausFilter, 'replicate');  % the motion map after Gaussian filter
        a_min2 = min(min(blur));
        if max(max(blur)) - a_min2 == 0
            a2 = 0;
        else
            a2 = 10.0 / (max(max(blur)) - a_min2);
        end
        greymap1_new = a1 .* (greymap1 - a_min1);  % normalization
        greymap2_new = a2 .* (blur - a_min2); 
        greymap_mix=0.5*greymap1_new + 0.5*greymap2_new;
        greymap = max(greymap2_new, greymap_mix);  % get the final mixed map (importance map)
        a_min3 = min(min(greymap));
        a3 = 1.0 / (max(max(greymap)) - a_min3);
        heat = a3 .* (greymap - a_min3);

        heat(heat>0) = 1;
        heat(heat<0.8) = 0;   % set the pixel values of top 20% to be 1
        STATS = regionprops(heat, 'centroid');  % get the heat center in 2D plane
        heat_center(i, : ) = cat(1, STATS.Centroid);
        longi = 2*pi*( (heat_center(i, 1) + 0.5) / W - 0.5);  % get the heat center in sphere surface
        lati = 2*pi*( -(heat_center(i, 2) + 0.5) / H + 0.5);
        heat_x = cos(longi) * cos(lati);
        heat_y = sin(lati);
        heat_z = -cos(lati)*sin(longi);
        heat_sph_cen(i, 1) = heat_x;
        heat_sph_cen(i, 2) = heat_y;
        heat_sph_cen(i, 3) = heat_z;
    end
    save(['video', int2str(vid), '_heatcen.mat'], 'heat_sph_cen');
end
