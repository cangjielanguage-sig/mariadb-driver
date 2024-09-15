package cjmd.cdbc
import cdbc.UpdateResult

public class UpdateResultImpl <: UpdateResult {

    private var _effectRow: Int64 = 0
    
    private var _lastInsertId: Int64 = 0

    public UpdateResultImpl(effectRowCount: Int64, lastInsertId: Int64){
        _effectRow = effectRowCount
        _lastInsertId = lastInsertId
    }


    public override prop lastInsertId: Int64 {
        get() {
            _lastInsertId
        }
    }

    public override prop effectRow: Int64 {
        get() {
            _effectRow
        }
    }

}