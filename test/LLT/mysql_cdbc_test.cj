// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./mainprotected package mysql.test.cdbc
package mysql
import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import mysql.cdbc.*
import std.time.*
import std.sync.*
import std.fs.*
import std.io.*
import std.math.numeric.*
import mysql.util.*
import encoding.json.*

@Test
public class MySqlTest {

    private static const INSERT_SQL: String = ###"insert into full_test (bool_col, tinyint_col, utinyint_col, smallint_col, usmallint_col, mediumint_col,
                                umediumint_col, int_col, uint_col, bigint_col, ubigint_col, float_col, double_col,
                                decimal_col, date_col, time_col, datetime_col,timestamp_col, year_col, char_col, varchar_col,
                                tinytext_col, text_col, mediumtext_col, longtext_col, tinyblob_col, blob_col, mediumblob_col,
                                longblob_col, json_col, set_col, enum_col) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"###

    private let connection: Connection

    init() {
        let driver = MySqlDriver()
        let username = ("username", "test_user")
        let password = ("password", "test_user")
        let database = ("database", "driver_test")
        let sslMode = ("ssl.mode", "disabled")
        //let prepareMode = ("prepare.mode","client")
        let prepareMode = ("prepare.mode", "server")
        let dataSource = driver.open("mysql://localhost", [username, password, database, sslMode, prepareMode])
        connection = dataSource.connect()
    }

    /*
     * 插入数据测试
     */
    @TestCase
    public func insertTest() {
        let prepare = connection.prepareStatement(INSERT_SQL)
        //bool
        let p0 = SqlBool(false)
        //tinyintm
        let p1 = SqlByte(-128)
        //utinyint
        let p2 = SqlSmallInt(0)
        //smallint
        let p3 = SqlSmallInt(-32768)
        //usmallint
        let p4 = SqlInteger(0)
        //mediumintl
        let p5 = SqlInteger(-8388608)
        //umediumint
        let p6 = SqlBigInt(0)
        //int
        let p7 = SqlBigInt(-2147483648)
        //uint
        let p8 = SqlInteger(0)
        //bigint
        let p9 = SqlBigInt(-9223372036854775808)
        //ubigint
        let p10 = SqlBigInt(0)
        //float
        let p11 = SqlReal(2355.785436875)
        //double
        let p12 = SqlDouble(2465.089728343)
        //decimal
        let p13 = SqlDecimal(Decimal.parse("1234.56789"))
        //date
        let p14 = SqlDate(DateTime.now())
        //time
        let p15 = SqlTime(DateTime.now())
        //datetime
        let p16 = SqlTimestamp(DateTime.now())
        //timestamp
        let p17 = SqlTimestamp(DateTime.now())
        //year
        let p18 = SqlSmallInt(2077)
        //char
        let p19 = SqlChar("我冒了严寒，回到相隔二千余里，别了二十余年的故乡去。")
        //varchar
        let p20 = SqlVarchar("时候既然是深冬；渐近故乡时，天气又阴晦了，冷风吹进船舱中")
        //tiny_text
        let p21 = SqlVarchar("于是我自己解释说：故乡本也如此，——虽然没有进步，也未必有如我所感的悲凉")
        //text
        let p22 = SqlVarchar(
            "我所记得的故乡全不如此。我的故乡好得多了。但要我记起他的美丽，说出他的佳处来，却又没有影像，没有言辞了。仿佛也就如此。"
        )
        //mediutext
        let p23 = SqlVarchar(
            "但我们终于谈到搬家的事。我说外间的寓所已经租定了，又买了几件家具，此外须将家里所有的木器卖去，再去增添。母亲也说好，而且行李也略已齐集，木器不便搬运的，也小半卖去了，只是收不起钱来。\r\n\r\n“你休息一两天，去拜望亲戚本家一回，我们便可以走了。”母亲说。\r\n\r\n“是的。”\r\n\r\n“还有闰土，他每到我家来时，总问起你，很想见你一回面。我已经将你到家的大约日期通知他，他也许就要来了。”\r\n\r\n这时候，我的脑里忽然闪出一幅神异的图画来：深蓝的天空中挂着一轮金黄的圆月，下面是海边的沙地，都种着一望无际的碧绿的西瓜，其间有一个十一二岁的少年，项带银圈，手捏一柄钢叉，向一匹猹⑵尽力的刺去，那猹却将身一扭，反从他的胯下逃走了。"
        )
        //longtext
        let p24 = SqlVarchar(
            "这少年便是闰土。我认识他时，也不过十多岁，离现在将有三十年了；那时我的父亲还在世，家景也好，我正是一个少爷。那一年，我家是一件大祭祀的值年⑶。这祭祀，说是三十多年才能轮到一回，所以很郑重；正月里供祖像，供品很多，祭器很讲究，拜的人也很多，祭器也很要防偷去。我家只有一个忙月（我们这里给人做工的分三种：整年给一定人家做工的叫长工；按日给人做工的叫短工；自己也种地，只在过年过节以及收租时候来给一定人家做工的称忙月），忙不过来，他便对父亲说，可以叫他的儿子闰土来管祭器的。\r\n\r\n我的父亲允许了；我也很高兴，因为我早听到闰土这名字，而且知道他和我仿佛年纪，闰月生的，五行缺土⑷，所以他的父亲叫他闰土。他是能装〔弓京〕捉小鸟雀的。\r\n\r\n我于是日日盼望新年，新年到，闰土也就到了。好容易"
        )
        //tinyblob
        let stream1 = ByteBuffer()
        stream1.write([])
        let p25 = SqlBlob(stream1)
        //blob
        let p26 = SqlBinary(
            [145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56, 67, 145, 67, 34, 12, 45, 32, 76, 90, 62,
                145, 24, 56, 234, 34, 235, 56, 67, 145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56,
                67, 145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56, 67])
        //mediumblob
        let stream3 = ByteBuffer()
        stream3.write(
            [145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56, 67, 145, 67, 34, 12, 45, 32, 76, 90, 62,
                145, 24, 56, 234, 34, 235, 56, 67, 145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56,
                67, 145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56, 67])
        let p27 = SqlBlob(stream3)
        //longblob
        // let stream4 = ByteBuffer(Array<Byte>(10485760, repeat: 0))
        let stream4 = ByteBuffer(Array<Byte>(1048576 * 5, repeat: 0))
        let p28 = SqlBlob(stream4)
        //json
        let json = JsonObject.fromStr('{"name":"yesokim", "age": 22, "sex": 1}')
        let p29 = SqlJson(json)
        //set
        let p30 = SqlChar("value1,value2")
        //enum
        let p31 = SqlChar("value1")
        let result = prepare.update(
            [p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23,
                p24, p25, p26, p27, p28, p29, p30, p31])
        println("effect rows: ${result.rowCount}")
        println("last insert id: ${result.lastInsertId}")
        prepare.close()
    }

    @TestCase
    public func insertNullableTest() {
        let prepare = connection.prepareStatement(INSERT_SQL)
        //bool
        let p0 = SqlNullableBool(true)
        //tinyint
        let p1 = SqlNullableByte(-128)
        //utinyint
        let p2 = SqlNullableSmallInt(0)
        //smallint
        let p3 = SqlNullableSmallInt(-32768)
        //usmallint
        let p4 = SqlNullableInteger(0)
        //mediumintl
        let p5 = SqlNullableInteger(-8388608)
        //umediumint
        let p6 = SqlNullableBigInt(0)
        //int
        let p7 = SqlNullableBigInt(-2147483648)
        //uint
        let p8 = SqlNullableInteger(0)
        //bigint
        let p9 = SqlNullableBigInt(-9223372036854775808)
        //ubigint
        let p10 = SqlNullableBigInt(0)
        //float
        let p11 = SqlNullableReal(2355.785436875)
        //double
        let p12 = SqlNullableDouble(2465.089728343)
        //decimal
        let p13 = SqlNullableDecimal(Decimal.parse("1234.56789"))
        //date
        let p14 = SqlNullableDate(DateTime.now())
        //time
        let p15 = SqlNullableTime(DateTime.now())
        //datetime
        let p16 = SqlNullableTimestamp(DateTime.now())
        //timestamp
        let p17 = SqlNullableTimestamp(DateTime.now())
        //year
        let p18 = SqlNullableSmallInt(2077)
        //char
        let p19 = SqlNullableChar("我冒了严寒，回到相隔二千余里，别了二十余年的故乡去。")
        //varchar
        let p20 = SqlNullableVarchar("时候既然是深冬；渐近故乡时，天气又阴晦了，冷风吹进船舱中")
        //tiny_text
        let p21 = SqlNullableVarchar("于是我自己解释说：故乡本也如此，——虽然没有进步，也未必有如我所感的悲凉")
        //text
        let p22 = SqlNullableVarchar(
            "我所记得的故乡全不如此。我的故乡好得多了。但要我记起他的美丽，说出他的佳处来，却又没有影像，没有言辞了。仿佛也就如此。"
        )
        //mediutext
        let p23 = SqlNullableVarchar(
            "但我们终于谈到搬家的事。我说外间的寓所已经租定了，又买了几件家具，此外须将家里所有的木器卖去，再去增添。母亲也说好，而且行李也略已齐集，木器不便搬运的，也小半卖去了，只是收不起钱来。\r\n\r\n“你休息一两天，去拜望亲戚本家一回，我们便可以走了。”母亲说。\r\n\r\n“是的。”\r\n\r\n“还有闰土，他每到我家来时，总问起你，很想见你一回面。我已经将你到家的大约日期通知他，他也许就要来了。”\r\n\r\n这时候，我的脑里忽然闪出一幅神异的图画来：深蓝的天空中挂着一轮金黄的圆月，下面是海边的沙地，都种着一望无际的碧绿的西瓜，其间有一个十一二岁的少年，项带银圈，手捏一柄钢叉，向一匹猹⑵尽力的刺去，那猹却将身一扭，反从他的胯下逃走了。"
        )
        //longtext
        let p24 = SqlNullableVarchar(
            "这少年便是闰土。我认识他时，也不过十多岁，离现在将有三十年了；那时我的父亲还在世，家景也好，我正是一个少爷。那一年，我家是一件大祭祀的值年⑶。这祭祀，说是三十多年才能轮到一回，所以很郑重；正月里供祖像，供品很多，祭器很讲究，拜的人也很多，祭器也很要防偷去。我家只有一个忙月（我们这里给人做工的分三种：整年给一定人家做工的叫长工；按日给人做工的叫短工；自己也种地，只在过年过节以及收租时候来给一定人家做工的称忙月），忙不过来，他便对父亲说，可以叫他的儿子闰土来管祭器的。\r\n\r\n我的父亲允许了；我也很高兴，因为我早听到闰土这名字，而且知道他和我仿佛年纪，闰月生的，五行缺土⑷，所以他的父亲叫他闰土。他是能装〔弓京〕捉小鸟雀的。\r\n\r\n我于是日日盼望新年，新年到，闰土也就到了。好容易"
        )
        //tinyblob
        let stream1 = ByteBuffer()
        stream1.write([])
        let p25 = SqlNullableBlob(stream1)
        //blob
        let p26 = SqlNullableBinary(
            [145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56, 67, 145, 67, 34, 12, 45, 32, 76, 90, 62,
                145, 24, 56, 234, 34, 235, 56, 67, 145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56,
                67, 145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56, 67])
        //mediumblob
        let stream3 = ByteBuffer()
        stream3.write(
            [145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56, 67, 145, 67, 34, 12, 45, 32, 76, 90, 62,
                145, 24, 56, 234, 34, 235, 56, 67, 145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56,
                67, 145, 67, 34, 12, 45, 32, 76, 90, 62, 145, 24, 56, 234, 34, 235, 56, 67])
        let p27 = SqlNullableBlob(stream3)
        //longblob
        let stream4 = ByteBuffer(Array<Byte>(1048576, repeat: 0))
        let p28 = SqlNullableBlob(stream4)
        //json
        let json = JsonObject.fromStr('{"name":"yesokim", "age": 22, "sex": 1}')
        let p29 = SqlNullableJson(json)
        //set
        let p30 = SqlNullableChar("value1,value2")
        //enum
        let p31 = SqlNullableChar("value1")
        let result = prepare.update(
            [p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23,
                p24, p25, p26, p27, p28, p29, p30, p31])
        println("effect rows: ${result.rowCount}")
        println("last insert id: ${result.lastInsertId}")
        prepare.close()
    }

    /*
     * NULL值插入测试
     */
    @TestCase
    public func insertNullTest() {
        let prepare = connection.prepareStatement(INSERT_SQL)
        let null = Array<SqlDbType>(32, repeat: SqlNullableBlob(None))
        let result = prepare.update(null)
        println("effect rows: ${result.rowCount}")
        println("last insert id: ${result.lastInsertId}")
    }

    /*
     * 查询数据测试
     */
    @TestCase
    public func queryTest() {
        let prepare = connection.prepareStatement("select * from full_test")
        //prepare.setOption("fetchSize", "10")
        let id = SqlInteger(-1)
        let col0 = SqlNullableBool(None)
        //tinyint
        let col1 = SqlNullableByte(None)
        //utinyint
        let col2 = SqlNullableSmallInt(None)
        //smallint
        let col3 = SqlNullableSmallInt(None)
        //usmallint
        let col4 = SqlNullableInteger(None)
        //mediumint
        let col5 = SqlNullableInteger(None)
        //umediumint
        let col6 = SqlNullableByte(None)
        //int
        let col7 = SqlNullableInteger(None)
        //uint
        let col8 = SqlNullableBigInt(None)
        //bigint
        let col9 = SqlNullableBigInt(None)
        //ubigint ?
        let col10 = SqlNullableBigInt(None)
        //float
        let col11 = SqlNullableReal(None)
        //double
        let col12 = SqlNullableDouble(None)
        //decimal
        let col13 = SqlNullableDecimal(None)
        //date
        let col14 = SqlNullableDate(None)
        //time
        let col15 = SqlNullableTime(None)
        //datetime
        let col16 = SqlNullableTimestamp(None)
        //timestamp
        let col17 = SqlNullableTimestamp(None)
        //year
        let col18 = SqlNullableSmallInt(None)
        //char
        let col19 = SqlNullableChar(None)
        //varchar
        let col20 = SqlNullableVarchar(None)
        //tinytext
        let col21 = SqlNullableVarchar(None)
        //text
        let col22 = SqlNullableVarchar(None)
        //mediumtext
        let col23 = SqlNullableVarchar(None)
        //longtext
        let col24 = SqlNullableVarchar(None)
        //tinyblob
        let col25 = SqlNullableBinary(None)
        //blob 
        let col26 = SqlNullableBlob(None)
        //meidum blob
        let col27 = SqlNullableBlob(None)
        //long blob
        let col28 = SqlNullableBlob(None)
        //json
        let col29 = SqlNullableJson(None)
        //set
        let col30 = SqlNullableVarchar(None)
        //enum
        let col31 = SqlNullableVarchar(None)
        let result = prepare.query()

        let row: Array<SqlDbType> = [id, col0, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12,
            col13, col14, col15, col16, col17, col18, col19, col20, col21, col22, col23, col24, col25, col26, col27,
            col28, col29, col30, col31]

        while (result.next(row)) {
            println(id.value)
            println(col0.value)
            println(col1.value)
            println(col2.value)
            println(col3.value)
            println(col4.value)
            println(col5.value)
            println(col6.value)
            println(col7.value)
            println(col8.value)
            println(col9.value)
            println(col10.value)
            println(col11.value)
            println(col12.value)
            println(col13.value)
            println(col14.value)
            println(col15.value)
            println(col16.value)
            println(col17.value)
            println(col18.value)
            println(col19.value)
            println(col20.value)
            println(col21.value)
            println(col22.value)
            println(col23.value)
            println(col24.value)
            println(col25.value)
            println(toArray(col26.value.getOrDefault({=> ByteBuffer()})).size)
            println(toArray(col27.value.getOrDefault({=> ByteBuffer()})).size)
            println(toArray(col28.value.getOrDefault({=> ByteBuffer()})).size)
            println(col29.value)
            println(col30.value)
            println(col31.value)
        }
    }

    /*
     * 事务测试
     */
    @TestCase
    public func transactionTest() {
        let transaction = connection.createTransaction()
        transaction.isoLevel = Serializable
        transaction.accessMode = ReadOnly
        transaction.begin()
        transaction.rollback()
        transaction.begin()
        transaction.commit()
        transaction.begin()
        transaction.save("yesokim")
        transaction.rollback("yesokim")
        transaction.release("yesokim")
        transaction.commit()
        transaction.accessMode = ReadWrite
    }

    /*
     * 单连接并发测试
     */
    @TestCase
    public func concurrentTest() {
        let counter = SyncCounter(3)
        spawn {
            insertTest()
            counter.dec()
        }
        spawn {
            insertTest()
            counter.dec()
        }
        spawn {
            queryTest()
            counter.dec()
        }
        counter.waitUntilZero()
    }

    /**
    * 防止SQL注入测试
    */
    @TestCase
    public func sqlInjectionTest() {
        let prepare = connection.prepareStatement("insert into full_test (char_col) values (?)")
        let id = SqlInteger(1)
        let sqlInjection = SqlNullableVarchar("'y'esoi'm'")
        let result = prepare.update([sqlInjection])
    }

}
