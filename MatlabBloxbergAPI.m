classdef MatlabBloxbergAPI
    % MATLABBLOXBERGAPI An API to interact with the Bloxberg blockchain.
    % This class provides functions to verify and certify science data
    % with the Bloxberg Blockchain.
    
    properties(GetAccess = 'private', SetAccess = 'private')
        url_certify             % Constant for the certify URL of Bloxberg
        url_vertify             % Constant for the verify URL of Bloxberg
        
        authorName              % Name of the author
        timestamp               % Timestamp in milliseconds
        
        buffersize              % Size of the buffer for hash calculation
 
        checksum                % Hash of the resultfile
        
        txHash                  % Transaction hash that is recived from Bloxberg
        pdfData                 % PDF-bytecode recived from Bloxberg
    end
    
    methods
        function MBBAPI = MatlabBloxbergAPI(varargin)
         % MATLABBLOXBERGAPI Constructor of the MatlabBloxbergAPI class.
         % This function create an object of the API.
    
            if nargin == 2
                disp('Initialize MatlabBloxbergAPI...');
                MBBAPI.authorName = varargin{1}; 
                MBBAPI.buffersize = varargin{2};
                MBBAPI.url_certify = 'https://certify.bloxberg.org/certifyData';
                MBBAPI.url_vertify = 'https://certify.bloxberg.org/generateCertificate';
            elseif nargin == 4
                disp('Initialize MatlabBloxbergAPI...');
                MBBAPI.authorName = varargin{1}; 
                MBBAPI.buffersize = varargin{2};
                MBBAPI.url_certify = varargin{3};
                MBBAPI.url_vertify = varargin{4};
            else
                disp('Wrong number of arguments.');
            end
        end
        
        function MBBAPI = createHash(MBBAPI, filename)
        % CREATEHASH creates a Hash from a file.
        % This function creates a SHA-256 hash from the given file
        % that the author has inputed.
        
            disp('Creating Hash...');
            
            % import java libs (needed for hash function)
            import java.security.*;
            import java.math.*;

            % opens the resultfile with read rights
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
            disp(['    Runtime:  ' num2str(timeElapsed) ' seconds']);
        end
        
        function MBBAPI = certifyData(MBBAPI, filename)
        % CERTIFYDATA certifies the given file.
        % This function certifies the file with the SHA-256 hash.
        
            MBBAPI = createHash(MBBAPI, filename);
        
            disp('Certify data...');
            
            % creating a timestamp of the current system time
            timestampString = num2str(floor(posixtime(datetime('now'))));
            
            % bilding a json object out of structs that Bloxberg requires
            certifyOptionsStruct = struct('checksum', MBBAPI.checksum, 'authorName', MBBAPI.authorName, 'timestampString', timestampString);
            certifyStruct = struct('certifyVariables', certifyOptionsStruct);

            % setting up weboptions
            options = weboptions('RequestMethod', 'post', 'ArrayFormat','json', 'Timeout', 3000);
            % writing the request to Bloxberg and safing the response (json object) in certifyData
            certifiyData = webwrite(MBBAPI.url_certify, certifyStruct, options);
            
            disp(['    ' certifiyData.msg]);
            disp(['    Transaction hash:  ' certifiyData.txReceipt.transactionHash]);
            
            %safing the transaction hash from the response to txHash
            MBBAPI.txHash = certifiyData.txReceipt.transactionHash;
        end
        
        function generateCertificate(MBBAPI, certificateOutputPath, certificateName)
        % GENERATECERTIFICATE generates a certificate.
        % This function generates a certificationfile for the given file as
        % a pdf.
        
            disp('Generate certificate...');
            
            % bilding a json object out of structs that Bloxberg requires
            verifyOptionsStruct = struct('transactionHash', MBBAPI.txHash);
            verifyStruct = struct('certificateVariables', verifyOptionsStruct);
            
            % setting up weboptions
            options = weboptions('RequestMethod', 'post', 'ArrayFormat','json', 'Timeout', 10000);

            % writing the request to Bloxberg and safing the response 
            % (pdf-file) in generatedCertificate
            generatedCertificate = webwrite(MBBAPI.url_vertify, verifyStruct, options);
            
            % safing the bytecode of the PDF certificate to pdfData
            MBBAPI.pdfData = convertCharsToStrings( char(generatedCertificate) );
            
            createCertificate(MBBAPI, certificateOutputPath, certificateName);
        end
        
        function createCertificate(MBBAPI, certificateOutputPath, certificateName)
        % CREATECERTIFICATE creates a certificate.
        % This function creates a PDF certificate out of the response from
        % Bloxberg.
        
            % creates the PDF file
            fileID = fopen([certificateOutputPath '\' certificateName], 'w');
            % Get the bytecode from the pdfData
            bytes = (unicode2native(MBBAPI.pdfData, 'ISO-8859-1'));
            % writing the bytecode to the PDF file
            fwrite(fileID, bytes, 'uint8');
            fclose(fileID);

            disp(['    Certificate worte to ' certificateOutputPath '\' certificateName]);
        end
    end
end

