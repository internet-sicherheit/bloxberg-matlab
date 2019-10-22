%MBB = MatlabBlockbergAPI('Hans Franz', 'matlab.mat', 'C:\Users\Dominik\Desktop', 'mypdf9.pdf');

% methodsview('java.security.MessageDigest');

% md = MessageDigest.getInstance('MD5');
% hash = md.digest(double('Your string.'));
% bi = BigInteger(1, hash);
% test = char(bi.toString(16));
% disp(test);

import java.security.*;
import java.math.*;

md = MessageDigest.getInstance('SHA-256');
hash = md.digest(double('hello'));
bi = BigInteger(1, hash);
char(bi.toString(16))

% fileID = fopen('matlab.mat','r');

% bits = fread(fileID, 'ubit8', 'ieee-le');
% byte = fread(fileID,'uint8');
% byte = dec2hex(byte);
% bits = fread(fileID, 5,'ubit1');
% disp(byte);
% display(length(bits));
% string = '';
% tline = fgetl(fileID);
% while ischar(tline)
%      disp(tline)
%     string = [string tline];
%     tline = fgetl(fileID);
% end
% disp(string);

% sha256hasher = System.Security.Cryptography.SHA256Managed;
% sha256 = uint8(sha256hasher.ComputeHash(uint8('hallo'))); %consider the string as 8-bit characters
% checksum = dec2hex(sha256);
% display(checksum);
% 
% disp('Hash should be:  56711d042f230799e6205571bc67236292488568f6d1bfe4a97c25f237fcb488');
% disp(checksum);