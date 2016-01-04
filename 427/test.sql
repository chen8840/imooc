#MySQL开发技巧（一） 
Create Database If Not Exists test DEFAULT Character Set UTF8;
use test;

SET names utf8;
DROP TABLE IF EXISTS user1;
DROP TABLE IF EXISTS user2;
DROP TABLE IF EXISTS user_kills;
DROP TABLE IF EXISTS tb_sequence;
DROP TABLE IF EXISTS user1_equipment;
DROP TABLE IF EXISTS order_seq;
DROP PROCEDURE IF EXISTS seq_no;
DROP TABLE IF EXISTS user1_test;

CREATE  TABLE IF NOT EXISTS user1 (
  id INT NOT NULL AUTO_INCREMENT,
  user_name VARCHAR(45) NOT NULL ,
  over VARCHAR(45) NOT NULL ,
  mobile VARCHAR(100) NOT NULL,
  PRIMARY KEY(id))
DEFAULT CHARACTER SET = utf8;

CREATE  TABLE IF NOT EXISTS user2 (
  id INT NOT NULL AUTO_INCREMENT,
  user_name VARCHAR(45) NOT NULL ,
  over VARCHAR(45) NOT NULL ,
  PRIMARY KEY(id))
DEFAULT CHARACTER SET = utf8;

CREATE  TABLE IF NOT EXISTS user_kills (
  id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  timestr DATETIME NOT NULL,
  kills INT NOT NULL ,
  PRIMARY KEY(id))
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS tb_sequence(
	id INT AUTO_INCREMENT NOT NULL,
	PRIMARY KEY(id))
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS user1_equipment(
	id INT NOT NULL AUTO_INCREMENT,
	user_id INT NOT NULL,
	arms VARCHAR(11),
	clothing VARCHAR(11),
	shoe VARCHAR(11),
	PRIMARY KEY(id))
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS order_seq(
	timestr VARCHAR(30) NOT NULL,
	order_sn INT NOT NULL)
DEFAULT CHARACTER SET = utf8;

CREATE TABLE IF NOT EXISTS user1_test(
	id INT AUTO_INCREMENT NOT NULL,
	user_name VARCHAR(45) NOT NULL ,
	over VARCHAR(45) NOT NULL ,
	mobile VARCHAR(100) NOT NULL,
	PRIMARY KEY(id))
DEFAULT CHARACTER SET = utf8;

INSERT INTO user1(user_name, over, mobile) VALUES (
	'唐僧', '旃檀功德佛', '121123456,141123456,161123456'
),(
	'猪八戒', '净坛使者', '12144643321,14144643321'
),(
	'孙悟空', '斗战神佛', '12166666666,14166666666,1616666666,1816666666'
),(
	'沙僧', '金身罗汉', '12198765432,14198765432'
);

INSERT INTO user2(user_name, over) VALUES (
	'孙悟空', '成佛'
),(
	'牛魔王', '被降服'
),(
	'鹏魔王', '被降服'
),(
	'蛟魔王', '被降服'
),(
	'狮骆王', '被降服'
);

INSERT INTO user_kills(timestr, kills, user_id) VALUES (
	'2013-01-11 00:00:00', 20, 3
),(
	'2013-01-10 00:00:00', 3, 4
),(
	'2013-01-10 00:00:00', 10, 2
),(
	'2013-02-01 00:00:00', 2, 2
),(
	'2013-02-05 00:00:00', 12, 2
),(
	'2013-02-06 00:00:00', 1, 2
),(
	'2013-02-07 00:00:00', 17, 2
),(
	'2013-02-11 00:00:00', 5, 2
),(
	'2013-02-12 00:00:00', 10, 2
);

INSERT INTO tb_sequence values(),(),(),(),(),(),(),(),();

INSERT INTO user1_equipment(user_id, arms, clothing, shoe) VALUES(
	3, '金箍棒', '锁子黄金甲', '藕丝步云履'
),( 
	2, '九齿钉耙', '僧衣', '僧鞋' 
),( 
	4, '降妖宝杖', '僧衣', '僧鞋' 
),( 
	1, '九环锡杖', '锦斓袈裟', '僧鞋' 
);

INSERT INTO user1_test(user_name,over,mobile) SELECT user_name,over,mobile FROM user1;
INSERT INTO user1_test(user_name,over,mobile) SELECT user_name,over,mobile FROM user1 LIMIT 2;

#2-3 使用自连接的方法实现行转列
SELECT * 
FROM (
	SELECT SUM(kills) as '沙僧' FROM user1 a JOIN user_kills b ON a.id=b.user_id AND a.user_name='沙僧'
) a CROSS JOIN (
	SELECT SUM(kills) as '猪八戒' FROM user1 a JOIN user_kills b ON a.id=b.user_id AND a.user_name='猪八戒'
) b CROSS JOIN (
	SELECT SUM(kills) as '孙悟空' FROM user1 a JOIN user_kills b ON a.id=b.user_id AND a.user_name='孙悟空'
) c;

#2-4 使用CASE方法实现行转列
SELECT SUM(CASE user_name WHEN '孙悟空' THEN kills END) AS '孙悟空', 
	   SUM(CASE WHEN user_name='猪八戒' THEN kills END) AS '猪八戒', 
	   SUM(CASE WHEN user_name='沙僧' THEN kills END) AS '沙僧' 
	FROM user1 a JOIN user_kills b ON a.id = b.user_id;

#2-6 使用序列化表的方法实现列转行
SELECT user_name,
	REPLACE(
		SUBSTRING(
			SUBSTRING_INDEX(mobile,',',a.id),
			CHAR_LENGTH(SUBSTRING_INDEX(mobile,',',a.id-1))+1
			),
		',',
		''
		) AS mobile
	FROM tb_sequence a 
	CROSS JOIN(
		SELECT user_name,
			   CONCAT(mobile,',') AS mobile,
			   LENGTH(mobile)-LENGTH(REPLACE(mobile,',',''))+1 size
			FROM user1
	)b ON a.id<=b.size;

#2-7 使用UNION的方法实现列转行
SELECT user_name,'arms' AS equipment,arms AS 'equip_name' FROM user1 a JOIN user1_equipment b ON a.id=b.user_id
UNION ALL
SELECT user_name,'clothing' AS equipment,clothing AS 'equip_name' FROM user1 a JOIN user1_equipment b ON a.id=b.user_id
UNION ALL
SELECT user_name,'shoe' AS equipment,shoe AS 'equip_name' FROM user1 a JOIN user1_equipment b ON a.id=b.user_id;

#2-8 使用序列化表的方法实现列转行
SELECT user_name, 
	CASE WHEN c.id = 1 THEN 'arms'
		 WHEN c.id = 2 THEN 'clothing'
		 WHEN c.id = 3 THEN 'shoe'
	END AS equipment,
	COALESCE(CASE WHEN c.id = 1 THEN arms END,
			 CASE WHEN c.id = 2 THEN clothing END,
			 CASE WHEN c.id = 3 THEN shoe END) AS equip_name
	FROM user1 a 
	JOIN user1_equipment b on a.id = b.user_id
	CROSS JOIN tb_sequence c WHERE c.id <= 3 ORDER BY user_name;

/*SELECT user_name, 
	CASE WHEN c.id = 1 THEN 'arms'
		 WHEN c.id = 2 THEN 'clothing'
		 WHEN c.id = 3 THEN 'shoe'
	END AS equipment,
	CASE WHEN c.id = 1 THEN arms
		 WHEN c.id = 2 THEN clothing
		 WHEN c.id = 3 THEN shoe END AS equip_name
	FROM user1 a 
	JOIN user1_equipment b on a.id = b.user_id
	CROSS JOIN tb_sequence c WHERE c.id <= 3 ORDER BY user_name;*/

#3-2 如何使用SQL语句建立特殊需求的序列号
DELIMITER //
CREATE PROCEDURE seq_no()
BEGIN
DECLARE v_cnt INT;
DECLARE v_timestr INT;
DECLARE rowcount BIGINT;
SET v_timestr=DATE_FORMAT(NOW(),'%Y%m%d');
SELECT ROUND(RAND()*100,0)+1 INTO v_cnt;
START TRANSACTION;
	UPDATE order_seq SET order_sn=order_sn+v_cnt WHERE timestr=v_timestr;
	IF ROW_COUNT()=0 THEN
		INSERT INTO order_seq(timestr,order_sn) VALUES(v_timestr,v_cnt);
	END IF;
	SELECT CONCAT(v_timestr,LPAD(order_sn,7,0)) AS order_sn
		FROM order_seq WHERE timestr=v_timestr;
COMMIT;
END
//
DELIMITER ;

call seq_no();

#4-1 利用主键删除重复数据
DELETE a FROM user1_test a JOIN (
	SELECT user_name,MAX(id) AS max_id FROM user1_test GROUP BY user_name,over,mobile HAVING COUNT(*) > 1
	) b 
	ON a.user_name = b.user_name
	WHERE a.id < b.max_id;

#4-2 如何处理复杂的重复数据删除
DELETE FROM user1_test;
INSERT INTO user1_test(user_name,over,mobile) SELECT user_name,over,mobile FROM user1;
UPDATE user1_test SET mobile='12112345678,14112345678,12112345678' WHERE user_name='唐僧';
UPDATE user1_test SET mobile='12166666666,14166666666,18166666666,18166666666' WHERE user_name='孙悟空';

SELECT id,user_name,GROUP_CONCAT(mobile) FROM 
	(SELECT DISTINCT b.id AS id,user_name,
		REPLACE(
			SUBSTRING(
				SUBSTRING_INDEX(mobile,',',a.id),
				CHAR_LENGTH(SUBSTRING_INDEX(mobile,',',a.id-1))+1
				),
			',',
			''
			) AS mobile
		FROM tb_sequence a 
		CROSS JOIN(
			SELECT id,user_name,
				   CONCAT(mobile,',') AS mobile,
				   LENGTH(mobile)-LENGTH(REPLACE(mobile,',',''))+1 size
				FROM user1_test
		)b ON a.id<=b.size) a
	GROUP BY a.id;