/*
 * Copyright (c) Yesokim. 2024-2024. All rights reserved.
 */
protected package cjmd.test.cdbc


import std.unittest.*
import std.unittest.testmacro.*
import std.database.sql.*
import cjmd.cdbc.*
import std.time.*
import std.sync.*
import std.fs.*
import std.io.*
import std.math.numeric.*
import cjmd.protocol.*
import encoding.json.*
@Test
public class MySqlTest{


    private var connection: Connection


    init() {
        var driver = MySqlDriver.instance
        var property1 = ("username","root")
        var property2= ("password","MySql123!")
        var property3 = ("database","driver_test")
        var property4 = ("ssl.mode","disabled")
        //passed
        var property5 = ("prepare.mode","server")
        //passed
        //var property5 = ("prepare.mode","client")
        var dataSource = driver.open("mysql://localhost", [property1,property2,property3,property4,property5])
        connection =  dataSource.connect()
        println("MySqlTest init")
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
        var p1 = SqlByte(-128)
        //utinyint
        var p2 = SqlSmallInt(0)
        //smallint
        var p3 = SqlSmallInt(-32768)
        //usmallint
        var p4 = SqlInteger(0)
        //mediumint
        var p5 = SqlInteger(-8388608)
        //umediumint
        var p6 = SqlBigInt(0)
        //int
        var p7 = SqlBigInt(-2147483648)
        //uint
        var p8 = SqlInteger(0)
        //bigint
        var p9 = SqlBigInt(-9223372036854775808)
        //ubigint
        var p10 = SqlBigInt(0)
        //float
        var p11 = SqlReal(2355.785436875)
        //double
        var p12 = SqlDouble(2465.089728343)
        //decimal
        var p13 = SqlDecimal(Decimal("1234.56789"))
        //date
        var p14 = SqlDate(DateTime.now())
        //time
        var p15= SqlTime(DateTime.now())
        //datetime
        var p16 = SqlTimestamp(DateTime.now())
        //timestamp
        var p17 = SqlTimestamp(DateTime.now())
        //year
        var p18 = SqlSmallInt(2077)
        //char
        var p19 = SqlChar("我冒了严寒，回到相隔二千余里，别了二十余年的故乡去。")
        //varchar
        var p20 = SqlVarchar("时候既然是深冬；渐近故乡时，天气又阴晦了，冷风吹进船舱中")
        //tiny_text
        var p21 = SqlVarchar("于是我自己解释说：故乡本也如此，——虽然没有进步，也未必有如我所感的悲凉")
        //text
        var p22 = SqlVarchar("我所记得的故乡全不如此。我的故乡好得多了。但要我记起他的美丽，说出他的佳处来，却又没有影像，没有言辞了。仿佛也就如此。")
        //mediutext
        var p23 = SqlVarchar("但我们终于谈到搬家的事。我说外间的寓所已经租定了，又买了几件家具，此外须将家里所有的木器卖去，再去增添。母亲也说好，而且行李也略已齐集，木器不便搬运的，也小半卖去了，只是收不起钱来。\r\n\r\n“你休息一两天，去拜望亲戚本家一回，我们便可以走了。”母亲说。\r\n\r\n“是的。”\r\n\r\n“还有闰土，他每到我家来时，总问起你，很想见你一回面。我已经将你到家的大约日期通知他，他也许就要来了。”\r\n\r\n这时候，我的脑里忽然闪出一幅神异的图画来：深蓝的天空中挂着一轮金黄的圆月，下面是海边的沙地，都种着一望无际的碧绿的西瓜，其间有一个十一二岁的少年，项带银圈，手捏一柄钢叉，向一匹猹⑵尽力的刺去，那猹却将身一扭，反从他的胯下逃走了。")
        //longtext
        var p24 = SqlVarchar("这少年便是闰土。我认识他时，也不过十多岁，离现在将有三十年了；那时我的父亲还在世，家景也好，我正是一个少爷。那一年，我家是一件大祭祀的值年⑶。这祭祀，说是三十多年才能轮到一回，所以很郑重；正月里供祖像，供品很多，祭器很讲究，拜的人也很多，祭器也很要防偷去。我家只有一个忙月（我们这里给人做工的分三种：整年给一定人家做工的叫长工；按日给人做工的叫短工；自己也种地，只在过年过节以及收租时候来给一定人家做工的称忙月），忙不过来，他便对父亲说，可以叫他的儿子闰土来管祭器的。\r\n\r\n我的父亲允许了；我也很高兴，因为我早听到闰土这名字，而且知道他和我仿佛年纪，闰月生的，五行缺土⑷，所以他的父亲叫他闰土。他是能装〔弓京〕捉小鸟雀的。\r\n\r\n我于是日日盼望新年，新年到，闰土也就到了。好容易")
        //tinyblob
        var stream1 = ByteArrayStream()
        stream1.write([])
        var p25 = SqlBlob(stream1)
        //blob
        var p26 = SqlBinary([145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67])
        //mediumblob
        var stream3 = ByteArrayStream()
        stream3.write([145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67,145,67,34,12,45,32,76,90,62,145,24,56,234,34,235,56,67])
        var p27 = SqlBlob(stream3)
        //longblob
        var file = File("C:\\Users\\30247\\Desktop\\cjmd\\doc\\1.jpg",  OpenOption.Open(true, true))
        var array = file.readToEnd()
        var stream4 = ByteArrayStream()
        stream4.write(array)
        var p28 = SqlBlob(stream4)
        //json
        var json = JsonObject.fromStr('{"name":"yesokim", "age": 22, "sex": 1}')
        var p29 = SqlJson(json)
        //set
        var p30 = SqlNullableChar("value1,value2")
        //enum
        var p31 = SqlNullableChar("value1")
        var result = prepare.update([p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31])
        println("effect rows: ${result.rowCount}")
        println("last insert id: ${result.lastInsertId}")
        prepare.close()
    }


    /*
    * 查询数据测试
    */
    @TestCase
    public func queryTest(){

        var prepare = connection.prepareStatement("select * from full_test")
        var id = SqlInteger(-1)
        //tinyint
        var col1 = SqlNullableByte(None)
        //utinyint
        var col2 = SqlNullableSmallInt(None)
        //smallint
        var col3 = SqlNullableSmallInt(None)
        //usmallint
        var col4 = SqlNullableInteger(None)
        //mediumint
        var col5 = SqlNullableInteger(None)
        //umediumint
        var col6 = SqlNullableByte(None)
        //int
        var col7 = SqlNullableInteger(None)
        //uint
        var col8 = SqlNullableBigInt(None)
        //bigint
        var col9 = SqlNullableBigInt(None)
        //ubigint ?
        var col10 = SqlNullableBigInt(None)
        //float
        var col11 = SqlNullableReal(None)
        //double
        var col12 = SqlNullableDouble(None)
        //decimal
        var col13 = SqlNullableDecimal(None)
        //date
        var col14 = SqlNullableDate(None)
        //time
        var col15 = SqlNullableTime(None)
        //datetime
        var col16 = SqlNullableTimestamp(None)
        //timestamp
        var col17 = SqlNullableTimestamp(None)
        //year
        var col18 = SqlNullableSmallInt(None)
        //char
        var col19 = SqlNullableChar(None)
        //varchar
        var col20 = SqlNullableVarchar(None)
        //tinytext
        var col21 = SqlNullableVarchar(None)
        //text
        var col22 = SqlNullableVarchar(None)
        //mediumtext
        var col23 = SqlNullableVarchar(None)
        //longtext
        var col24 = SqlNullableVarchar(None)
        //tinyblob
        var col25 = SqlNullableBinary(None)
        //blob 
        var col26 = SqlNullableBlob(None)
        //meidum blob
        var col27 = SqlNullableBlob(None)
        //long blob
        var col28 = SqlNullableBlob(None)
        //json
        var col29 = SqlNullableJson(None)
        //set
        var col30 = SqlNullableVarchar(None)
        //enum
        var col31 = SqlNullableVarchar(None)
        var result = prepare.query()

        var row: Array<SqlDbType> = [id,col1,col2,col3,col4,col5,col6,col7,col8,col9,col10,col11,col12,col13,col14,col15,col16,col17,col18,col19,col20,col21,col22,col23,col24,col25,col26,col27,col28,col29,col30,col31]
        
        while (result.next(row)) {
           print(id.value)
           print(" ")
           print(col1.value)
           print(" ")
           print(col2.value)
           print(" ")
           print(col3.value)
           print(" ")
           print(col4.value)
           print(" ")
           print(col5.value)
           print(" ")
           print(col6.value)
           print(" ")
           print(col7.value)
           print(" ")
           print(col8.value)
           print(" ")
           print(col9.value)
           print(" ")
           print(col10.value)
           print(" ")
           print(col11.value)
           print(" ")
           print(col12.value)
           print(" ")
           print(col13.value)
           print(" ")
           print(col14.value)
           print(" ")
           print(col15.value)
           print(" ")
           print(col16.value)
           print(" ")
           print(col17.value)
           print(" ")
           print(col18.value)
           print(" ")
           print(col19.value)
           print(" ")
           print(col20.value)
           print(" ")
           print(col21.value)
           print(" ")
           print(col22.value)
           print(" ")
           print(col23.value)
           print(" ")
           print(col24.value)
           print(" ")
           print(col25.value)
           print(" ")
           print(inputStreamToArray(col26.value.getOrDefault({=>ByteArrayStream()})).size)
           print(" ")
           print(inputStreamToArray(col27.value.getOrDefault({=>ByteArrayStream()})).size)
           print(" ")
           print(inputStreamToArray(col28.value.getOrDefault({=>ByteArrayStream()})).size)
           print(" ")
           print(col29.value)
           print(" ")
           print(col30.value)
           print(" ")
           print(col31.value)
           println()
        }

    }

    /*
    * 事务测试
    */
    @TestCase
    public func transactionTest(){
        var transaction = connection.createTransaction()
        transaction.isoLevel = RepeatableRead
        transaction.begin()
        insertTest()
        //transaction.rollback()
        transaction.commit()
    }

    /*
    * 多线程并发测试
    */
    @TestCase
    public func concurrentTest(){
        var counter = SyncCounter(7)
        spawn { =>
            insertTest()
        }
        spawn {
            insertTest()
        }
        spawn{
            insertTest()
        }
        spawn {
            insertTest()
        }
        spawn{
            queryTest()
        }
        sleep(Duration.second * 5)
    }

    /*
    * NULL值插入测试
    */
    @TestCase
    public func insertNullTest() {
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
                                longblob_col) 
                                values
                                (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"###
        var prepare = connection.prepareStatement(sql)
        var result = prepare.update([
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None),
            SqlNullableChar(None)])
        println("effect rows: ${result.rowCount}")
        println("last insert id: ${result.lastInsertId}")
    }

}

   