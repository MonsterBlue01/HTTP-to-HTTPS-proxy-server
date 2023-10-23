CREATE TABLE Movies ( 
    movieTitle CHAR(100) DEFAULT 'Unknown Title' PRIMARY KEY NOT NULL,  -- 第一种declare PRIMARY KEY的方法
    movieYear INT DEFAULT 2000 NOT NULL,
    length INT DEFAULT 120 NOT NULL, -- Assuming default length as 120 minutes
    genre BOOLEAN DEFAULT FALSE NOT NULL, 
    studioName CHAR(30) DEFAULT 'Unknown Studio' NOT NULL, 
    producerC# INT DEFAULT 0 NOT NULL
);

-- movieTitle是很明显的一个key（当然也有其他的candidate key)，{movieTitle, movieYear}可以作为Superkey

CREATE TABLE MovieStar (
    starName CHAR(30) NOT NULL,
    address VARCHAR(255) DEFAULT 'Hollywood' NOT NULL,
    gender CHAR(1) DEFAULT 'U' NOT NULL, -- U for Unknown
    birthdate DATE DEFAULT '1990-08-26' NOT NULL,
    PRIMARY KEY (starName), -- 第二种declare PRIMARY KEY的方法（也可以PRIMARY KEY(starName, birthdate)，这代表starName和birthdate的组合不可以重复
    UNIQUE (starName) -- 这是冗余的，但只是举一个例子。区别PRIMARY KEY: 可以为NULL, 可以多个
);

CREATE TABLE MovieStarAppearsIn (
    movieTitle CHAR(100),
    starName CHAR(30),
    FOREIGN KEY (movieTitle) REFERENCES Movies(movieTitle),
    FOREIGN KEY (starName) REFERENCES MovieStar(starName)
);

-- 更改表格
DROP TABLE Movies; -- 删除表
ALTER TABLE MovieStar ADD phone CHAR(16) DEFAULT 'Unknown' NOT NULL; -- 添加属性
ALTER TABLE MovieStar DROP COLUMN birthdate; -- 删除属性
-- 插入一些数据到修改后的MovieStar表中
INSERT INTO MovieStar (starName, address, gender, phone) VALUES ('Tom Cruise', 'Hollywood Blvd', 'M', '123-456-7890');
INSERT INTO MovieStar (starName, address, gender, phone) VALUES ('Angelina Jolie', 'Hollywood Blvd', 'F', '987-654-3210');

-- Set: {2,4,6,2,2}, Multiset (bag): {{2,4,6,2,2}} => {{2[3],4[1],6[1]}} [这两个顺序不重要]

SELECT DISTINCT M.movieTitle AS "Distinct Movie Title", S.starName AS "Star Name" --在SELECT的结果中去除掉相同的结果
FROM Movies M
JOIN MovieStarAppearsIn MAI ON M.movieTitle = MAI.movieTitle
JOIN MovieStar S ON MAI.starName = S.starName
WHERE M.studioName = 'Disney'
AND M.movieYear = 1990
AND (M.movieTitle LIKE 'Pr%' OR M.movieTitle IS NULL) 
ORDER BY M.movieTitle DESC; --(ASC: 增长, DESC: 降低)

-- CROSS JOIN 示例:
-- 这是一个CROSS JOIN查询，它将Movies表中的每一部电影与MovieStar表中的每一个明星组合。
-- 结果是一个笛卡尔积，即电影数量乘以明星数量的所有组合，即使明星并未出演那部电影。
SELECT M.movieTitle, S.starName
FROM Movies M
CROSS JOIN MovieStar S;

-- 消除名称歧义
CREATE TABLE Students (
    name VARCHAR(50),
    age INT
);

CREATE TABLE Teachers (
    name VARCHAR(50),
    subject VARCHAR(50)
);


-- 现在，如果我们想选择所有名为"John"的学生和老师，我们可能会写以下查询：
SELECT *
FROM Students, Teachers
WHERE name = 'John';

SELECT *
FROM Students, Teachers
WHERE Students.name = 'John' OR Teachers.name = 'John';

-- 但是，由于两个表都有一个name列，所以这会引起歧义。为了消除歧义，我们应该这样写：

SELECT *
FROM Students, Teachers
WHERE Students.name = 'John' OR Teachers.name = 'John';

-- SQL里LIKE的Pattern Matching:
SELECT name
FROM students
WHERE name LIKE 'Li%'; -- 上述查询会返回所有名字以 "Li" 开头的学生，如 "Li Ming", "Li Hua", "Lily" 等。

SELECT name
FROM students
WHERE name LIKE 'a_a'; -- 此查询可能会返回 "ana", "apa", "ala" 等名字。

-- IS的等于和不等于
SELECT * FROM table WHERE column = NULL;
SELECT * FROM table WHERE column IS NULL;

SELECT * FROM table WHERE column IS NOT NULL;
SELECT * FROM table WHERE column <> 'value';

-- Employees 表

+-----+----------+-----------+
| ID  |  Name   | Department|
+-----+----------+-----------+
| 1   | Alice   | HR        |
| 2   | Bob     | Finance   |
| 3   | Charlie | Marketing |
+-----+----------+-----------+

-- Departments 表:

+-----------+---------+
| Department| Manager |
+-----------+---------+
| HR        | Alice   |
| Finance   | David   |
| Sales     | Ellen   |
+-----------+---------+

-- JOIN...ON... (经常指 INNER JOIN)

SELECT Employees.Name, Departments.Manager 
FROM Employees 
JOIN Departments 
ON Employees.Department = Departments.Department;

-- 结果：

+----------+---------+
|  Name   | Manager |
+----------+---------+
| Alice   | Alice   |
| Bob     | David   |
+----------+---------+

-- CROSS JOIN

SELECT Employees.Name, Departments.Manager 
FROM Employees 
CROSS JOIN Departments;

-- 结果：得到两个表的笛卡尔积

-- NATURAL JOIN

SELECT * 
FROM Employees 
NATURAL JOIN Departments;

-- 结果：

+-----+----------+-----------+---------+
| ID  |  Name   | Department| Manager |
+-----+----------+-----------+---------+
| 1   | Alice   | HR        | Alice   |
| 2   | Bob     | Finance   | David   |
+-----+----------+-----------+---------+

-- FULL OUTER JOIN：

SELECT Employees.Name, Departments.Manager 
FROM Employees 
FULL OUTER JOIN Departments 
ON Employees.Department = Departments.Department;

-- 结果：

+----------+---------+
|  Name   | Manager |
+----------+---------+
| Alice   | Alice   |
| Bob     | David   |
| Charlie | NULL    |
| NULL    | Ellen   |
+----------+---------+

-- LEFT OUTER JOIN:

SELECT Employees.Name, Departments.Manager 
FROM Employees 
LEFT OUTER JOIN Departments 
ON Employees.Department = Departments.Department;

-- 结果：

+----------+---------+
|  Name   | Manager |
+----------+---------+
| Alice   | Alice   |
| Bob     | David   |
| Charlie | NULL    |
+----------+---------+

-- RIGHT OUTER JOIN:

SELECT Employees.Name, Departments.Manager 
FROM Employees 
RIGHT OUTER JOIN Departments 
ON Employees.Department = Departments.Department;

-- 结果：

+----------+---------+
|  Name   | Manager |
+----------+---------+
| Alice   | Alice   |
| Bob     | David   |
| NULL    | Ellen   |
+----------+---------+

-- Bag union和Set union

-- R(A, B, C)

+---+---+----+
| A | B | C  |
+---+---+----+
| 5 | 3 | 10 |
| 15| 4 | 20 |
| 20| 5 | 30 |
+---+---+----+

-- S(A, B, C)

+---+---+----+
| A | B | C  |
+---+---+----+
| 5 | 3 | 10 |
| 20| 5 | 30 |
| 25| 7 | 40 |
+---+---+----+

-- Set union

( SELECT * FROM R WHERE A > 10 )
UNION
( SELECT * FROM S WHERE B < 300 );

+---+---+----+
| A | B | C  |
+---+---+----+
| 15| 4 | 20 |
| 20| 5 | 30 |
| 25| 7 | 40 |
+---+---+----+

-- Bag Union

( SELECT * FROM R WHERE A > 10)
UNION ALL
( SELECT * FROM S WHERE B < 300 );

+---+---+----+
| A | B | C  |
+---+---+----+
| 15| 4 | 20 |
| 20| 5 | 30 |
| 5 | 3 | 10 |
| 20| 5 | 30 |
| 25| 7 | 40 |
+---+---+----+

--Set的示例 1
CREATE TABLE Students (
    studentID INT PRIMARY KEY,
    name VARCHAR(50),
    age INT
);

INSERT INTO Students VALUES (1, 'Alice', 20), (2, 'Bob', 21), (3, 'Charlie', 22);

CREATE TABLE EnrolledCourses (
    studentID INT,
    courseName VARCHAR(50),
    FOREIGN KEY (studentID) REFERENCES Students(studentID)
);

INSERT INTO EnrolledCourses VALUES (1, 'Math'), (2, 'History'), (3, 'Math'), (3, 'Biology');

--IN：找出所有学习了"Math"或"History"的学生名字
SELECT name 
FROM Students
WHERE studentID IN (SELECT studentID FROM EnrolledCourses WHERE courseName IN ('Math', 'History'));

--NOT IN：找出没有学习"Math"的学生名字。
SELECT name 
FROM Students
WHERE studentID NOT IN (SELECT studentID FROM EnrolledCourses WHERE courseName = 'Math');

--op ANY：找出年龄大于任何学习了"Biology"的学生年龄的学生名字。
SELECT name 
FROM Students
WHERE age > ANY (SELECT age FROM Students WHERE studentID IN (SELECT studentID FROM EnrolledCourses WHERE courseName = 'Biology'));

--op ALL：找出年龄小于所有学习了"Math"的学生年龄的学生名字。
SELECT name 
FROM Students
WHERE age < ALL (SELECT age FROM Students WHERE studentID IN (SELECT studentID FROM EnrolledCourses WHERE courseName = 'Math'));

--EXISTS: 找出至少选修了一门课程的学生名字。
SELECT name 
FROM Students S
WHERE EXISTS (SELECT 1 FROM EnrolledCourses EC WHERE EC.studentID = S.studentID);

--NOT EXISTS: 找出没有选修任何课程的学生名字。
SELECT name 
FROM Students S
WHERE NOT EXISTS (SELECT 1 FROM EnrolledCourses EC WHERE EC.studentID = S.studentID);

--Set的示例 2
CREATE TABLE TeacherA_Students (
    studentName VARCHAR(50)
);

INSERT INTO TeacherA_Students VALUES ('Alice'), ('Bob'), ('Charlie'), ('David');

CREATE TABLE TeacherB_Students (
    studentName VARCHAR(50)
);

INSERT INTO TeacherB_Students VALUES ('Charlie'), ('David'), ('Eve'), ('Frank');

-- UNION
-- 获取两位教师的所有学生名单，但不包括重复的学生
SELECT studentName FROM TeacherA_Students
UNION
SELECT studentName FROM TeacherB_Students;

-- UNION ALL
-- 获取两位教师的所有学生名单，包括重复的学生
SELECT studentName FROM TeacherA_Students
UNION ALL
SELECT studentName FROM TeacherB_Students;

-- INTERSECT
-- 获取同时在两位教师名单中的学生
SELECT studentName FROM TeacherA_Students
INTERSECT
SELECT studentName FROM TeacherB_Students;

-- EXCEPT
-- 获取只在教师A的名单中，但不在教师B的名单中的学生
SELECT studentName FROM TeacherA_Students
EXCEPT
SELECT studentName FROM TeacherB_Students;

-- 子查询
-- 返回标量值的子查询
-- 找到制作电影 "Star Wars" 的执行者名称：
SELECT e.execName
FROM MovieExec e
WHERE e.cert# = (SELECT m.producerC#
                 FROM Movies m
                 WHERE m.movieTitle = 'Star Wars');

--返回关系的子查询
-- 还是找到制作电影 "Star Wars" 的执行者名称：
SELECT e.execName 
FROM MovieExec e 
WHERE e.cert# IN (SELECT m.producerC# 
                  FROM Movies m 
                  WHERE m.movieTitle = 'Star Wars');

--嵌套子查询
--找到为“Harrison Ford”主演的所有电影的执行者名称:
SELECT e.execName 
FROM MovieExec e 
WHERE e.cert# IN (SELECT m.producerC# 
                  FROM Movies m 
                  WHERE (m.movieTitle, m.movieYear) IN (SELECT s.movieTitle, s.movieYear 
                                                        FROM StarsIn s 
                                                        WHERE s.starName = 'Harrison Ford'));

--相关子查询
--找出用于两部或更多电影的电影标题
SELECT DISTINCT m.movieTitle 
FROM Movies m 
WHERE m.movieYear < ANY (SELECT m2.movieYear 
                         FROM Movies m2 
                         WHERE m2.movieTitle = m.movieTitle);