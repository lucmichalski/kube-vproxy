API's - Two Distinct Categories: MODIFY & QUERY

All LTU engine queries fall into one of two general API categories: MODIFY or QUERY. 

:!: For LTU engine/ON demand, the url of the query examples given in the following pages should be modified as follows :
MODIFY - https://api.ltu-engine.com/v2/ltumodify/json/
QUERY - https://api.ltu-engine.com/v2/ltuquery/json/

For LTU engine/server
MODIFY - addressed via port 7789
QUERY - addressed via port 8080

API Category	Port	Example
Modify	7789	http://ltu76:7789/api/v2.0/ltumodify/json/AddImage
Query	8080	http://ltu76:8080/api/v2.0/ltuquery/json/SearchImageByUpload

# Colors by Upload
curl -sL -F "image_content=@pinpin.jpg" 'http://hostaddress:8080/api/v2.0/ltuquery/json/GetImageColorsByUpload?application_key=PXly9fRUfUt0oizKTcmpzFS8AAtqrTgI'

# Similarity by Upload
curl -sL 'http://hostaddress:8080/api/v2.0/ltuquery/json/SearcImageByColors?application_key=PXly9fRUfUt0oizKTcmpzFS8AAtqrTgI&colors=FF6633&colors=FF99'

# Image Fine Comparison
curl -F "reference_image=@fic1.jpg" -F "query_image=@fic2.jpg" "http://hostaddress:8080/api/v2.0/ltuquery/json/FineComparison?application_key=VmLGHUj9yXA731RD0Hzp9svWCb5MtMY1"

# Application ID status
curl -sL 'http://hostaddress:7789/api/v2.0/ltumodify/GetApplicationStatus?application_key=PXly9fRUfUt0oizKTcmpzFS8AAtqrTgI'

# Forwarding logs to syslog
"SYSLOG_HANDLER_LOG_LEVEL": "INFO", 
"SYSLOG_LOG_FORMAT_PREFIX": "saas-standalone", 
"SYSLOG_LOG_FORMAT": "%(SYSLOG_LOG_FORMAT_PREFIX)s[%%(threadName)s] %%(levelname)s [%%(name)s::%%(funcName)s] %%(message)s", 
"SYSLOG_FACILITY": "LOG_LOCAL7", 
"ENABLE_SYSLOG": "True", 
"ENABLE_FILE_LOGGING": "False",

# Backup data
cd <directory/where/you/unzip/your/ltuengine/archive/> 
./scripts/backup.sh <directory/to/you/ltuengine/installation> <directory/to/store/your/backup>

# Restore data
/etc/init.d/ltud stop 
cd <directory/to/you/ltuengine/installation> 
rm -rf <installation/directory> 
tar xvf <path/to/your/archive/file>  
/etc/init.d/ltud restart all

# All PIDs are in  /opt/ltuengine76/run/

# Fixed application keys for LTU 7.63
app_01 / jX3BRTUDVVKcR6uR9T3FRpmsHScT4zG5
app_02 / kSZ3qWSwxx75UQviQvsKz67MMfeEvgDh
app_03 / 9SXtdxsdNi8xXDZcThVLzKGDLbjESwAA
app_04 / 6gbJeEq2TXnnK2xcMJCXqgJwBbm89SzS
app_05 / JMuhnVvnReQZyuL4dDrCSJwK9jQCPyHi
app_06 / LPuw5wyne6F3Rz9W4WCF2SxPcqdRjXBZ
app_07 / dFkeFPEiTeD2z3jGYf5Ri5dSGEwzQ7bg
app_08 / wti8GZm3bqLs4HZb4M8vTef4JJSPx2J8
app_09 / 7bDdXDmUkBzJLMaCCfBtAtc2wFLtQTch
app_10 / iDdjWWDCRUcyQtmMNyvtsyLLzym9CRem
