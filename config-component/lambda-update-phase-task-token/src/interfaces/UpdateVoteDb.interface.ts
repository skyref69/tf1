// export interface updateStateVoteDb {
//   request: { 
//     id: string, 
//     poolStatus: "open" | "closed";    
//   },
//   token: string;
// }

// const id:string = event.otherInput.dataOpened.id
// const taskToken:string = event.token 

export interface updateStateVoteDb {
  otherInput: { 
    dataOpened: {
      id: string, 
      poolStatus: "open" | "closed"; 
    }       
  },
  token: string;
}