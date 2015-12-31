#MySQL开发技巧（一） 
Create Database If Not Exists test DEFAULT Character Set UTF8;
use test;

SET names utf8;
DROP TABLE IF EXISTS user1;
DROP TABLE IF EXISTS user2;
DROP TABLE IF EXISTS user_kills;
DROP TABLE IF EXISTS tb_sequence;
DROP TABLE IF EXISTS user1_equipment;

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
SELECT user_name,'arms' as equipment,arms AS 'equip_name' FROM user1 a JOIN user1_equipment b ON a.id=b.user_id
UNION ALL
SELECT user_name,'clothing' as equipment,clothing AS 'equip_name' FROM user1 a JOIN user1_equipment b ON a.id=b.user_id
UNION ALL
SELECT user_name,'shoe' as equipment,shoe AS 'equip_name' FROM user1 a JOIN user1_equipment b ON a.id=b.user_id;