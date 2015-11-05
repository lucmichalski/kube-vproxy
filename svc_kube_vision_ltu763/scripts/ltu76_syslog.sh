#!/bin/bash

"SYSLOG_HANDLER_LOG_LEVEL": "INFO", 
"SYSLOG_LOG_FORMAT_PREFIX": "saas-standalone", 
"SYSLOG_LOG_FORMAT": "%(SYSLOG_LOG_FORMAT_PREFIX)s[%%(threadName)s] %%(levelname)s [%%(name)s::%%(funcName)s] %%(message)s", 
"SYSLOG_FACILITY": "LOG_LOCAL7", 
"ENABLE_SYSLOG": "True", 
"ENABLE_FILE_LOGGING": "False",

ltusaas-generate-config-files -i /opt/ltuengine76/config/ltuengine.spec -m all -o /opt/ltuengine76/env/run/cache/config ltud restart all
