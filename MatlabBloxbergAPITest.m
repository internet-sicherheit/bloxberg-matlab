%  ['name', buffersize], 'outputpath', 'certificatename.pdf', buffersize]
MBB = MatlabBloxbergAPI('Hans Franz', 51200);
%  ['name', buffersize, 'outputpath', 'certificatename']
% MBB = MatlabBloxbergAPI('Hans Franz', 51200, 'https://certify.bloxberg.org/certifyData', 'https://certify.bloxberg.org/generateCertificate');
MBB = certifyData(MBB, 'matlab.mat');
generateCertificate(MBB, 'C:\Users\Dominik\Desktop', 'mycertificate.pdf');