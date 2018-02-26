% Implementation of Laplacian Blob detector (By Downsampling the image)
% Created By: Akshay Chopra
% Person No.: 50248989
% Email: achopra6@buffalo.edu




src=dir('../data/*.jpg');

for iloop= 1: length(src)

    filename = strcat('../data/',src(iloop).name);  
    img=imread(filename);
   
    tic; % Recording internal execution time
    
    %Converting image to GrayScale
    img=rgb2gray(img);

    %If Image is not floating point type, we convert it
    if(~isfloat(img))
      img=im2double(img);
    end

    I=img;

    [h w]= size(img);
    n=1;
    scale_space = zeros(h,w,n);
    sigma=2;
    [r c]= size(img);
    img_sample=img;
    scale = 1;
    k = 1.28;


    %DownSampling the image by Scale, creating filter, applying the filter on
    %the image, UpSampling the image(to original size), storing filtered image
    %in scale space and then increasing the scale by factor k.
    for i=1:15

            img_down_sample=imresize(img_sample, 1/scale);   %DownSampling the Image by Scale

            filter = fspecial('log', 2*ceil(scale*3)+1, sigma);
            filter = sigma.^2 * filter;
            imgnew=imfilter(img_down_sample,filter,'replicate');

            imgnew=imgnew.*imgnew;

            imgnew=imresize(imgnew,[r c]);   %UpSampling the image to original size

            if n==1
                scale_space=imgnew;
            else
                scale_space=cat(3,scale_space,imgnew);
            end
            n=n+1;

            scale = scale * k;

    end


    %Performing Non Maximum Supression on each 2D layer of the Scale Space
    for i=1:15     

        cim = scale_space(:,:,i);

        mx = ordfilt2(cim,9,ones(3,3)) ; %Getting the maximas for the layer

        if i==1
            mx_new=mx;
        else
            mx_new=cat(3,mx_new,mx);
        end

    end


    %Finding Maximum values in the 3D Scale Space 
    nms_3d=max(mx_new,[],3);

    nms_3d= (nms_3d==mx_new).*mx_new;



    %Replacing all non maximum values with zeros (for every 2D scale space
    %slice). Finding coordinates of the maximas and drawing circles for that
    %maxima.
    % Important: Here We are increasing sigma only for the purpose of drawing
    % different size circles (different radius).

    for i=1: 15

        radius=1.414 * sigma; %Calculating Radius
        thresh=.007;

        cim = scale_space(:,:,i);

        cim = (cim==nms_3d(:,:,i))&(cim>thresh);

        [r,c] = find(cim);

        if i==1
            r1=r;
            c1=c;
            rad=radius;        
            rad=repmat(radius,size(r,1),1);

        else

            rad2=repmat(radius,size(r,1),1);
            rad=cat(1,rad,rad2);
            r1=cat(1,r1,r);
            c1=cat(1,c1,c);
        end
        sigma=sigma*k;
    end
    
    toc;    % Displaying Elapsed Time
    show_all_circles(I, c1, r1, rad,'r' , 1.5);
end



