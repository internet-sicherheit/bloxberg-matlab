classdef MatlabBloxbergAPI
    % MATLABBLOXBERGAPI An API to interact with the Bloxberg Blockchain.
    % This class provides functions to verify and certify science data
    % with the Bloxberg Blockchain.
    
    properties(Constant = true)
        URL_CERTIFY = 'https://certify.bloxberg.org/certifyData';           % Constant for the certify URL of Bloxberg
        URL_VERTIFY = 'https://certify.bloxberg.org/generateCertificate';   % Constant for the verify URL of Bloxberg
    end
    
    properties(GetAccess = 'private', SetAccess = 'private')
        authorName              % Name of the author
        timestamp               % Timestamp in milliseconds
        
        buffersize              % Size of the buffer for hash calculation
  
        matlabFile              % Resultfile that the author wants to certify (<filename.mat>)
        checksum                % Hash of the resultfile
        
        txHash                  % Transaction hash that is recived from Bloxberg
        
        certificateOutputPath   % Outputpath of the certificate
        certificateName         % Name of the certificate
        pdfData                 % The recived PDF bytecode from Bloxberg
    end
    
    methods
        
         function MBBAPI = MatlabBloxbergAPI(name, matlabFile, certificateOutputPath, certificateName, buffersize)
         % MATLABBLOXBERGAPI Constructor of the MatlabBloxbergAPI class.
         % This function create an object of the API.
    
            disp('Initialize MatlabBloxbergAPI...');
             
            MBBAPI.authorName = name; 
            MBBAPI.matlabFile = matlabFile;
            MBBAPI.certificateOutputPath = certificateOutputPath;
            MBBAPI.certificateName = certificateName;
            MBBAPI.buffersize = buffersize;
            
            % called methods to certify and verify the resultfile
            MBBAPI = MBBAPI.createHash(MBBAPI.matlabFile);
            MBBAPI = MBBAPI.certifyData();
            MBBAPI = MBBAPI.generateCertificate();
            MBBAPI = MBBAPI.createCertificate();
            
            disp('MatlabBloxbergAPI closed.');
        end
        
        function MBBAPI = createHash(MBBAPI, filename)
        % CREATEHASH creates a Hash from a file.
        % This function creates a SHA-256 hash from the resultdata
        % that the author has inputed.
        
            disp('Creating Hash...');
            
            % import java libs
            import java.security.*;
            import java.math.*;

            % open the resultdata file with read rights
            fileID = fopen(filename, 'r');
            
            % provides a SHA-256 instance
            sha256 = MessageDigest.getInstance('SHA-256');
            
            % set up runtime clock
            tic;

            stop = 0;
            while stop == 0
                
            % reads the bytes of the resultfile in chunks by up setted buffersize
            [bytes, readedBytes] = fread(fileID, MBBAPI.buffersize, 'ubit8', 'ieee-le');
    
                if readedBytes < 1
                    stop = 1;
                else
                    % update hash with new readed bytes
                    sha256.update(bytes);
                end
            end
            % build complete hash
            hash = sha256.digest();
            
            % get termination time
            timeElapsed = toc;
            
            % convert hash to BigInteger
            bigInteger = BigInteger(1, hash);
            % convert BigInteger to String
            sha256Hash = char(bigInteger.toString(16));
            MBBAPI.checksum = sha256Hash;
            
            disp(['    Created hash:  ' MBBAPI.checksum]);   
            disp(['    Runtime: ' num2str(timeElapsed) ' seconds']);
            
        end
        
        function MBBAPI = certifyData(MBBAPI)
        % CERTIFYDATA certifies the resultdata.
        % This function certifies the resultdata with the SHA-256 hash
        % created before.
        
            disp('Certify data...');
            
            % creating a timestamp of the current system time
            timestampString = num2str(floor(posixtime(datetime('now'))));
            
            % bilding a json object out of structs
            certifyOptionsStruct = struct('checksum', MBBAPI.checksum, 'authorName', MBBAPI.authorName, 'timestampString', timestampString);
            certifyStruct = struct('certifyVariables', certifyOptionsStruct);

            % setting up weboptions
            options = weboptions('RequestMethod', 'post', 'ArrayFormat','json', 'Timeout', 3000);
            % writing the request to Bloxberg and safing the result in certifyData
            certifiyData = webwrite(MBBAPI.URL_CERTIFY, certifyStruct, options);
            
            %safing the transaction hash from the response to txHash
            MBBAPI.txHash = certifiyData.txReceipt.transactionHash;

            disp(['    ' certifiyData.msg]);
            disp(['    txHash: ' certifiyData.txReceipt.transactionHash]);
        end
        
        function MBBAPI = generateCertificate(MBBAPI)
        % GENERATECERTIFICATE generates a certificate.
        % This function generates certification file for the resultdata as
        % a pdf.
        
            disp('Generate certificate...');
            
            % bilding a json object out of structs
            verifyOptionsStruct = struct('transactionHash', MBBAPI.txHash);
            verifyStruct = struct('certificateVariables', verifyOptionsStruct);
            
            % setting up weboptions
            options = weboptions('RequestMethod', 'post', 'ArrayFormat','json', 'Timeout', 10000);

            % writing the request to Bloxberg and safing the response in
            % getGeneratedCertificate (bytecode of the PDF certificate)
            getGeneratedCertificate = webwrite(MBBAPI.URL_VERTIFY, verifyStruct, options);
            
            % safing the bytecode of the PDF certificate to pdfData
            MBBAPI.pdfData = convertCharsToStrings( char(getGeneratedCertificate) );
        end
        
        function MBBAPI = createCertificate(MBBAPI)
        % CREATECERTIFICATE creates a certificate.
        % This function creates a PDF certificate out of the bytecode that
        % has been saved before.
        
            % creates the PDF file
            fileID = fopen([MBBAPI.certificateOutputPath '\' MBBAPI.certificateName], 'w');
            % Get the bytecode from the pdfData
            bytes = (unicode2native(MBBAPI.pdfData, 'ISO-8859-1'));
            % writing the bytecode the the PDF file
            fwrite(fileID, bytes, 'uint8');
            fclose(fileID);

            disp(['    Certificate worte to ' MBBAPI.certificateOutputPath '\' MBBAPI.certificateName]);
        end
    end
end

