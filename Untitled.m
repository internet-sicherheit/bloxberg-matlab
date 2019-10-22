% string = 'some string'; 
% sha256hasher = System.Security.Cryptography.SHA256Managed;
% sha256 = uint8(sha256hasher.ComputeHash(uint8(string))); %consider the string as 8-bit characters
% hexString = convertCharsToStrings(sha256);
% 
% % certify Data
% checksum = ['0x'  hexString];
% authorName = 'Max Hans';
% timestampString = '1565256859';
% certifyOptionsStruct = struct('checksum', checksum, 'authorName', authorName, 'timestampString', timestampString);
% certifyStruct = struct('certifyVariables', certifyOptionsStruct);
% 
% url = 'https://certify.bloxberg.org/certifyData';
% 
% options = weboptions('RequestMethod', 'post', 'ArrayFormat','json', 'Timeout', 3000);
% certifiyData = webwrite(url, certifyStruct, options);
% 
% disp(certifiyData.msg);
% disp(certifiyData.txReceipt.transactionHash);

% generate certificate
%txHash = certifiyData.txReceipt.transactionHash;
txHash = '0x915343895c0b0d40eee1eaafe2d26e9298abedfee53c46f586cbcec641023fcf';
verifyOptionsStruct = struct('transactionHash', txHash);
verifyStruct = struct('certificateVariables', verifyOptionsStruct);

url = 'https://certify.bloxberg.org/generateCertificate';
options = weboptions('RequestMethod', 'post', 'ArrayFormat','json', 'Timeout', 10000);

getGeneratedCertificate = webwrite(url, verifyStruct, options);

disp(class(getGeneratedCertificate));
pdfData = convertCharsToStrings( char(getGeneratedCertificate) );

%write pdf certificate
filePath = 'C:\Users\Dominik\Desktop\certificate2.pdf';
fileID = fopen(filePath, 'w');
bytes = (unicode2native(pdfData, 'ISO-8859-1'));
fwrite(fileID, bytes, 'uint8');
fclose(fileID);

disp(['File worte to ' filePath]);