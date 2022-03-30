
import { updateStateVoteDb } from '../interfaces/UpdateVoteDb.interface';
import { DynamoDB, UpdateItemInput } from '@aws-sdk/client-dynamodb'
import { marshall, unmarshall } from '@aws-sdk/util-dynamodb'

const dynamoClient = new DynamoDB({})

export const LambdaHandlerDbFunction = async(event: updateStateVoteDb) => {    
    
  if(!event) return sendFail('invalid request: body undefined !')
  if(!event.token) return sendFail('invalid request: token undefined !')  

  const id: string = event.request.id
  const taskToken: string = event.token
  const todoParams: UpdateItemInput = {
    Key: marshall({ id }),
    UpdateExpression: 'set taskToken = :taskToken',
    ConditionExpression: 'attribute_exists(id)',
    ExpressionAttributeValues: marshall({
      ':taskToken': taskToken,  
    }),
    ReturnValues: 'ALL_NEW',
    TableName: process.env.TODO_TABLE_NAME
  };
  
  try {    
    const { Attributes } = await dynamoClient.updateItem(todoParams)       
    return console.log('Update dynamoDb ok !')    
  } catch (err) {
      console.error(err)
      return sendFail('Something went wrong')
  }
}

const sendFail = (message: string) => {    
    return console.log(message)   
}