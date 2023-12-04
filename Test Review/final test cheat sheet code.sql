-- 创建存储过程示例
CREATE PROCEDURE JoeMenu (
    IN b CHAR(20), -- 参数1
    IN p REAL      -- 参数2
)
AS $$
DECLARE
    exampleVariable INTEGER := 10; -- 局部变量声明及初始化
    category VARCHAR(20);          -- 另一个局部变量，用于价格分类
    counter INTEGER := 0;          -- 循环计数器
    productPrice REAL;             -- 用于存储查询到的价格
    productQuantity INTEGER;       -- 用于存储查询到的数量
    myCursor CURSOR FOR SELECT price, quantity FROM Sells WHERE beer = b; -- 声明游标
BEGIN
    -- 执行一些操作
    exampleVariable := exampleVariable + 1; -- 赋值语句

    -- 使用CASE...WHEN...来确定价格分类
    category := CASE 
                    WHEN p < 10 THEN 'Cheap'
                    WHEN p >= 10 AND p < 20 THEN 'Moderate'
                    ELSE 'Expensive'
                END;

    -- 打开游标
    OPEN myCursor;

    -- 使用游标遍历符合条件的记录
    LOOP
        FETCH myCursor INTO productPrice, productQuantity;
        EXIT WHEN NOT FOUND; -- 当游标没有更多记录时退出循环

        -- 在这里处理每条记录，例如更新计数器或执行其他操作
        counter := counter + 1;

        -- 可以在此处添加更多对每个记录的处理
        -- 比如: UPDATE Sells SET ... WHERE ...;

    END LOOP;

    -- 关闭游标
    CLOSE myCursor;

    -- 根据价格分类插入不同的信息
    INSERT INTO Sells
    VALUES('Joe''s Bar', b, p, category);
END;
$$ LANGUAGE plpgsql;

-- 调用存储过程
CALL JoeMenu('Moosedrool', 5.00);


-- 创建函数示例
CREATE FUNCTION CalculateDiscount(price REAL) RETURNS REAL
    AS $$
DECLARE
    discount REAL;
    i INTEGER;
BEGIN
    -- 根据价格计算折扣
    IF price > 100 THEN
        discount := 0.1; -- 10% 折扣
    ELSE
        discount := 0.05; -- 5% 折扣
    END IF;

    -- FOR循环示例
    FOR i IN 1..10 LOOP
        -- 在这里执行一些循环操作
    END LOOP;

    RETURN price * discount; -- 返回计算的折扣
END;
$$ LANGUAGE plpgsql;
