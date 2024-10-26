protected package mysqlclient4cj.test.jdbc.impl

import std.unittest.*
import std.unittest.testmacro.*
import mysqlclient4cj.jdbc.impl.*
import mysqlclient4cj.jdbc.*
import std.time.*
import std.sync.*
import std.fs.*
import std.io.*
import std.math.numeric.*
import encoding.json.*

import mysqlclient4cj.jdbc.*
import mysqlclient4cj.jdbc.impl.*
import mysqlclient4cj.protocol.inputStreamToArray

@Test
public class TidbTest {


    private static var connection: Connection


    static init() {
        var driver = MySqlDriver.instance
        var property1 = ("username","3VaBbhPVncyrhn6.root")
        var property2= ("password","vLCfT9KIHkTonNft")
        var property3 = ("database","driver_test")
        var dataSource = driver.open("mysql://gateway01.ap-northeast-1.prod.aws.tidbcloud.com:4000", [property1,property2,property3])
        connection =  dataSource.connect()
    }

    /*
    * 插入数据测试
    */
    @TestCase
    public func insertTest(){
        var sql = ###"insert into full_test (
                                tinyint_col,
                                utinyint_col,
                                smallint_col,
                                usmallint_col,
                                mediumint_col,
                                umediumint_col,
                                int_col,
                                uint_col,
                                bigint_col,
                                ubigint_col,
                                float_col,
                                double_col,
                                decimal_col,
                                date_col, 
                                time_col, 
                                datetime_col,
                                timestamp_col, 
                                year_col,
                                char_col,
                                varchar_col,
                                tinytext_col,
                                text_col,
                                mediumtext_col,
                                longtext_col,
                                tinyblob_col,
                                blob_col,
                                mediumblob_col,
                                longblob_col,
                                json_col,
                                set_col,
                                enum_col) 
                                values
                                (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"###
        var prepare = connection.prepareStatement(sql)
        //tinyint
        prepare.setInt8(1, -128)
        //utinyint
        prepare.setUInt8(2, 0)
        //smallint
        prepare.setInt16(3, -32768)
        //usmallint
        prepare.setUInt16(4, 0)
        //mediumint
        prepare.setInt32(5, -8388608)
        //umediumint
        prepare.setUInt32(6, 0)
        //int
        prepare.setInt32(7, -2147483648)
        //uint
        prepare.setUInt32(8, 0)
        //bigint
        prepare.setInt64(9, -9223372036854775808)
        //ubigint
        prepare.setUInt64(10, 0)
        //float
        prepare.setFloat32(11, -1230.456)
        //double
        prepare.setFloat64(12, -234.568978)
        //decimal
        prepare.setDecimal(13, Decimal("1234.56789"))
        //date
        prepare.setDate(14, Date.now())
        //time
        prepare.setTime(15, Time.now())
        //datetime
        prepare.setDateTime(16, DateTime.now()) 
        //timestamp
        prepare.setDateTime(17, DateTime.now()) 
        //year
        prepare.setInt16(18, 2077)
        //char
        prepare.setString(19, "我冒了严寒，回到相隔二千余里，别了二十余年的故乡去。")
        //varchar
        prepare.setString(20, "时候既然是深冬；渐近故乡时，天气又阴晦了，冷风吹进船舱中")
        //tiny_text
        prepare.setString(21, "于是我自己解释说：故乡本也如此，——虽然没有进步，也未必有如我所感的悲凉")
        //text
        prepare.setString(22, "我所记得的故乡全不如此。我的故乡好得多了。但要我记起他的美丽，说出他的佳处来，却又没有影像，没有言辞了。仿佛也就如此。")
        //mediutext
        prepare.setString(23, "但我们终于谈到搬家的事。我说外间的寓所已经租定了，又买了几件家具，此外须将家里所有的木器卖去，再去增添。母亲也说好，而且行李也略已齐集，木器不便搬运的，也小半卖去了，只是收不起钱来。\r\n\r\n“你休息一两天，去拜望亲戚本家一回，我们便可以走了。”母亲说。\r\n\r\n“是的。”\r\n\r\n“还有闰土，他每到我家来时，总问起你，很想见你一回面。我已经将你到家的大约日期通知他，他也许就要来了。”\r\n\r\n这时候，我的脑里忽然闪出一幅神异的图画来：深蓝的天空中挂着一轮金黄的圆月，下面是海边的沙地，都种着一望无际的碧绿的西瓜，其间有一个十一二岁的少年，项带银圈，手捏一柄钢叉，向一匹猹⑵尽力的刺去，那猹却将身一扭，反从他的胯下逃走了。")
        //longtext
        prepare.setString(24, "这少年便是闰土。我认识他时，也不过十多岁，离现在将有三十年了；那时我的父亲还在世，家景也好，我正是一个少爷。那一年，我家是一件大祭祀的值年⑶。这祭祀，说是三十多年才能轮到一回，所以很郑重；正月里供祖像，供品很多，祭器很讲究，拜的人也很多，祭器也很要防偷去。我家只有一个忙月（我们这里给人做工的分三种：整年给一定人家做工的叫长工；按日给人做工的叫短工；自己也种地，只在过年过节以及收租时候来给一定人家做工的称忙月），忙不过来，他便对父亲说，可以叫他的儿子闰土来管祭器的。\r\n\r\n我的父亲允许了；我也很高兴，因为我早听到闰土这名字，而且知道他和我仿佛年纪，闰月生的，五行缺土⑷，所以他的父亲叫他闰土。他是能装〔弓京〕捉小鸟雀的。\r\n\r\n我于是日日盼望新年，新年到，闰土也就到了。好容易")
        //tinyblob
        var stream = ByteBuffer()
        stream.write([])
        prepare.setInputStream(25, stream)
        //blob
        var bytes: Array<Byte> = [145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67]
        prepare.setArray(26, bytes)
        //mediumblob
        stream = ByteBuffer()
        stream.write([145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67])
        prepare.setInputStream(27, stream)
        //longblob
        var file = File("C:\\Users\\30247\\Desktop\\mysqlclient4cj\\doc\\1.jpg",  OpenOption.Open(true, true))
        var array = readToEnd(file)
        var image = ByteBuffer()
        image.write(array)
        prepare.setInputStream(28, image)
        //json
        var json = JsonObject.fromStr('{"name":"yesokim", "age": 22, "sex": 1}')
        prepare.setJson(29, json)
        //set
        prepare.setString(30, "value1,value2")
        //enum
        prepare.setString(31, "value1")
        var result = prepare.update()
        println("effect rows: ${result.effectRow}")
        println("last insert id: ${result.lastInsertId}")
        prepare.close()
    }

    /*
    * 查询数据
    */
    @TestCase
    public func queryTest(){
        var prepare = connection.prepareStatement("select * from full_test where id = ?")
        var result = prepare.query([270001])
        while (result.next()) {
            println(result.getInt64(1))
            println(result.getInt8(2))
            println(result.getUInt8(3))
            println(result.getInt16(4))
            println(result.getUInt16(5))
            println(result.getInt32(6))
            println(result.getUInt32(7))
            println(result.getInt32(8))
            println(result.getUInt32(9))
            println(result.getInt64(10))
            println(result.getUInt64(11))
            println(result.getFloat32(12))
            println(result.getFloat64(13))
            println(result.getDecimal(14))
            println(result.getDate(15))
            println(result.getTime(16))
            println(result.getDateTime(17))
            println(result.getDateTime(18))
            println(result.getInt16(19))

            println(result.getString(20))
            println(result.getString(21))
            println(result.getString(22))
            println(result.getString(23))
            println(result.getString(24))
            println(result.getString(25))
            println(result.getArray(26))
            println(result.getArray(27))
            println(result.getArray(28))
            println(inputStreamToArray(result.getInputStream(29).getOrThrow()).size)
            println(result.getJsonValue(30))
            println(result.getString(31))
            println(result.getString(32))
        }
    }

    /*
    * 查询数据
    */
    @TestCase
    public func queryByNameTest(){
        var prepare = connection.prepareStatement("select * from full_test where id = ?")
        var result = prepare.query([270001])
        while (result.next()) {
            println(result.getInt64("id"))
            println(result.getInt8("tinyint_col"))
            println(result.getUInt8("utinyint_col"))
            println(result.getInt16("smallint_col"))
            println(result.getUInt16("usmallint_col"))
            println(result.getInt32("mediumint_col"))
            println(result.getUInt32("umediumint_col"))
            println(result.getInt32("int_col"))
            println(result.getUInt32("uint_col"))
            println(result.getInt64("bigint_col"))
            println(result.getUInt64("ubigint_col"))
            println(result.getFloat32("float_col"))
            println(result.getFloat64("double_col"))
            println(result.getDecimal("decimal_col"))
            println(result.getDate("date_col"))
            println(result.getTime("time_col"))
            println(result.getDateTime("datetime_col"))
            println(result.getDateTime("timestamp_col"))
            println(result.getInt16("year_col"))

            println(result.getString("char_col"))
            println(result.getString("varchar_col"))
            println(result.getString("tinytext_col"))
            println(result.getString("text_col"))
            println(result.getString("mediumtext_col"))
            println(result.getString("longtext_col"))
            println(result.getArray("tinyblob_col"))
            println(result.getArray("blob_col"))
            println(result.getArray("mediumblob_col"))
            println(inputStreamToArray(result.getInputStream("longblob_col").getOrThrow()).size)
            println(result.getJsonValue("json_col"))
            println(result.getString("set_col"))
            println(result.getString("enum_col"))
        }
    }


}