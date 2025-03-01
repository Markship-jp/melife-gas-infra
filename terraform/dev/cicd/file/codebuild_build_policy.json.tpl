{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:ap-northeast-1:${AWS_ACCOUNT_ID}:log-group:/aws/codebuild/${BUILDPROJECT_NAME}",
                "arn:aws:logs:ap-northeast-1:${AWS_ACCOUNT_ID}:log-group:/aws/codebuild/${BUILDPROJECT_NAME}:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Effect": "Allow",
            "Resource": [
                "${S3_BUCKET_ARN}",
                "${S3_BUCKET_ARN}/*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:codebuild:ap-northeast-1:${AWS_ACCOUNT_ID}:report-group/${BUILDPROJECT_NAME}*"
            ]
        }
    ]
}