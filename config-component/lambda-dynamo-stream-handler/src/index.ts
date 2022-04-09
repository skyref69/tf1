import * as AWS from "aws-sdk"
import process = require('process');
import { stateVoteDb } from "./interfaces/StateVoteDb.interface"

let stepfunctions = new AWS.StepFunctions()

export const LambdaDynamoStreamHandlerFunction = async(event: stateVoteDb) => {
    
    let id = event.Records[0].dynamodb.NewImage.id.S
    let poolStatus = event.Records[0].dynamodb.NewImage.poolStatus.S    
    let taskToken = event.Records[0].dynamodb.NewImage.taskToken.S    
    
    try {        
      switch (poolStatus) {
        case "opened":  
            console.log("Command opened vote received !");               
                if (taskToken === "0") {
                    let params = {
                        stateMachineArn: process.env.state_machine_arn!,
                        input: JSON.stringify({"dataOpened": {"id": id, "poolStatus": poolStatus}})
                    };
                    await stepfunctions.startExecution(params).promise();                  
                }                
                break;

            case "closed":
                console.log("Command closed vote received !");                         
                let params = {
                    output: "{}",
                    taskToken: taskToken            
                }               
                await stepfunctions.sendTaskSuccess(params).promise();  
                break;
        
            default:
                break;
        }
        
    } catch (error) {
        console.log(error)        
    }    
    return "end"
}