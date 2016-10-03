clear all
% % features display
load N1
%
% [gmag,gdir] = imgradient(img);
% % normalize gmag and gdir
% gmag = (gmag-min(gmag(:)))./(max(gmag(:))-min(gmag(:)));
% gdir = (gdir-min(gdir(:)))./(max(gdir(:))-min(gdir(:)));
% 
% % display images
% figure, imshow(gmag); title('gradient');
% figure, imshow(gdir); title('gdir');

% % % img normalization
img = img/max(img(:));
% %
% % % %img gradient
% % % [Gmag,Gdir] = imgradient(img);
% %
% % % active contour for abdomen mask;
% mask = zeros(size(img));
% mask(50:end-50,50:end-50) = 1;
% 
% bw = activecontour(img,mask,300);
% %
% % % boundary
% bd = []; kk = 1;
% %
% % % display the mask part
% [xx,yy] = find(bw==1);
% for k = 1:length(xx)
% 
%     i = xx(k); j = yy(k);
%     if bw(i-1,j)==0 ||bw(i+1,j)==0 ||bw(i,j+1) == 0 || bw(i,j-1)== 0 ||bw(i-1,j-1)==0 ||bw(i-1,j+1)==0 || bw(i+1,j-1)==0 || bw(i+1,j+1)==0
%         bd(kk,:) = [i,j];
%         kk = kk+1;
%     end
% end
% % %
% % % figure
% % % imshow(img,[0,max(img(:))]);
% % %
% % % hold on
% % % plot(bd(:,2),bd(:,1),'r.')
% %
% %
% % %% location information
% %
% dr = max(bd); % down + right
% ul = min(bd); % up + left
% center = (dr+ul).*0.5;
% % %
% % % hold on
% % % plot(center(1),center(2),'g*')
% %
% % %% almost located in the same angle was normalized to 1;
% %
% % % step1: computing polar radius and polar angles
% %
% Polarcords = size(length(xx),2);
% 
% for k = 1:length(xx)
% 
%     ij = [xx(k),yy(k)];
%     diff = ij - center;
%     Polarcords(k,1) = sqrt(diff(1)^2+diff(2)^2);
% 
%     diffx = diff(1); diffy = diff(2);
% 
% 
%     if diffx>0
% 
%         Polarcords(k,2) = atan(diffy/diffx);
% 
%     else
%         if diffx < 0
% 
%             if diffy < 0
%                 Polarcords(k,2) = atan(diffy/diffx)+pi;
%             else
%                 Polarcords(k,2) = atan(diffy/diffx)+pi/2;
%             end
%         else
%             if diffy > 0
%                Polarcords(k,2) = pi/2;
%             else
%                 Polarcords(k,2) = -pi/2;
%             end
%         end
%     end
% end
% 
% Polarcords = Polarcords + pi/2; % [0,2*pi];
% 
% %
% % load Polarcords
% 
% polar1 = Polarcords(:,2);
% radiu1 = Polarcords(:,1);
% 
% tt = 360;
% for ang = pi/tt:pi/tt:(2*pi+pi/tt)
%     
% %     lowbd = ang-pi/tt;
% %     upbd = ang;
%     ll = find(polar1<ang);
% %     l2 = find(polar1>=lowbd);
% %     ll = intersect(l1,l2);
%     if ~isempty(ll);
%         radiu1(ll) = radiu1(ll)/max(radiu1(ll));
%         polar1(ll) = inf;
%     end
%     
%     
% end
% 
% idx = find(bw==1);
% polarmap = zeros(size(img));
% polarmap(idx) = radiu1;
% 
% imagesc(polarmap)
% 
% 

%% algorithms 2 for polarmap
% abdomen part
[xx1,yy1] = find(lab==1); [xx2,yy2] = find(lab==2); [xx3,yy3] = find(lab==3); 
sat = find(lab==1); vat = find(lab==2); nat = find(lab==3);

clear lab

img = img/max(img(:)); % normalized to [0,1]

intensity = [img(sat);img(vat);img(nat)];

% step3: polarmap---radius
% algorihtm1 for center: abdomen mask;
% xmax = max(xx1); xmin = min(xx1);
% ymax = max(yy1); ymin = min(yy1);
% 
% center = zeros(1,2);
% center(1) = 0.5*(xmax+xmin); center(2)=0.5*(ymax+ymin);

% algorithm2 for center: center of the img;

center = [256,256];


%% computing polar radius and normalized to [0,1]
xx = [xx1;xx2;xx3]; yy = [yy1;yy2;yy3];

Polarcords = size(length(xx),2);

for k = 1:length(xx)

    ij = [yy(k),xx(k)];
    diff = ij - center;
    diffx = diff(1); diffy = diff(2);
    Polarcords(k,1) = sqrt(diffx^2+diffy^2); % distance;
    
    if diffx>0

        Polarcords(k,2) = atan(diffy/diffx);

    else
        if diffx < 0

            if diffy < 0
                Polarcords(k,2) = atan(diffy/diffx)+pi;
            else
                Polarcords(k,2) = atan(diffy/diffx)+pi/2;
            end
        else
            if diffy > 0
               Polarcords(k,2) = pi/2;
            else
                Polarcords(k,2) = -pi/2;
            end
        end
    end
end

Polarcords(:,2) = Polarcords(:,2) + pi/2; % [0,2*pi];

%
% load Polarcords

polar1 = Polarcords(:,2);
radiu1 = Polarcords(:,1);

tt = 200;
for ang = pi/tt:pi/tt:(2*pi+pi/tt)
    
    ll = find(polar1<=ang);
    if ~isempty(ll);
        radiu1(ll) = radiu1(ll)/max(radiu1(ll));
        polar1(ll) = inf;
    end
    
end
polarmap = zeros(512,512);
abdomen = [sat;vat;nat];
polarmap(abdomen) = radiu1;

figure
imshow(img);

hold on
plot(center(1),center(2),'g*')

figure
imagesc(polarmap)




