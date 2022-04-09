import { updateStateVoteDb } from "./interfaces/UpdateVoteDb.interface";
import { DynamoDB } from "aws-sdk"
import { UpdateItemInput } from "aws-sdk/clients/dynamodb";
import { Converter } from "aws-sdk/clients/dynamodb";
import process = require('process');

const dynamoClient = new DynamoDB({})

export const LambdaUpdatePhaseTaskTokenFunction = async(event: updateStateVoteDb) => {  

  if(!event) return sendFail("invalid request: body undefined !")
  if(!event.token) return sendFail("invalid request: token undefined !")  
 
  const id:string = event.otherInput.dataOpened.id
  const taskToken:string = event.token 
  let TableName: string = process.env.DATABASENAME!
 
  try {
    const todoParams: UpdateItemInput = {
      Key: Converter.marshall({id: id}),
      UpdateExpression: "set taskToken = :taskToken",
      ConditionExpression: "attribute_exists(id)",
      ExpressionAttributeValues: Converter.marshall({":taskToken": taskToken,}),
      ReturnValues: "ALL_NEW",      
      TableName: TableName 
    };  
    const { Attributes } = await dynamoClient.updateItem(todoParams).promise();
    const todo = Attributes ? Converter.unmarshall(Attributes) : null;
    return {
      statusCode: 200,
      body: JSON.stringify({ todo })
  };
} catch (err) {
  console.error(err);
  return sendFail("something went wrong");
}
}

const sendFail = (message: string) => {    
    return message   
}