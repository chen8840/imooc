#MySQL开发技巧（一） 
Create Database If Not Exists test DEFAULT Character Set UTF8;
use test;

SET names utf8;
DROP TABLE IF EXISTS user1;
DROP TABLE IF EXISTS user2;
DROP TABLE IF EXISTS user_kills;

CREATE  TABLE IF NOT EXISTS user1 (
  id INT NOT NULL AUTO_INCREMENT,
  user_name VARCHAR(45) NOT NULL ,
  over VARCHAR(45) NOT NULL ,
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
  user_name VARCHAR(45) NOT NULL ,
  timestr DATETIME NOT NULL,
  kills INT NOT NULL ,
  PRIMARY KEY(id))
DEFAULT CHARACTER SET = utf8;

INSERT INTO user1(user_name, over) VALUES (
	'唐僧', '旃檀功德佛'
),(
	'猪八戒', '净坛使者'
),(
	'孙悟空', '斗战神佛'
),(
	'沙僧', '金身罗汉'
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

INSERT INTO user_kills(user_name, timestr, kills, user_id) VALUES (
	'孙悟空', '2013-01-11 00:00:00', 20, 3
),(
	'沙僧', '2013-01-10 00:00:00', 3, 4
),(
	'猪八戒', '2013-01-10 00:00:00', 10, 2
),(
	'猪八戒', '2013-02-01 00:00:00', 2, 2
),(
	'猪八戒', '2013-02-05 00:00:00', 12, 2
),(
	'猪八戒', '2013-02-06 00:00:00', 1, 2
),(
	'猪八戒', '2013-02-07 00:00:00', 17, 2
),(
	'猪八戒', '2013-02-11 00:00:00', 5, 2
),(
	'猪八戒', '2013-02-12 00:00:00', 10, 2
);

SET names gbk;
#2-1 join从句—内连接
SELECT a.user_name,a.over,b.over FROM user1 a INNER JOIN user2 b ON a.user_name=b.user_name;

#2-2 join从句—左外连接
SELECT a.user_name,a.over,b.over FROM user1 a LEFT JOIN user2 b ON a.user_name=b.user_name;                                       

#2-3 join从句—右外连接
SELECT b.user_name,b.over,a.over FROM user1 a RIGHT JOIN user2 b ON a.user_name=b.user_name WHERE a.user_name IS NULL; 

#2-4 join从句—全连接
SELECT a.user_name,a.over,b.over FROM user1 a LEFT JOIN user2 b ON a.user_name=b.user_name UNION SELECT b.user_name,a.over,b.over FROM user1 a RIGHT JOIN user2 b ON a.user_name=b.user_name;

#2-5 join从句—交叉连接
SELECT * FROM user1 a CROSS JOIN user2 b;

SET names utf8;
#2-6 使用join更新表
UPDATE user1 a JOIN(SELECT b.user_name FROM user1 a INNER JOIN user2 b ON a.user_name=b.user_name) b ON a.user_name=b.user_name SET a.over='齐天大圣';

SET names gbk;
#2-7 使用join优化子查询
SELECT a.user_name,a.over,(SELECT over FROM user2 b WHERE a.user_name=b.user_name) AS over2 FROM user1 a;
SELECT a.user_name,a.over,b.over AS over2 FROM user1 a LEFT JOIN user2 b ON a.user_name = b.user_name;

#2-8 使用join优化聚合子查询
SELECT a.user_name,b.timestr,b.kills FROM user1 a JOIN user_kills b ON a.id=b.user_id WHERE b.kills=(SELECT MAX(c.kills) FROM user_kills c WHERE c.user_id=b.user_id);
SELECT a.user_name,b.timestr,b.kills 
	FROM user1 a 
	JOIN user_kills b ON a.id=b.user_id 
	JOIN user_kills c ON c.user_id=b.user_id
	GROUP BY a.user_name,b.timestr,b.kills
	HAVING b.kills=MAX(c.kills);

#3-1 如何实现分组选择数据
SELECT d.user_name,c.timestr,kills 
	FROM(
		SELECT user_id,timestr,kills,
			(SELECT COUNT(*) FROM user_kills b WHERE b.user_id=a.user_id AND a.kills<=b.kills) AS cnt
			FROM user_kills a
			GROUP BY user_id,timestr,kills 
		) c
	JOIN user1 d ON c.user_id=d.id
	WHERE cnt<=2;