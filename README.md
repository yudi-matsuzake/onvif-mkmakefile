# makefile.sh

Script to generate the onvif's Makefile to generate the c++ client proxies code with gsoap (wsdhl2h and soapcpp2) based on the wsdl url in wsdl.txt file. This script are able to generate the environment for onvif's applications.

## features

* generate a Makefile based on wsdl.txt file with the url for the onvif wsdl specifications;

* Makefile will generate all modules with c++ namespaces and separeted in folders;

* autofix the gsoap code for c++ namespaces. The original code does not compile with c++ namespaces and onvif specifications.

## how to use

### 1. Generate the Makefile

( illustrative url )

```shell
$ git clone onvif-mkmakefile.git
$ mv onvif-mkmakefile .make
$ ./make/mkmakefile.sh > Makefile
```

### 2. Generate the modules code using the Makefile

```shell
$ make env devicemgmt/devicemgmt.hpp ptz/ptz.hpp
```

### 3. Compile the the source code using the macro `WITH_NOIDREF`

```shell
$ cd devicemgmt
$ g++ -c -DWITH_NOIDREF *.cpp
$ cd ../ptz
$ g++ -c -DWITH_NOIDREF *.cpp
```

* compile `env/*.cpp`

```shell
$ cd ../env
$ g++ -c *.cpp
```

### 3. Copy duration.c and stdsoap2.cpp from gsoap project for your project

* The duration.c and stdsoap2.cpp file must have the same version of your executables soapcpp2 and wsdl2h

### 4. Compile the duration.c

1. Change the file of the `#include` directive of soapH.h for DevicemgmtH.h or any module header in the duration.c file;
2. Compile the duration.c

```shell
$ mv duration.c devicemgmt
$ g++ -c devicemgmt/duration.c
```

### 5. Compile the stdsoap2.cpp with the macro `WITH_NONAMESPACES`

```shell
g++ -c -DWITH_NONAMESPACES stdsoap2.cpp 
```

### 6. Create a client program

*e.g. This program will request the DeviceInformation Method*:

```c++
#include <iostream>
#include "devicemgmt/devicemgmt.hpp"
#include "ptz/ptz.hpp"

using namespace std;

#define URL "http://169.254.1.20/onvif/services"

int main(){

	// create and inicialize soap context
	struct soap soap_context;
	soap_init(&soap_context);
	

	// class proxy
	Devicemgmt::DeviceBindingProxy device(&soap_context);
	Ptz::PTZBindingProxy ptx(&soap_context);

	// set namespaces after PTZBindgProxy inicialization
	soap_set_namespaces(&soap_context, Devicemgmt_namespaces);
	

	Devicemgmt::_tds__GetDeviceInformation device_request;
	Devicemgmt::_tds__GetDeviceInformationResponse device_response;

	std::string endpoint = URL;

	int result = SOAP_ERR;    

	result = device.GetDeviceInformation( endpoint.c_str(), NULL, 
	&device_request, device_response );

	if ( result == SOAP_OK )
	{
		std::cout << "Mfr: " << device_response.Manufacturer << std::endl;
		std::cout << "Model: " << device_response.Model << std::endl;
		std::cout << "F/W version: " << device_response.FirmwareVersion << std::endl;
		std::cout << "HardwareId: " << device_response.HardwareId << std::endl;
		std::cout << "Serial number:" << device_response.SerialNumber << std::endl;

	}else{
		std::cout << "ERROOO" << std::endl;
		std::cout << result << std::endl;
	}

	soap_destroy(&soap_context); // remove deserialized class instances (C++ only)
	soap_end(&soap_context); // clean up and remove deserialized data
	soap_done(&soap_context); // detach context (last use and no longer in scope)

	return 0;
}
```

### 7. Finally, compile the whole thing

```shell

$ g++ main.cpp devicemgmt/*.o ptz/*.o duration.o env/envC.o stdsoap2.o -o getDeviceInformation

```
