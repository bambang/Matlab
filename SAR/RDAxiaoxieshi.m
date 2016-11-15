%2016/11/8
%Liu Yakun

clc,clear,close all;
C = 3e8;%����
fc = 1e9;%�ز�Ƶ��
lambda = C / fc;%����
v = 200;%�״�ƽ̨�ٶ�
% h = 5000;
D = 2;%���߳���
theta = 10 / 180 * pi;%б�ӽ�
beta = lambda / D;%��������
yc = 10000;%��������б��
xc = yc * tan(theta);%���״ﲨ�����Ĵ�Խ�������ĵ�ʱ�״�����Ϊ��0��0���㣬�������ĵ�ķ�λ������

wa = 100;%��λ�����
wr = 100;%���������
xmin = xc - wa/2;%��λ��߽��
xmax = xc + wa/2;%��λ��߽��
ymin = yc - wr/2;%������߽��
ymax = yc + wr/2;%������߽��

rnear = ymin/cos(theta-beta/2);%���б��
rfar = ymax/cos(theta+beta/2);%��Զб��

a = 0.7;
b = 0.6;

targets = [xc + a*wa/2,yc + b*wr/2
           xc + a*wa/2,yc - b*wr/2
           xc - a*wa/2,yc + b*wr/2
           xc - a*wa/2,yc - b*wr/2
           xc         ,yc         ];


xbegin = xc - wa/2 - ymax*tan(theta+beta/2);%��ʼ���䳡���ķ�λ������
xend = xc + wa/2 - ymin*tan(theta - beta/2);%��������ʱ�ķ�λ������
ka = -2*v^2*cos(theta)^3/lambda/yc;%��λ���Ƶ��
% lsar = beta * yc / cos(theta);%�ϳɿ׾���
lsar = yc * (tan(theta + beta/2) - tan(theta - beta/2));%�ϳɿ׾���
tsar = lsar/v;%�ϳɿ׾�ʱ��
ba = abs(ka * tsar);%������Ƶ��
tr = 2e-6;%�������ʱ��
br = 50e6;%�������
kr = br / tr;%�������Ƶ��

% PRFmin = ba + 2*v*br*sin(theta)/C;
% PRFmax = 1/(2*tr+2*(rfar-rnear)/C);
% PRF = round(1.3 * ba);
% fs = round(1.2 * br);
alpha_slow = 1.3;%��λ���������
alpha_fast = 1.2;%�����������ϵ��
PRF = round(alpha_slow * ba);%��Ƶ
PRT = 1 / PRF;%�����ظ�����
Fs = alpha_fast * br;%�����������
Ts = 1 / Fs;%������������
Na = round((xend - xbegin)/v/PRT);%��λ���������
Na = 2^nextpow2(Na);%Ϊ��fft�����µ���
Nr = round((tr + 2*(rfar-rnear)/C)/Ts);%�������������
Nr = 2^nextpow2(Nr);%Ϊ��fft�����µ���
% PRF = Na / ((xend - xbegin)/v);
% fs = Nr / (tr + 2*(rfar-rnear)/C);
% tslow = linspace(xbegin/v,xend/v,Na);
ts = [-Na/2:Na/2 - 1]*PRT;%��λ����ʱ������
tf = [-Nr/2:Nr/2 - 1]*Ts + 2*yc/C;%�����������
range = tf*C/2;%������




ntargets = size(targets,1);%��Ŀ�����
echo = zeros(Na,Nr);%��ʼ����Ŀ��
for i = 1:ntargets
    xi = targets(i,1);%��λ������
    yi = targets(i,2);%����������
    tci = ((xi - xc) - (yi - yc)*tan(theta)) / v;%�������Ĵ�Խʱ��
    rci = yi / cos(theta);%�������Ĵ�Խʱ��˲ʱб��
%     tsi = rci*(cos(theta)*tan(theta + beta/2) - sin(theta))/v;%������ʼ�����벨����������ʱ�̵ķ�λ��ʱ���
    tsi = yi * (tan(theta + beta/2 - tan(theta))) / v;
%     tei = rci*(sin(theta) - cos(theta)*tan(theta - beta/2))/v;%�������������벨����������ʱ�̵ķ�λ��ʱ���
    tei = yi * (tan(theta) - tan(theta - beta/2)) / v;
    ri = sqrt(yi^2 + (xi - v*ts).^2);%����ʱ���ڵ�˲ʱб��
    tau = 2 * ri / C;%��ʱ
    t = ones(Na,1)*tf - tau.'*ones(1,Nr);%t-tau����
    phase = pi*kr*t.^2 - 4*pi/lambda*(ri.'*ones(1,Nr));%��λ
    
    echo = echo + exp(1i*phase).* (abs(t)<tr/2) .* ((ts > (tci - tsi) & ts < (tci + tei))' * ones(1,Nr));
    
end
 
% ff = linspace(-Fs/2,Fs/2,Nr);
% f = fftshift(ff);

% t = linspace(-tr/2,tr/2,Nr);  %����ֱ������ƥ���˲���
% r = sqrt(yc^2 + (xc - v*ts).^2);
% f = kr * (ones(Na,1) * t - 2/C*r'*ones(1,Nr));
% ref_R = exp(1i*pi/kr*f.^2);
% signal_comp = ifty(fty(echo) .* ref_R);

t = tf - 2*yc/C;%��ʽ������ƥ���˲��� ��fft֮��ȡ����
ref_r = exp(1i*pi*kr*t.^2) .* (abs(t) < tr/2);
signal_rfat = fty(echo) .* (ones(Na,1) * conj(fty(ref_r)));
signal_comp = ifty(signal_rfat);%������ѹ֮����ź�
signal_rfaf = ftx(signal_rfat);%��ά�ź�
% signal_rtaf = ftx(signal_comp);
% d = sqrt(1 - (lambda * ))
% Ksrc = 

% d = sqrt(1-(lambda*fdoc/2/v)^2);
% ksrc = 2*v^2*fc^3*d^3/C/yc/fdoc;
% ref_R = exp(1i*pi*(1/kr-1/ksrc)*ff.^2);
% signal_comp = ifty(fty(echo) .* (ones(Na,1) * ref_R));
fdoc = round(2*v*sin(theta)/lambda);%����������Ƶ��
% fu = linspace(fdoc + PRF/2,fdoc - PRF/2,Na);
% fa = fftshift(fu);
% fu = ka * ts;
% d = sqrt(1 - (lambda*fu/2/v).^2);
% ksrc = 2*v^2*fc^3*d.^3/C/yc/fdoc^2;
% km = kr/(1 - kr / ksrc);
% ref_r = exp(1i*pi*km*t.^2) .* (abs(t) < tr/2);
% signal_comp1 = ifty(fty(echo) .* (ones(Na,1) * conj(fty(ref_r))));
% t = tf - 2*rnear/C;
% ref_src = exp(1i*pi*ksrc*t.^2) .* (abs(t) < tr/2);
% H_src = exp(-1i*pi*(ones(Na,1) * ff.^2)./(ksrc.' * ones(1,Nr))); 
% H_src = fty(ref_src);
% H_src = exp(-1i * pi * yc * C / (2 * v^2 * fc^3) * ((fu.^2 ./ d.^3)' * ones(1,Nr)) .* f.^2);
% signal_src = ifty(signal_rfaf .* H_src);

signal_RD = ftx(signal_comp);%������������ź�
signal_RCMC = zeros(Na,Nr);
win = waitbar(0,'��������ֵ');
for i = 1:Na
    for j = 1:Nr
        fai = fdoc + (i - Na/2) / Na * PRF;
        d = sqrt(1 - (lambda*fai/2/v)^2);
        r0 = (yc + (j - Nr/2)*Ts*C/2)*cos(theta);
        ksrc = 2*v^2*fc^3/C/r0*d^3/fai^2;
        
        rcm = r0*(1/d - 1);
        n_rcm = 2*rcm/C*Fs;
        
        delta_nrcm = n_rcm - ceil(n_rcm);
        
        if j + round(n_rcm) > Nr
            signal_RCMC(i,j) = signal_RD(i,Nr/2);
        else
            if delta_nrcm >= 0.5
                signal_RCMC(i,j) = signal_RD(i,j+ceil(n_rcm));
            else
                signal_RCMC(i,j) = signal_RD(i,j+floor(n_rcm));
            end
        end
    end
    waitbar(i/Na);
end
close(win);

fu = linspace(fdoc - PRF/2,fdoc + PRF/2,Na);
f = fftshift(fu);
d = sqrt(1 - (lambda*f/2/v).^2); 
ref_A = exp(1i*4*pi/lambda*(ones(Na,1)*range) .* (d'*ones(1,Nr)));
final_signal = iftx(signal_RCMC .* ref_A);

figure;
subplot(211);
imagesc(abs(echo));
xlabel('������');
ylabel('��λ��');
title('�ز��ź�');

subplot(212);
imagesc(abs(signal_comp));
xlabel('������');
ylabel('��λ��');
title('������ѹ֮����ź�');

figure;
subplot(211);
imagesc(abs())