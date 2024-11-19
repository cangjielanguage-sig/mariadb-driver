#创建测试数据库
CREATE DATABASE driver_test;
USE driver_test;

#创建测试用户
CREATE USER 'native_user'@'%' IDENTIFIED WITH mysql_native_password BY 'native_user';
CREATE USER 'sha256_user'@'%' IDENTIFIED WITH sha256_password BY 'sha256_user';
CREATE USER 'caching_user'@'%' IDENTIFIED WITH caching_sha2_password BY 'caching_user';
CREATE USER 'test_user'@'%' IDENTIFIED BY 'test_user';
GRANT ALL PRIVILEGES ON driver_test.* TO 'test_user'@'%';

#创建测试表
CREATE TABLE `full_test`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tinyint_col` tinyint ,
  `utinyint_col` tinyint UNSIGNED ,
  `smallint_col` smallint,
  `usmallint_col` smallint UNSIGNED ,
  `mediumint_col` mediumint ,
  `umediumint_col` mediumint UNSIGNED,
  `int_col` int ,
  `uint_col` int UNSIGNED ,
  `bigint_col` bigint ,
  `ubigint_col` bigint UNSIGNED,
  `float_col` float ,
  `double_col` double ,
  `decimal_col` decimal(65, 30),
  `date_col` date ,
  `time_col` time ,
  `datetime_col` datetime ,
  `timestamp_col` timestamp,
  `year_col` year ,
  `char_col` char(255) ,
  `varchar_col` varchar(255) ,
  `tinytext_col` tinytext ,
  `text_col` text,
  `mediumtext_col` mediumtext,
  `longtext_col` longtext,
  `tinyblob_col` tinyblob ,
  `blob_col` blob ,
  `mediumblob_col` mediumblob ,
  `longblob_col` longblob ,
  `json_col` json ,
  `set_col` set('value1','value2','value3','value4','value5'),
  `enum_col` enum('value1','value2','value3','value4','value5') ,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB;
