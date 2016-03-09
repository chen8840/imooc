#MySQL开发技巧（三） 
Create Database If Not Exists test DEFAULT Character Set UTF8;
use test;

DROP TABLE IF EXISTS user1;
DROP TABLE IF EXISTS user_kills;
DROP TABLE IF EXISTS user1_skills;
DROP TABLE IF EXISTS taxRate;

CREATE  TABLE IF NOT EXISTS user1 (
  id INT NOT NULL AUTO_INCREMENT,
  user_name VARCHAR(45) NOT NULL ,
  over VARCHAR(45) NOT NULL ,
  money float(10,2) NOT NULL,
  PRIMARY KEY(id))
DEFAULT CHARACTER SET = utf8;


CREATE  TABLE IF NOT EXISTS user_kills (
  id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  timestr DATETIME NOT NULL,
  kills INT NOT NULL ,
  PRIMARY KEY(id))
DEFAULT CHARACTER SET = utf8;

CREATE  TABLE IF NOT EXISTS user1_skills (
  id INT NOT NULL AUTO_INCREMENT,
  user_id INT NOT NULL,
  skill VARCHAR(45) NOT NULL,
  skill_level INT NOT NULL ,
  PRIMARY KEY(id))
DEFAULT CHARACTER SET = utf8;

CREATE  TABLE IF NOT EXISTS taxRate (
  low float(10,2) NOT NULL,
  high float(10,2) NOT NULL,
  rate float(10,2) NOT NULL)
DEFAULT CHARACTER SET = utf8;

INSERT INTO user1(user_name, over, money) VALUES (
	'唐僧', '旃檀功德佛', 35000.00
),(
	'猪八戒', '净坛使者', 15000.00
),(
	'孙悟空', '斗战神佛', 28000.00
),(
	'沙僧', '金身罗汉',   8000.00
);


INSERT INTO user_kills(timestr, kills, user_id) VALUES (
	'2013-01-10 00:00:00', 10, 2
),(
	'2013-02-01 00:00:00', 2, 2
),(
	'2013-02-05 00:00:00', 12, 2
),(
	'2013-01-10 00:00:00', 3, 4
),(
	'2013-02-11 00:00:00', 5, 4
),(
	'2013-02-06 00:00:00', 1, 4
),(
	'2013-01-11 00:00:00', 20, 3
),(
	'2013-02-12 00:00:00', 10, 3
),(
	'2013-02-07 00:00:00', 17, 3
);

INSERT INTO user1_skills(user_id, skill, skill_level) VALUES(
	1, '紧箍咒', 	5
),(
	1, '打坐', 		4
),(
	1, '念经', 		5
),(
	1, '变化', 		0
),(
	2, '变化', 		4
),(
	2, '腾云', 		3
),(
	2, '浮水', 		5
),(
	2, '念经', 		0
),(
	2, '紧箍咒', 	0
),(
	3, '变化', 		5
),(
	3, '腾云', 		5
),(
	3, '浮水', 		3
),(
	3, '念经', 		2
),(
	3, '请神', 		5
),(
	3, '紧箍咒', 	0
),(
	4, '变化', 		2
),(
	4, '腾云', 		2
),(
	4, '浮水', 		4
),(
	4, '念经', 		1
),(
	4, '紧箍咒', 		0
);

INSERT INTO taxRate(low,high,rate) VALUES(
	0.00,		1500.00,		0.03
),(
	1500.00,	4500.00,		0.10
),(
	4500.00,	9000.00,		0.20
),(
	9000.00,	35000.00,		0.25
),(
	35000.00,	55000.00,		0.30
),(
	55000.00,	80000.00,		0.35
),(
	80000.00,	99999999.00,	0.45
);


#2-1 子查询的使用场景及其好处
SELECT user_name FROM user1 WHERE id IN (SELECT user_id FROM user_kills);
SELECT DISTINCT a.user_name FROM user1 a JOIN user_kills b ON a.id = b.user_id;

#2-2 如何在子查询中实现多列过滤
SELECT a.user_name,b.timestr,kills 
	FROM user1 a 
	JOIN user_kills b ON a.id = b.user_id
	JOIN (SELECT user_id,max(kills) AS cnt FROM user_kills GROUP BY user_id) c 
	ON b.user_id = c.user_id AND b.kills = c.cnt;
SELECT a.user_name,b.timestr,kills 
	FROM user1 a
	JOIN user_kills b ON a.id = b.user_id
	WHERE (b.user_id,b.kills) IN (SELECT user_id,MAX(kills) FROM user_kills GROUP BY user_id);

#3-2 什么是同一属性的多值过滤
SELECT a.user_name,b.skill,c.skill
	FROM user1 a
	JOIN user1_skills b ON a.id = b.user_id
	JOIN user1_skills c ON c.user_id = b.user_id
	WHERE b.skill = '念经' AND c.skill = '变化' AND b.skill_level > 0 AND c.skill_level > 0;

#3-3 使用关联方式实现多属性查询（一） (05:38)
SELECT a.user_name,b.skill,c.skill,d.skill 
	FROM user1 a
	JOIN user1_skills b ON a.id = b.user_id
	JOIN user1_skills c ON c.user_id = b.user_id
	JOIN user1_skills d ON d.user_id = b.user_id
	WHERE b.skill='念经' AND c.skill='变化' AND d.skill='腾云' AND b.skill_level>0 AND c.skill_level>0 AND d.skill_level>0;

#3-4 使用关联方式实现多属性查询（二） (08:46)
SELECT a.user_name,b.skill,c.skill,d.skill,e.skill
	FROM user1 a
	LEFT JOIN user1_skills b ON a.id=b.user_id AND b.skill='念经' AND b.skill_level>0
	LEFT JOIN user1_skills c ON a.id=c.user_id AND c.skill='变化' AND c.skill_level>0
	LEFT JOIN user1_skills d ON a.id=d.user_id AND d.skill='腾云' AND d.skill_level>0
	LEFT JOIN user1_skills e ON a.id=e.user_id AND e.skill='浮水' AND e.skill_level>0
	WHERE (CASE WHEN b.skill IS NOT NULL THEN 1 ELSE 0 END)
		 +(CASE WHEN c.skill IS NOT NULL THEN 1 ELSE 0 END)
		 +(CASE WHEN d.skill IS NOT NULL THEN 1 ELSE 0 END)
		 +(CASE WHEN e.skill IS NOT NULL THEN 1 ELSE 0 END) >= 2;

#3-5 使用Group by 实现多属性查询 (03:59)
SELECT a.user_name
	FROM user1 a
	JOIN user1_skills b ON a.id = b.user_id
	WHERE b.skill IN ('念经','变化','腾云','浮水') AND b.skill_level>0
	GROUP BY a.user_name HAVING COUNT(*)>=2;

#4-2 如何计算累进税 (09:05)
SELECT user_name,sum(curmoney*rate)
	FROM(
		SELECT user_name,money,low,high,LEAST(money-low,high-low) AS curmoney,rate
			FROM user1 a
			JOIN taxRate b ON a.money>b.low
	) a
	Group by user_name;