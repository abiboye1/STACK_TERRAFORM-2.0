terraform{
         backend "s3"{
                bucket= "stackbuckstateabib-jen"
                key = "MULTI-TIER.tfstate"
                region="us-east-1"
                dynamodb_table="statelock-tf"
                 }
 }