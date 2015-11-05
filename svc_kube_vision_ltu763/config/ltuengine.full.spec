{
  "AMQP_BROKER_HOSTNAME": "%(LOCALHOST)s", 
  "AMQP_BROKER_PASSWORD": "ltu", 
  "AMQP_BROKER_PORT": 7792, 
  "BASE_DIRECTORY": "/opt/ltuengine76/core/lib/python2.7/site-packages", 
  "CACHE_DIRECTORY": "/opt/ltuengine76/run/cache", 
  "CACHE_LIFE_DURATION": "60", 
  "CELERY_TASKS_NB_PROCESSING_THREADS": 32, 
  "CONFIG_CACHE_DIRECTORY": "/opt/ltuengine76/run/cache/config", 
  "CONFIG_DIRECTORY": "/opt/ltuengine76/config", 
  "CONFIG_FILE_OUTPUT_DIRECTORY": "%(CONFIG_CACHE_DIRECTORY)s", 
  "CONSOLE_HANDLER_LOG_LEVEL": "INFO", 
  "CPP_LOGGER_LEVEL": "LOG_INFO", 
  "DATABASE_DATA_DIRECTORY": "/opt/ltuengine76/data/database", 
  "DATABASE_INSTALL_DIRECTORY": "/opt/ltuengine76/deps/database", 
  "DATAMODEL_DIRECTORY": "/opt/ltuengine76/core/share/ltu/saas/dataModel", 
  "DATA_DIRECTORY": "/opt/ltuengine76/data/ltu", 
  "DATA_DIRECTORY_ROOT": "/opt/ltuengine76/data", 
  "DB_APP_HOSTNAME": "%(LOCALHOST)s", 
  "DB_APP_TIMEOUT": "120000", 
  "DB_APP_USER": "%(DB_SI_USER)s", 
  "DB_APP_USER_PASSWORD": "%(DB_PASSWORD)s", 
  "DB_HOSTNAME": "%(LOCALHOST)s", 
  "DB_LOGGING_CACHE_SIZE": "0", 
  "DB_LOG_HOSTNAME": "%(DB_HOSTNAME)s", 
  "DB_LOG_TIMEOUT": 30000, 
  "DB_LOG_URL": "%(DB_TYPE)s://%(DB_LOG_USER)s:%(DB_LOG_USER_PASSWORD)s@%(DB_LOG_HOSTNAME)s:%(DB_PORT)s/saas_log", 
  "DB_LOG_URL_ADMIN": "%(DB_TYPE)s://%(DB_SI_USER)s:%(DB_SI_USER_PASSWORD)s@%(DB_SI_HOSTNAME)s:%(DB_PORT)s/saas_log", 
  "DB_LOG_USER": "%(DB_SI_USER)s", 
  "DB_LOG_USER_PASSWORD": "%(DB_PASSWORD)s", 
  "DB_PASSWORD": "mcCai2DT", 
  "DB_POOL_OVERFLOW": "10", 
  "DB_POOL_SIZE": "15", 
  "DB_PORT": 7791, 
  "DB_ROOT_PASSWORD": "ltu_engine", 
  "DB_ROOT_URL": "%(DB_TYPE)s://%(DB_ROOT_USER)s:%(DB_ROOT_PASSWORD)s@%(DB_HOSTNAME)s:%(DB_PORT)s/%(DB_TYPE)s", 
  "DB_ROOT_URL_ADMIN": "%(DB_TYPE)s://%(DB_SI_USER)s:%(DB_SI_USER_PASSWORD)s@%(DB_SI_HOSTNAME)s:%(DB_PORT)s/%(DB_TYPE)s", 
  "DB_ROOT_USER": "ltu", 
  "DB_SI_HOSTNAME": "%(DB_HOSTNAME)s", 
  "DB_SI_TIMEOUT": "%(DB_TIMEOUT)s", 
  "DB_SI_URL": "%(DB_TYPE)s://%(DB_SI_USER)s:%(DB_SI_USER_PASSWORD)s@%(DB_SI_HOSTNAME)s:%(DB_PORT)s/saas_si", 
  "DB_SI_URL_ADMIN": "%(DB_TYPE)s://%(DB_SI_USER)s:%(DB_SI_USER_PASSWORD)s@%(DB_SI_HOSTNAME)s:%(DB_PORT)s/saas_si", 
  "DB_SI_USER": "saas_admin", 
  "DB_SI_USER_PASSWORD": "%(DB_PASSWORD)s", 
  "DB_TEMPLATE_URL_ADMIN": "%(DB_TYPE)s://%(DB_APP_USER)s:%(DB_APP_USER_PASSWORD)s@%(DB_APP_HOSTNAME)s:%(DB_PORT)s/saas_app_template", 
  "DB_TIMEOUT": 10000, 
  "DB_TYPE": "postgres", 
  "DEPS_DIRECTORY": "/opt/ltuengine76/deps", 
  "DISPATCHER_INSTALL_DIRECTORY": "/opt/ltuengine76/deps/dispatcher", 
  "ENABLE_FILE_LOGGING": "True", 
  "ENABLE_KIMA_FILE_LOGGING": "True", 
  "ENABLE_LOG_PROFILING": false, 
  "ENABLE_SYSLOG": "False", 
  "ENGINE_LIBRARY_PATH": "/opt/ltuengine76/core/lib", 
  "EXPOSED_API_FORMATS": "json", 
  "FLEXLM_DIRECTORY": "/opt/ltuengine76/deps/license", 
  "FRONTOFFICE_BATCH_IMAGES_THUMB_URL_PREFIX": "/batchimage/thumb-200x200", 
  "FRONTOFFICE_BATCH_IMAGES_URL_PREFIX": "/batchimage", 
  "FRONTOFFICE_DEBUG": "false", 
  "FRONTOFFICE_EGG_NAME": "ltu-saas-frontoffice", 
  "FRONTOFFICE_EMAIL_TO": "%(TECH_SUPPORT_EMAIL)s", 
  "FRONTOFFICE_ERROR_EMAIL_FROM": "", 
  "FRONTOFFICE_FILTERS_CONFIG": "[filter:proxy-prefix]\nuse = egg:PasteDeploy#prefix\nprefix = %(FRONTOFFICE_URL_PREFIX)s\nscheme = %(FRONTOFFICE_SCHEME)s", 
  "FRONTOFFICE_LOG_ERRORS": "true", 
  "FRONTOFFICE_MAX_POST_SIZE_IN_MB": 25000, 
  "FRONTOFFICE_PUBLIC_IP_V4": "127.0.0.1", 
  "FRONTOFFICE_PUBLIC_IP_V6": "::1", 
  "FRONTOFFICE_QUERYLOGS_THUMB_URL_PREFIX": "/querylogs/thumb-200x200", 
  "FRONTOFFICE_QUERYLOGS_URL_PREFIX": "/querylogs", 
  "FRONTOFFICE_RESOURCE_DIR": "%(LTU_LIBRARIES_PATH)s/python2.7/site-packages/frontoffice/resources", 
  "FRONTOFFICE_SCHEME": "http", 
  "FRONTOFFICE_STATIC_THUMB_URL_PREFIX": "/image/thumb-200x200", 
  "FRONTOFFICE_STATIC_URL_PREFIX": "/image", 
  "FRONTOFFICE_URL_PREFIX": "/", 
  "HOSTS": {
    "ltu76": "%(INSTALL_TYPE)s"
  }, 
  "HW_HOSTNAME": "%(LOCALHOST)s", 
  "ID_SITE": "%(INSTALL_TYPE)s", 
  "INSTALL_ROOT_DIRECTORY": "/opt/ltuengine76", 
  "INSTALL_TYPE": "chiwa", 
  "INTEL_ARCHITECTURE_NB_BITS": 64, 
  "KIMA_DIRECTORY": "/opt/ltuengine76/data/ltu/kima", 
  "KIMA_LOGGING_FILE": "%(SAAS_LOG_DIR)s/kima-%%(kimaId)s.log", 
  "KIMA_NB_CORES": 10, 
  "KIMA_SERVER_LOGGING_FILE": "%(SAAS_LOG_DIR)s/kima-server-%%(kimaId)s.log", 
  "KIMA_SQLITE_FOLDER_PATH": "%(DATA_DIRECTORY)s/kima", 
  "LIBRARIES_PATH": "/opt/ltuengine76/core/lib", 
  "LICENSE_FILE": "/opt/ltuengine76/tmp/tmp.jehyCZcb1z/licence.lic", 
  "LICENSE_FOLDER": "%(CONFIG_DIRECTORY)s", 
  "LOCALHOST": "ltu76", 
  "LOG_CONFIG_DIR": "%(CONFIG_CACHE_DIRECTORY)s", 
  "LOG_DIRECTORY": "/opt/ltuengine76/logs", 
  "LTUCORE_DATA_PATH": "%(SYSPREFIX)s/share/ltu/data", 
  "LTU_BIN_HOME": "%(SYSPREFIX)s/bin", 
  "LTU_CLIENT_FOLDER_PATH": "E/3D57368", 
  "LTU_KIMA_BIN_32": "%(LTU_KIMA_BIN_64)s", 
  "LTU_KIMA_BIN_64": "%(SYSPREFIX)s/bin/ltusaas_StandaloneKimaServer_64", 
  "LTU_LIBRARIES_PATH": "/opt/ltuengine76/core/lib", 
  "MANAGER_HOSTNAME": "%(LOCALHOST)s", 
  "MANAGER_URI": "http://%(MANAGER_HOSTNAME)s:8081", 
  "MESSAGING_DATA_DIRECTORY": "/opt/ltuengine76/data/messaging", 
  "MESSAGING_INSTALL_DIRECTORY": "/opt/ltuengine76/deps/messaging", 
  "MODIFY_API_PORT": 7789, 
  "MODIFY_SERVER_URI": "http://%(LOCALHOST)s:%(MODIFY_API_PORT)s/api/v2.0/ltumodify/json", 
  "OPENMP_NUM_THREADS": 1, 
  "PID_DIRECTORY": "/opt/ltuengine76/run", 
  "PLATFORM": "linux", 
  "PROCESSOR_ADMIN_PORT": 7788, 
  "PROCESSOR_NB_CORES": 10, 
  "PROCESSOR_PORT": 7790, 
  "PROCESSOR_SERVERS": "upstream processor {\n  \tserver ltu76:7790;\n  }\n\n  server {\n    listen   %(MODIFY_API_PORT)s;\n    listen [::]:%(MODIFY_API_PORT)s default ipv6only=on;\n    
access_log  %(SAAS_LOG_DIR)s/dispatcher_access.log disp;\n\n    # ---------- Manage compressed transactions ---------\n    gzip on;\n    gzip_http_version 1.1;\n    gzip_vary on;\n    
gzip_comp_level 6;\n    gzip_proxied any;\n    gzip_types application/json text/xml application/xml;\n    gzip_buffers 16 8k;\n    gzip_disable MSIE [1-6].(?!.*SV1);\n\n    # ---------- 
Maximum buffer size -------------\n    client_body_buffer_size 20m;\n\n    # ---------- Find Client IP (Use for proxy chain)\n    if ($http_ltu_forwarded_for = '') {\n      set $ltu_ip 
$remote_addr;\n    }\n    if ($http_ltu_forwarded_for != '') {\n      set $ltu_ip $http_ltu_forwarded_for;\n    }\n\n    # ---------- V2 ltumodify ----------\n    location 
/api/v2.0/ltumodify/ {\n      proxy_pass http://processor/api/v2.0/ltumodify/;\n      client_max_body_size 20m;\n      proxy_redirect off;\n      proxy_set_header Host $host;\n      
proxy_set_header X-Real-IP $remote_addr;\n      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n      proxy_set_header LTU-Forwarded-For $ltu_ip;\n      proxy_connect_timeout 
5;   # Assign timeout for the connection to the upstream server\n      proxy_send_timeout 30;     # Assign timeout with the transfer of request to the upstream server\n      
proxy_read_timeout 25;     # The time until the server returns the pages\n    }\n  }", 
  "QUERY_API_PORT": 8080, 
  "QUERY_LOGS_CACHE_SIZE": "10", 
  "QUERY_LOGS_DIR_PATH": "%(DATA_DIRECTORY)s/query", 
  "REPORTS_DIR_PATH": "%(DATA_DIRECTORY)s/reports", 
  "ROOT_INSTALL_DIRECTORY": "/opt/ltuengine76", 
  "SAAS_DECOMPRESS_FOLDER": "/opt/ltuengine76/tmp/tmp.jehyCZcb1z", 
  "SAAS_LOG_DIR": "%(INSTALL_ROOT_DIRECTORY)s/logs", 
  "SAAS_STATIC": "/saas/static", 
  "SALES_SUPPORT_EMAIL": "sales@ltutech.com", 
  "SEARCH_THREAD_POOL_SIZE": 32, 
  "SERVER_HOST": "0.0.0.0", 
  "SERVICES": {
    "frontoffice": [
      "ltu76"
    ], 
    "license": [
      "ltu76"
    ], 
    "app_database": [
      "ltu76"
    ], 
    "app_worker": [
      "ltu76"
    ], 
    "log_database": [
      "ltu76"
    ], 
    "si_database": [
      "ltu76"
    ], 
    "storage": [
      "ltu76"
    ], 
    "db_creator": [
      "ltu76"
    ], 
    "admin_worker": [
      "ltu76"
    ], 
    "dispatcher": [
      "ltu76"
    ], 
    "manager": [
      "ltu76"
    ], 
    "other": [
      "ltu76"
    ], 
    "messaging": [
      "ltu76"
    ], 
    "kima": [
      "ltu76"
    ], 
    "processor": [
      "ltu76"
    ], 
    "weki": [
      "ltu76"
    ]
  }, 
  "SHARE_LTU_DIRECTORY": "%(SYSPREFIX)s/share/ltu", 
  "SHARE_LTU_SAAS_DIRECTORY": "%(SHARE_LTU_DIRECTORY)s/saas", 
  "SIMPLE_LOG_FORMAT": "%%(asctime)s [%%(threadName)s] %%(levelname)s [%%(name)s::%%(funcName)s] %%(message)s", 
  "SQLITE_CREATOR_COMMAND": "%(SYSPREFIX)s/bin/ltusaas_sqliteCreator_64", 
  "SQLITE_FOLDER": "%(TEMP_DIRECTORY)s/sqlite", 
  "STORAGE_DIR_PATH": "%(DATA_DIRECTORY)s/storage", 
  "SYSLOG_FACILITY": "LOG_LOCAL7", 
  "SYSLOG_HANDLER_LOG_LEVEL": "INFO", 
  "SYSLOG_LOG_FORMAT": "%(SYSLOG_LOG_FORMAT_PREFIX)s[%%(threadName)s] %%(levelname)s [%%(name)s::%%(funcName)s] %%(message)s", 
  "SYSLOG_LOG_FORMAT_PREFIX": "saas-standalone", 
  "ENABLE_SYSLOG": "True", 
  "ENABLE_FILE_LOGGING": "False",
  "SYSPREFIX": "/opt/ltuengine76/core", 
  "TECH_SUPPORT_EMAIL": "support@ltutech.com", 
  "TEMP_DIRECTORY": "/opt/ltuengine76/run/tmp", 
  "TG_ADMIN_FOLDER_PATH": "%(TEMP_DIRECTORY)s", 
  "VERSION_FILE": "/opt/ltuengine76/VERSION", 
  "WEKI_KIMA_NB_CONNECTIONS": 200, 
  "WEKI_NB_CORES": 10, 
  "WEKI_PORT": 8082, 
  "WEKI_SERVERS": "upstream weki {\n  \tserver ltu76:8082;\n  }\n\n  server {\n    listen %(QUERY_API_PORT)s;\n    listen [::]:%(QUERY_API_PORT)s default ipv6only=on;\n    access_log  
%(SAAS_LOG_DIR)s/dispatcher_access.log disp;\n\n    # ---------- Manage compressed transactions ---------\n    gzip on;\n    gzip_http_version 1.1;\n    gzip_vary on;\n    gzip_comp_level 
6;\n    gzip_proxied any;\n    gzip_types application/json text/xml application/xml;\n    gzip_buffers 16 8k;\n    gzip_disable MSIE [1-6].(?!.*SV1);\n\n    # ---------- Maximum buffer size 
-------------\n    client_body_buffer_size 20m;\n\n    # ---------- Find Client IP (Use for proxy chain)\n    if ($http_ltu_forwarded_for = '') {\n      set $ltu_ip $remote_addr;\n    }\n    
if ($http_ltu_forwarded_for != '') {\n      set $ltu_ip $http_ltu_forwarded_for;\n    }\n\n    # ---------- V2 ltuquery ----------\n    location /api/v2.0/ltuquery/ {\n      proxy_pass 
http://weki/api/v2.0/ltuquery/;\n      client_max_body_size 20m;\n      proxy_redirect off;\n      proxy_set_header Host $host;\n      proxy_set_header X-Real-IP $remote_addr;\n      
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n      proxy_set_header LTU-Forwarded-For $ltu_ip;\n      proxy_connect_timeout 5;   # Assign timeout for the connection to the 
upstream server\n      proxy_send_timeout 10;     # Assign timeout with the transfer of request to the upstream server\n      proxy_read_timeout 25;     # The time until the server returns 
the pages\n    }\n  }\n"
}
