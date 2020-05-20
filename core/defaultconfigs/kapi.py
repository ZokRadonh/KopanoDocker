#!/usr/bin/env python3
import kcconf

# Component specific configurations
kcconf.configkopano({
    r"/tmp/kopano/kapid.cfg":
    {
        # Certain configuration can be pre-defined at startup:
        #'listen': "0.0.0.0:8039",
    }
})

# Override configs from environment variables
kcconf.configkopano(kcconf.parseenvironmentvariables(r"/tmp/kopano/"))
