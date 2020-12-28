I1 = im2double(imread("testing_images/img1","jpg"));
I2 = im2double(imread("testing_images/img2","jpg"));

feature = detectHarrisFeatures(rgb2gray(I1));
pos1 = feature.Location;

prob = 0.2;
idx = 1;
while size(pos1,1) > 100
    idx = fix(mod((idx+1),size(pos1,1)))+1;
    if rand() < prob
        pos1(idx,:) = [];
    end
end

pos2 = find_matches(I1,pos1,I2);

figure(10);clf();
subplot(1,3,1);imshow(I1);subplot(1,3,2);imshow(I2);subplot(1,3,3);
showMatchedFeatures(I1,I2,pos1,pos2,"blend","PlotOptions",{'g.','r.','y-'});
title("pos1 to pos2")