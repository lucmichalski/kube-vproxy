#!/bin/bash
curl -X POST -H "Content-Type: application/json" http://192.168.99.100:8182/v2/frontends/front_kubeFactor/middlewares \
     -d '{
         "Middleware": {
                         "Id": "front_kubeFactor_Connect",
                         "Priority": 3,
	                 "Type": "kubeConnect",
		         "Middleware":{
		                       "Status":503,
		                        "BodyWithHeaders": "Content-Type: application/json\n\n{\"status\": \"###Status###\",  \"result\": [\"###Results###\"]}"
		   }
	     }
      }' | jq .
