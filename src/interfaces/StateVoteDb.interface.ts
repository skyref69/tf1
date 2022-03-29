export interface stateVoteDb {
  Records: { 
    eventID: string, 
    eventName: string,
    eventVersion: string,
    eventSource: string,
    awsRegion: string,
    dynamodb: {
      Keys: {
        id: {
          S: string
        }
      },
      NewImage: {
        id: { S: string };
        Message: { S: string };
        poolStatus: { S: string };
        taskToken: { S: string };
      },
      ApproximateCreationDateTime: number,
      SequenceNumber: string,
      SizeBytes: number,
      StreamViewType: string
    },
    eventSourceARN: string
  }[];
}