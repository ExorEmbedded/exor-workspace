Corvina Cloud Service Integration
=================================
#### Version:        `0.1`
#### Last modified:  `22/11/2017`

### Introduction

This documents describes the process of integrating [Corvina
Cloud](https://corvina.cloud/) Services into customer's 3rd party systems.

The provided software allows Devices (gateways) to autonomously connect to a
Cloud Server, making their services available to end users via:
- **Web Browsers**, for general monitoring and a given subset of web-based client
applications (e.g. RDP, VNC, SSH);
- **Corvina Cloud App**, for a wider range of scenarios requiring full
Virtual Private Network connectivity.

_IMPORTANT NOTE_: forwarding to Endpoints (behind gateways) is currently not
integrated in the packages provided; information on handling this scenario can
be provided upon request.

The software consists of two components:
* **libencloud**, containing the core logic to setup the connection and control
via REST API;
* **encloud**, which provides a basic daemon wrapper for libencloud and a
sample startup script.

Both of the above packages have an
unrestrictive [MIT license](https://opensource.org/licenses/MIT) license for the cloud
connectivity scenario, so customers are totally free to integrate them in
closed/proprietary systems.

### Building from source

Yocto recipes can be provided upon request, but some generic guidelines follow.
If the target device CPU architecture differs from the build machine's, we
assume that an appropriate _cross-compilation environment/toolchain has already
been sourced_.

#### System prerequisites

- TUN/TAP kernel module

#### libencloud

Dependencies: Qt4 (core, network), OpenVPN, QJson

Fetch libencloud repo from https://github.com/ExorEmbedded/libencloud.git and
enter the stable branch:

    $ git checkout exorint-1.x.x

Compile and install:

    $ qmake -r CONFIG+="exor splitdeps modeqcc nogui notest"
    $ make
    $ INSTALL_ROOT="${DESTDIR}" make install

, where `DESTDIR` is the staging directory as defined by the build system.

#### encloud

Dependencies: Qt4 (core), libencloud

Fetch encloud repo from https://github.com/ExorEmbedded/encloud and enter the
stable branch:

    $ git checkout exorint-1.x.x

Compile and install:

    $ qmake -r CONFIG+="exor splitdeps modeqcc noservice"
    $ make
    $ INSTALL_ROOT="${DESTDIR}" make install

, where `DESTDIR` is the staging directory as defined by the build system.

### Startup

Add appropriate Yocto `INIT_PARAMS` or equivalent to make encloud start at boot
(can be done directly via `update-rc.d` for SysV init - otherwise refer to docs
 of specific init system).

### Runtime usage

Once the service is configured to start at boot, we can use REST API calls to
setup cloud connectivity. 

Here we provide some samples based on
[cURL](https://curl.haxx.se/) as a _PROOF OF CONCEPT_, but such calls can be
performed using virtually any programming language according to customer's
software environment. Make sure any calling software is robust (e.g. error
checking, buffer management, etc) and well tested before integrating it
in production.

For more detailed information on the REST APIs, please refer to `doc/API.md` and
`doc/CONFIG.md` within the libencloud repository.

In the following examples, the API is used directly on the target
(`localhost`), but calls can be done also from external components on Local
Area Network if a reverse proxy is configured accordingly via a web server
(appropriate encryption/authentication layers strongly recommended).

Given the following variable definitions (and customizing them where necessary):

    $ CLOUD_URL="https://corvinacloud.com"
    $ CLOUD_USER='myuser/mydomain'
    $ CLOUD_PASS='mypass123!'
    $ SERVICE_URL="http://localhost:4804/api/v1"

#### 1. Configuration

First of all we start off with a configuration step (JSON format):

 	$ curl "${SERVICE_URL}/config" -H 'Content-Type: application/json' \
        -d '{ "autoretry" : true, "decongest" : true, "timeout" : 120, "ssl" : { "verify_ca" : false } }'

#### 2. Authentication

Then setup authentication data:

    $ curl "${SERVICE_URL}/auth" -d "url=${CLOUD_URL}" -d "user=${CLOUD_USER}" -d "pass=${CLOUD_PASS}"

_IMPORTANT NOTE_: customers are responsible for protecting stored credentials
according to local security requirements and policies.

#### 3. Cloud

Now start the cloud connection:

    $ curl "${SERVICE_URL}/cloud" -d "action=start"

To stop it:
    
    $ curl "${SERVICE_URL}/cloud" -d "action=stop"

_NOTE_: doing so, credentials are lost - if restart is required, rerun Authentication step (2).

#### Status

The Status API returns information relating to the logged user and current connection state:

    $ curl "${SERVICE_URL}/status"
    {"login": {"user": "usomgw"},"need": {},"progress": {"desc": "VPN tunnel active","step": 12,"total": 12},"state": 4}

### Troubleshooting

Make sure the service is listening on the default port:

    $ sudo netstat -nlp | grep encloud

Verbosity can be increased for debugging purposes by setting the `log/lev`
parameter in `/etc/encloud/libencloud.json` to `7` instead of `3` and
restarting the service (can also be specified at runtime via Config REST API).
