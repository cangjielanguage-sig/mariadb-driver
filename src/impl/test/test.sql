/*
 Navicat Premium Data Transfer

 Source Server         : SuperLinux-Root
 Source Server Type    : MySQL
 Source Server Version : 80034
 Source Host           : 192.168.68.128:3306
 Source Schema         : test

 Target Server Type    : MySQL
 Target Server Version : 80034
 File Encoding         : 65001

 Date: 22/08/2024 21:10:21
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for test
-- ----------------------------
DROP TABLE IF EXISTS `test`;
CREATE TABLE `test`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `varchar_col` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `char_col` char(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `tinyint_col` tinyint NULL DEFAULT NULL,
  `smallint_col` smallint NULL DEFAULT NULL,
  `mediumint_col` mediumint NULL DEFAULT NULL,
  `int_col` int NULL DEFAULT NULL,
  `bigint_col` bigint NULL DEFAULT NULL,
  `float_col` float(8, 2) NULL DEFAULT NULL,
  `double_col` double(10, 4) NULL DEFAULT NULL,
  `decimal_col` decimal(10, 5) NULL DEFAULT NULL,
  `date_col` date NULL DEFAULT NULL,
  `datetime_col` datetime NULL DEFAULT NULL,
  `timestamp_col` timestamp NULL DEFAULT NULL,
  `time_col` time NULL DEFAULT NULL,
  `year_col` year NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 179 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
