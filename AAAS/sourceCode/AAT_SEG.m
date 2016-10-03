function [segmat] = AAT_SEG(figname)
qwe = 0;
h = waitbar(qwe,'请稍等','CreateCancelBtn','delete(gcbf)');
hBtn = findall(h, 'type', 'uicontrol');
set(hBtn, 'string', '取消', 'FontSize', 10);
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
      

  
load([figname]);
load('seg15.mat');
        qwe = qwe + 0.07;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
        

% patch extraction
patchsize = 17; half1 = floor(patchsize/2);
poolsize2 = 5; patchsize2 = patchsize*poolsize2; half2 = floor(patchsize2/2);
window_avg2 = 1/(poolsize2*poolsize2)*ones(poolsize2);


% image preprocessing
img = img/max(img(:));
img = single(img);

% abdomen part
[xx1,yy1] = find(lab==1); [xx2,yy2] = find(lab==2); [xx3,yy3] = find(lab==3); 
satidx = find(lab==1); vatidx = find(lab==2); natidx = find(lab==3);
idx = [satidx;vatidx;natidx];
% clear lab
        qwe = qwe + 0.04;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);

SAT = length(xx1); VAT = length(xx2); NAT = length(xx3); 

seg = [ones(SAT,1);ones(VAT,1)*2;ones(NAT,1)*3]; % label information for each pixel

data85 = zeros(size(seg,1),patchsize^2);
data17 = zeros(size(seg,1),patchsize^2);
[xxx,yyy]=size(img);

tt = 0;
        qwe = qwe + 0.07;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
       
hello(SAT,patchsize2,half2,xx1,yy1,xxx,yyy,img,window_avg2,poolsize2,data85,half1,data17,tt,patchsize);
for i = 1:SAT
    
    x = xx1(i); y = yy1(i);
    
    patch = zeros(patchsize2,patchsize2);
    xdelta1 = min(half2,x-1);  xdelta2 = min(half2,xxx-x); ydelta1 = min(half2,y-1); ydelta2 = min(half2,yyy-y);
    patch(half2+1-xdelta1:half2+1+xdelta2,half2+1-ydelta1:half2+1+ydelta2) = img(max(x-half2,1):min(x+half2,xxx),max(y-half2,1):min(y+half2,yyy));
    
    
    avg = conv2(patch,window_avg2,'valid'); avg_compress2 = avg(1:poolsize2:end,1:poolsize2:end);
    data85(tt+i,:) = avg_compress2(:)';
    clear avg avg_compress2 patch

    patch = zeros(patchsize,patchsize);
    xdelta1 = min(half1,x-1);  xdelta2 = min(half1,xxx-x); ydelta1 = min(half1,y-1); ydelta2 = min(half1,yyy-y);
    patch(half1+1-xdelta1:half1+1+xdelta2,half1+1-ydelta1:half1+1+ydelta2) = img(max(x-half1,1):min(x+half1,xxx),max(y-half1,1):min(y+half1,yyy));
    
   data17(tt+i,:) = patch(:)';
    clear patch
    if(mod(i,fix(SAT/11))==0)
         qwe = qwe + 0.01;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
    end
    
end
        %qwe = qwe + 0.11;
      % waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);

  
tt = SAT;
for i = 1:VAT
    
    x = xx2(i); y = yy2(i);
    patch = zeros(patchsize2,patchsize2);
    xdelta1 = min(half2,x-1);  xdelta2 = min(half2,xxx-x); ydelta1 = min(half2,y-1); ydelta2 = min(half2,yyy-y);
    patch(half2+1-xdelta1:half2+1+xdelta2,half2+1-ydelta1:half2+1+ydelta2) = img(max(x-half2,1):min(x+half2,xxx),max(y-half2,1):min(y+half2,yyy));
    avg = conv2(patch,window_avg2,'valid'); avg_compress2 = avg(1:poolsize2:end,1:poolsize2:end);
    data85(tt+i,:) = avg_compress2(:)';
%     clear avg avg_compress2 patch
 clear avg avg_compress2 patch

     patch = zeros(patchsize,patchsize);
    xdelta1 = min(half1,x-1);  xdelta2 = min(half1,xxx-x); ydelta1 = min(half1,y-1); ydelta2 = min(half1,yyy-y);
    patch(half1+1-xdelta1:half1+1+xdelta2,half1+1-ydelta1:half1+1+ydelta2) = img(max(x-half1,1):min(x+half1,xxx),max(y-half1,1):min(y+half1,yyy));
    
    data17(tt+i,:) = patch(:)';
    clear patch
    if(mod(i,fix(VAT/10))==0)
         qwe = qwe + 0.01;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
    end
end
        %qwe = qwe + 0.1;
        %waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);

tt = SAT + VAT;
for i = 1:NAT
    
    x = xx3(i); y = yy3(i);
    patch = zeros(patchsize2,patchsize2);
    xdelta1 = min(half2,x-1);  xdelta2 = min(half2,xxx-x); ydelta1 = min(half2,y-1); ydelta2 = min(half2,yyy-y);
    patch(half2+1-xdelta1:half2+1+xdelta2,half2+1-ydelta1:half2+1+ydelta2) = img(max(x-half2,1):min(x+half2,xxx),max(y-half2,1):min(y+half2,yyy));
    avg = conv2(patch,window_avg2,'valid'); avg_compress2 = avg(1:poolsize2:end,1:poolsize2:end);
    data85(tt+i,:) = avg_compress2(:)';
%     clear avg avg_compress2 patch
 clear avg avg_compress2 patch

     patch = zeros(patchsize,patchsize);
    xdelta1 = min(half1,x-1);  xdelta2 = min(half1,xxx-x); ydelta1 = min(half1,y-1); ydelta2 = min(half1,yyy-y);
    patch(half1+1-xdelta1:half1+1+xdelta2,half1+1-ydelta1:half1+1+ydelta2) = img(max(x-half1,1):min(x+half1,xxx),max(y-half1,1):min(y+half1,yyy));
    
    data17(tt+i,:) = patch(:)';
    clear patch
    if(mod(i,fix(NAT/11))==0)
         qwe = qwe + 0.01;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
    end
end
       % qwe = qwe + 0.11;
       % waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);

data85 = single(data85);
data17 = single(data17);
% clear img;


%forward propogation
 % forward propogation for testing
    N = size(data17,1);
    
    % local features;
    XX1 = [data17 ones(N,1)];
    w11probs = 1./(1+exp(-XX1*w11)); w11probs = [w11probs ones(N,1)]; % N*(l21+1);
    qwe = qwe + 0.03;
    waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);

    w21probs = 1./(1+exp(-w11probs*w21)); %w21probs = [w21probs ones(N,1)]; % N*(l3)
    qwe = qwe + 0.03;
    waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
    % global features;
    XX2 = [data85 ones(N,1)];
    w12probs = 1./(1+exp(-XX2*w12)); w12probs = [w12probs ones(N,1)];% N*(l22+1);
    qwe = qwe + 0.03;
    waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
    w22probs = 1./(1+exp(-w12probs*w22)); %w22probs = [w22probs ones(N,1)]; % N*l3

    qwe = qwe + 0.03;
    waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
    % feature fusion
    w2probs = [w21probs w22probs ones(N,1)]; % N*(l21+l22+1);
    qwe = qwe + 0.04;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
        w3probs = 1./(1+exp(-w2probs*w3)); 
        qwe = qwe + 0.07;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
%     w3probs = [w3probs  ones(N,1)]; % N*(l4+1)
    % adding new features;
%     w3probs = [w3probs feas];
    
    w3probs = [w3probs  ones(N,1)]; % N*(l4+1)
            qwe = qwe + 0.11;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
    temp = w3probs*w_class;
    targetout = exp(temp-max(temp(:)));
     qwe = qwe + 0.04;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
    targetout = targetout./repmat(sum(targetout,2),1,3);
    
    [dump,segvec] = max(targetout,[],2);
    
            qwe = qwe + 0.05;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
    % segmentation results
    segmat = ones(size(img))*4;
    segmat(idx) = segvec;
    qwe = qwe + 0.03;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);
    Out = uint8(segmat);
    mkdir('dat');
    dlmwrite(['dat\' figname '.dat'], Out, '\t');
    qwe = qwe + 0.02;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);

    save([figname ], 'segmat');
        qwe = qwe + 0.02;
        waitbar(qwe, h, ['当前进度：' num2str(qwe*100) '%']);

      delete(h);
    clear h;

    
    % imshow
   % figure(1)
   % imshow(img);
   % title('original MR image');
   % figure(2)
   % imagesc(lab);
   % title('manual segmentation');
    %figure(3)
    %imagesc(segmat);
   % title('our segmentation');
    