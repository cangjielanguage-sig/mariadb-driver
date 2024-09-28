package cjmd.jdbc

public enum IsolationLevel <: Equatable<IsolationLevel> {
    
    | Unsupported
    | ReadUncommitted 
    | ReadCommitted 
    | RepeatableRead 
    | Serializable 

    private func value(): Byte {
        match (this) {
            case Unsupported => 0
            case ReadUncommitted => 2
            case ReadCommitted => 4
            case RepeatableRead => 8
            case Serializable => 16
        }
    }

    public operator func ==(right: IsolationLevel): Bool{
        this.value() == right.value()
    }

}