

# variable names
source_bucket=hongyusuoriginal
target_bucket=${source_bucket}resized
function=CreateThumbnail

# role name
lambda_execution_role_name=lambda-$function-execution
lambda_execution_access_policy_name=lambda-$function-execution-access
lambda_invocation_role_name=lambda-$function-invocation
lambda_invocation_access_policy_name=lambda-$function-invocation-access
log_group_name=/aws/lambda/$function

# bucket
aws s3 mb s3://$source_bucket
aws s3 mb s3://$target_bucket
aws s3 cp HappyFace.jpg s3://$source_bucket/

# js
curl -O https://raw.githubusercontent.com/hongyusu/AmazonCodes/master/AWSExample/CreateThumbnail.js

# package
npm install async gm
zip -r $function.zip $function.js node_modules

#
lambda_execution_role_arn=$(aws iam create-role \
  --role-name "$lambda_execution_role_name" \
  --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }' \
  --output text \
  --query 'Role.Arn'
)
echo lambda_execution_role_arn=$lambda_execution_role_arn


aws iam put-role-policy \
  --role-name "$lambda_execution_role_name" \
  --policy-name "$lambda_execution_access_policy_name" \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:*"
        ],
        "Resource": "arn:aws:logs:*:*:*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject"
        ],
        "Resource": "arn:aws:s3:::'$source_bucket'/*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject"
        ],
        "Resource": "arn:aws:s3:::'$target_bucket'/*"
      }
    ]
  }'
  
  
  
  
  # upload package
  aws lambda upload-function \
    --function-name "$function" \
    --function-zip "$function.zip" \
    --role "$lambda_execution_role_arn" \
    --mode event \
    --handler "$function.handler" \
    --timeout 30 \
    --runtime nodejs
  
  
aws lambda create-function \
	--region us-west-2 \
	--function-name "$function" \
	--zip "fileb://$function.zip" \
	--role "$lambda_execution_role_arn" \
	--handler "$function.handler" \
	--timeout 30 \
	--runtime nodejs \
	--timeout 10 \
	--memory-size 1024
  
  
  
  
cat > $function-data.json <<EOM
{  
   "Records":[  
      {  
         "eventVersion":"2.0",
         "eventSource":"aws:s3",
         "awsRegion":"us-east-1",
         "eventTime":"1970-01-01T00:00:00.000Z",
         "eventName":"ObjectCreated:Put",
         "userIdentity":{  
            "principalId":"AIDAJDPLRKLG7UEXAMPLE"
         },
         "requestParameters":{  
            "sourceIPAddress":"127.0.0.1"
         },
         "responseElements":{  
            "x-amz-request-id":"C3D13FE58DE4C810",
            "x-amz-id-2":"FMyUVURIY8/IgAtTv8xRjskZQpcIZ9KG4V5Wp6S7S/JRWeUWerMUE5JgHvANOjpD"
         },
         "s3":{  
            "s3SchemaVersion":"1.0",
            "configurationId":"testConfigRule",
            "bucket":{  
               "name":"$source_bucket",
               "ownerIdentity":{  
                  "principalId":"A3NL1KOZZKExample"
               },
               "arn":"arn:aws:s3:::$source_bucket"
            },
            "object":{  
               "key":"HappyFace.jpg",
               "size":1024,
               "eTag":"d41d8cd98f00b204e9800998ecf8427e",
               "versionId":"096fKKXTRTtl3on89fVO.nfljtsv6qko"
            }
         }
      }
   ]
}
EOM


aws lambda invoke-async \
  --function-name "$function" \
  --invoke-args "$function-data.json"


# 
lambda_invocation_role_arn=$(aws iam create-role \
  --role-name "$lambda_invocation_role_name" \
  --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
            "Service": "s3.amazonaws.com"
          },
          "Action": "sts:AssumeRole",
          "Condition": {
            "StringLike": {
              "sts:ExternalId": "arn:aws:s3:::*"
            }
          }
        }
      ]
    }' \
  --output text \
  --query 'Role.Arn'
)
echo lambda_invocation_role_arn=$lambda_invocation_role_arn
  
  
aws iam put-role-policy \
  --role-name "$lambda_invocation_role_name" \
  --policy-name "$lambda_invocation_access_policy_name" \
  --policy-document '{
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "lambda:InvokeFunction"
         ],
         "Resource": [
           "*"
         ]
       }
     ]
   }'
  
  
  
  
   # get function arn
   
   lambda_function_arn=$(aws lambda get-function-configuration \
     --function-name "$function" \
     --output text \
     --query 'FunctionArn'
   )
   echo lambda_function_arn=$lambda_function_arn
  
  
  
  
  
  
  
  
  
  
  
  
  
  