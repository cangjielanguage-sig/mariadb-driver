package cjmd.jdbc

public enum IsolationLevel {
    
    | Unsupported
    | ReadUncommitted 
    | ReadCommitted 
    | RepeatableRead 
    | Serializable 

}