classdef MatlabBlockbergAPI
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant = true)
        URL_CERTIFY = 'https://certify.bloxberg.org/certifyData';
        URL_VERTIFY = 'https://certify.bloxberg.org/generateCertificate';
    end
    
    properties(GetAccess = 'private', SetAccess = 'private')
        authorName
        timestamp
  
        matlabFile
        hexString
        checksum
        
        txHash
        
        certificateOutputPath
        certificateName
        pdfData
    end
    
    methods
        
         function MBBAPI = MatlabBlockbergAPI(name, matlabFile, certificateOutputPath, certificateName)
            
            disp('Initialize MatlabBlocksbergAPI...');
             
            MBBAPI.authorName = name; 
            MBBAPI.matlabFile = matlabFile;
            MBBAPI.certificateOutputPath = certificateOutputPath;
            MBBAPI.certificateName = certificateName;
            
            MBBAPI = MBBAPI.createHash(MBBAPI.matlabFile);
            MBBAPI = MBBAPI.certifyData();
            MBBAPI = MBBAPI.generateCertificate();
            MBBAPI = MBBAPI.createCertificate();
            
        end
        
        function MBBAPI = createHash(MBBAPI, filename)
            disp('Creating Hash...');
            
%             fileID = fopen(filename, 'r');
%             bits = fread(fileID, 'ubit1', 'ieee-le');
%             
%             sha256hasher = System.Security.Cryptography.SHA256Managed;
%             sha256 = uint8(sha256hasher.ComputeHash(bits));
%             MBBAPI.checksum = lower(convertCharsToStrings(dec2hex(sha256)));
%             disp(['Created hash:  ' MBBAPI.checksum]);
            
            sha256hasher = System.Security.Cryptography.SHA256Managed;
            sha256 = uint8(sha256hasher.ComputeHash(uint8(filename))); %consider the string as 8-bit characters
            MBBAPI.checksum = lower(convertCharsToStrings(dec2hex(sha256)));
            disp(['Created hash:  ' MBBAPI.checksum]);
        end
        
        function MBBAPI = certifyData(MBBAPI)
            
            disp('Certify data...');
            
            timestampString = num2str(floor(posixtime(datetime('now'))));
            
            certifyOptionsStruct = struct('checksum', MBBAPI.checksum, 'authorName', MBBAPI.authorName, 'timestampString', timestampString);
            certifyStruct = struct('certifyVariables', certifyOptionsStruct);

            options = weboptions('RequestMethod', 'post', 'ArrayFormat','json', 'Timeout', 3000);
            certifiyData = webwrite(MBBAPI.URL_CERTIFY, certifyStruct, options);
            
            MBBAPI.txHash = certifiyData.txReceipt.transactionHash;

            disp(certifiyData.msg);
            disp(['txHash: ' certifiyData.txReceipt.transactionHash]);
        end
        
        function MBBAPI = generateCertificate(MBBAPI)
            
            disp('Generate certificate...');
            
            verifyOptionsStruct = struct('transactionHash', MBBAPI.txHash);
            verifyStruct = struct('certificateVariables', verifyOptionsStruct);
            
            options = weboptions('RequestMethod', 'post', 'ArrayFormat','json', 'Timeout', 10000);

            getGeneratedCertificate = webwrite(MBBAPI.URL_VERTIFY, verifyStruct, options);
            
            MBBAPI.pdfData = convertCharsToStrings( char(getGeneratedCertificate) );
        end
        
        function MBBAPI = createCertificate(MBBAPI)
            fileID = fopen([MBBAPI.certificateOutputPath '\' MBBAPI.certificateName], 'w');
            bytes = (unicode2native(MBBAPI.pdfData, 'ISO-8859-1'));
            fwrite(fileID, bytes, 'uint8');
            fclose(fileID);

            disp(['Certificate worte to ' MBBAPI.certificateOutputPath '\' MBBAPI.certificateName]);
        end
    end
end

