import * as AWS from 'aws-sdk'
import process = require('process');
import { stateVoteDb } from '../interfaces/StateVoteDb.interface'

let stepfunctions = new AWS.StepFunctions()

export const LambdaStartStepFunction = async(event: stateVoteDb) => {
    const id = event.Records[0].dynamodb.NewImage.id.S
    const poolStatus = event.Records[0].dynamodb.NewImage.poolStatus.S    
    const taskToken = event.Records[0].dynamodb.NewImage.taskToken.S
    try {      
        if(poolStatus === 'open' && taskToken === '0'){                           
          let params = {
            stateMachineArn: process.env.STATE_MACHINE_ARN,            
            input: JSON.stringify({"id": id, "poolStatus": poolStatus}),
        }        
        await stepfunctions.startExecution(params).promise();        
        }else if(poolStatus == 'closed'){
            let taskToken = event.Records[0].dynamodb.NewImage.taskToken.S          
            let params = {
                output: '{}',
                taskToken: taskToken
            }               
            await stepfunctions.sendTaskSuccess(params).promise();   
        }
    } catch (error) {
        console.log(error)        
    }    
    return "end"
}