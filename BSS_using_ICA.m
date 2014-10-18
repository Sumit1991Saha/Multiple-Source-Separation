function [S,A,W] = BSS_using_ICA()

%loading files
load('C:\Users\saha\Desktop\BTP\s1.mat');
load('C:\Users\saha\Desktop\BTP\s2.mat');
load('C:\Users\saha\Desktop\BTP\s3.mat');
load('C:\Users\saha\Desktop\BTP\A1.mat');


hmic = phased.OmnidirectionalMicrophoneElement;
ha = phased.ULA(5,0.05,'Element',hmic); % no. of microphones=5
c = 340;                         % sound speed, in m/s

fs=8000;   % in Hz
plot(s1);
xlabel('Time (sec)'); ylabel ('Amplitude (V)');
title('speech1'); ylim([-.6 .6]);

figure,plot(s2);
xlabel('Time (sec)'); ylabel ('Amplitude (V)');
title('speech2'); ylim([-.6 .6]);

figure,plot(s3);
xlabel('Time (sec)'); ylabel ('Amplitude (V)');
title('speech3'); ylim([-.6 .6]);

ang1 = [-30; 0];
ang2 = [60; 10];
angInt = [20; 0];


hCollector = phased.WidebandCollector('Sensor',ha,'PropagationSpeed',c,...
    'SampleRate',fs,'ModulatedInput', false);
sigSource = step(hCollector,[s1 s2 s3],[ang1 ang2 angInt]);

%rs = RandStream.create('mt19937ar','Seed',2008);
%noisePwr = 1e-4; % noise power
%sigNoise = sqrt(noisePwr)*randn(rs,size(sigSource));
%sigArray = sigSource + sigNoise;

figure,plot(sigSource(:,3));
xlabel('Time (sec)'); ylabel ('Amplitude (V)');
title('Signal Received at Microphone 3'); ylim([-.6 .6]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X=sigSource';
newvectors = zeros(size(X));
meanvalue = mean(X')';
newvectors = X-meanvalue*ones(1,size(X,2));
mixedsig=newvectors;
mixedmean = meanvalue;
[Dim, NumOfSampl] = size(mixedsig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating PCA

covarianceMatrix = cov(mixedsig',1);
% Calculate the eigenvalues and eigenvectors of covariance
% matrix.
[E, D] = eig(covarianceMatrix);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Whitening the data
  
whiteningMatrix = inv(sqrt(D))*E';
dewhiteningMatrix = E*sqrt(D);
whitesig = whiteningMatrix*mixedsig;
cov(whitesig')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating the ICA
 verbose           = 'on'; 
% Default values for 'pcamat' parameters 
firstEig          = 1; 
lastEig           = Dim; 
interactivePCA    = 'off'; 
  
% Default values for 'fpica' parameters 
approach          = 'defl'; 
numOfIC           = 3; 
g                 = 'pow3'; 
finetune          = 'off'; 
a1                = 1; 
a2                = 1; 
myy               = 1; 
stabilization     = 'off'; 
epsilon           = 0.0001; 
maxNumIterations  = 1000; 
maxFinetune       = 5; 
initState         = 'rand'; 
guess             = 0; 
sampleSize        = 1; 
displayMode       = 'off'; 
displayInterval   = 1; 

% Calculate the ICA with fixed point algorithm.
[A, W] = fpica(whitesig,  whiteningMatrix, dewhiteningMatrix, approach, ...
numOfIC, g, finetune, a1, a2, myy, stabilization, epsilon, ...
maxNumIterations, maxFinetune, initState, guess, sampleSize, ...
displayMode, displayInterval, verbose); 

icasig = W * mixedsig + (W * mixedmean) * ones(1, NumOfSampl);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure,plot(icasig(1,:));
xlabel('Time (sec)'); ylabel ('Amplitude (V)');
title('speech1R'); ylim([-30 30]);

figure,plot(icasig(2,:));
xlabel('Time (sec)'); ylabel ('Amplitude (V)');
title('speech2R'); ylim([-30 30]);

figure,plot(icasig(3,:));
 xlabel('Time (sec)'); ylabel ('Amplitude (V)'); 
title('laughterR'); ylim([-30 30]);

