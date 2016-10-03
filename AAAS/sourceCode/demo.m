%demo:
%for i = 1:64
    %str = strcat('N',num2str(i));
    %AAT_SEG(['N20']);
 % img = dicomread('PIC');
 % imagesc(img);
    %clear all;
%end
a = [];

for i = 1:32
    a = [a;lab];
end

a = uint8(a);
dlmwrite('aa.txt', a, '\t');