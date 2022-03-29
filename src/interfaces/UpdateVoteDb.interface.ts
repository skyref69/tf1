export interface updateStateVoteDb {
  request: { 
    id: string, 
    poolStatus: "open" | "closed";    
  },
  token: string;
}