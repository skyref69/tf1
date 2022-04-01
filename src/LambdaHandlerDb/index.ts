import { updateStateVoteDb } from '../interfaces/UpdateVoteDb.interface';
import { DynamoDB } from 'aws-sdk'
import { UpdateItemInput } from 'aws-sdk/clients/dynamodb';
import { Converter } from 'aws-sdk/clients/dynamodb';

const dynamoClient = new DynamoDB({})

export const LambdaHandlerDbFunction = async(event: any) => {    
  
  if(!event) return sendFail('invalid request: body undefined !')
  //if(!event.token) return sendFail('invalid request: token undefined !')  
  const id: string = event.dataOpened.id
  const taskToken:string = 'wudehffu9443gng43g'  
      
  try {
    const todoParams: UpdateItemInput = {
      Key: Converter.marshall({id: id}),
      UpdateExpression: 'set taskToken = :taskToken',
      ConditionExpression: 'attribute_exists(id)',
      ExpressionAttributeValues: Converter.marshall({':taskToken': taskToken,}),
      ReturnValues: 'ALL_NEW',
      TableName: 'DATABASE-TEST-TERRAFORM'
    };  
    const { Attributes } = await dynamoClient.updateItem(todoParams).promise();
    const todo = Attributes ? Converter.unmarshall(Attributes) : null;
    return {
      statusCode: 200,
      body: JSON.stringify({ todo })
  };
} catch (err) {
  console.error(err);
  return sendFail('something went wrong');
}
}

const sendFail = (message: string) => {    
    return message   
}