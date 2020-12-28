function [pos2] = find_matches(I1,pos1,I2)
    % For interests point given by pos1 in I1, find the correspondences
    % of those interest points in I2.
    %
    % Author: Yuhao Li, Nov 2020
    %
    % Input
    %   I1: RGB image in double format taken from one view point.
    %   pos1: A n-by-2 matrix of interest points in I1.
    %   I2: RGB image taken from another view point, in double format 
    %       which might contains correspondences of interest points 
    %       specified by pos1 in I1.
    % Output
    %   pos2: A n-by-2 matrix of correspondence to pos1 for I1.
    
    % Find interest points and descriptors
    % I1
    [desc11,vp11] = getDescriptors(I1,"Harris");
    [desc12,vp12] = getDescriptors(I1,"SURF");
    [desc13,vp13] = getDescriptors(I1,"BRISK");
    % I2
    [desc21,vp21] = getDescriptors(I2,"Harris");
    [desc22,vp22] = getDescriptors(I2,"SURF");
    [desc23,vp23] = getDescriptors(I2,"BRISK");
    
    % Find matches
    matches1 = matchFeatures(desc11,desc21,"Method","Approximate");
    matches2 = matchFeatures(desc12,desc22,"Method","Approximate");
    matches3 = matchFeatures(desc13,desc23,"Method","Approximate");
    mf11 = vp11(matches1(:,1),:);
    mf21 = vp21(matches1(:,2),:);
    mf12 = vp12(matches2(:,1),:);
    mf22 = vp22(matches2(:,2),:);
    mf13 = vp13(matches3(:,1),:);
    mf23 = vp23(matches3(:,2),:);
    mf1 = cat(2,mf11.Location,mf21.Location);
    mf2 = cat(2,mf12.Location,mf22.Location);
    mf3 = cat(2,mf13.Location,mf23.Location);
    data = cat(1,mf1,mf2,mf3);
    fprintf("matches: %d",size(data,1));
    
    figure(1);clf(); 
    showMatchedFeatures(I1,I2,data(:,1:2),data(:,3:4),"blend","PlotOptions",{'g.','r.','y-'});
    title("matched");
    
    % fit transformation model
    transR = fitgeotrans(data(:,1:2),data(:,3:4),"projective");
    
    % Output
    [transX,transY] = transformPointsForward(transR,pos1(:,1),pos1(:,2));
    pos2 = cat(2,transX,transY);
end

function [descriptors,valid_points] = getDescriptors(I,method)
    I = im2gray(I);
    if method == "Harris"
        features = detectHarrisFeatures(I);
    elseif method == "SURF"
        features = detectSURFFeatures(I);
    elseif method == "BRISK"
        features = detectBRISKFeatures(I);
    end
    [descriptors,valid_points] = extractFeatures(I,features);
end