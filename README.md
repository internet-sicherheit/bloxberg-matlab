#Matlab Bloxberg implementation

##Description

This is a Matlab API to certify and verify reseach data with
the Bloxberg Network.

##Usage

###1. Creating the MatlabBloxbergAPI instance

First the user has to create an instance of the MatlabBloxbergAPI by
calling on of the constructor functions.

Exsample:
```
MBB = MatlabBloxbergAPI('[AUTHORNAME]', [BUFFERSIZE]);

MBB = MatlabBloxbergAPI('[AUTHORNAME]', [BUFFERSIZE], '[CERTIFYURL]', '[VERIFYURL]');
```
The [CERTIFYURL] has to be https://certify.bloxberg.org/certifyData and 
the [VERIFYURL] https://certify.bloxberg.org/generateCertificate to
communicate with the Bloxberg Network.

###2. Certifing the research data

After creating the instance of the API the user certifies the data by
calling the certifyData function.

Exsample:
```
MBB = certifyData(MBB, '[RESEARCHFILENAME]');
```
The [RESEARCHFILENAME] can be any type of Data. recommended is to certify
a .mat file.

###3. Generating the Certificate

At least the user generates a certificate of the research data by calling
the generateCertificate function.

Exsample:
```
generateCertificate(MBB, '[CERTIFICATEOUTPUTPATH]', '[CERTIFICATEFILENAME]');
```
The [CERTIFICATEOUTPUTPATH] specifies the path of the certificate
and [CERTIFICATEFILENAME] is the name of the generated certificate.
