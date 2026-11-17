-- 1. Выбрать все книги, у которых прошёл срок возврата

SELECT DISTINCT Books.*
FROM Books
JOIN Subscription
ON Books.Book_code = Subscription.Book_code
WHERE Subscription.Return_mark = FALSE
AND Subscription.Issue_date + Subscription.Duration < CURRENT_DATE;


-- 2. Выбрать все книги, выпущенные издательствами, в название которых входит слово «Москва»

SELECT *
FROM Books
WHERE Publisher ILIKE '%Москва%';


-- 3. Создать таблицу, содержащую данные 1 запроса с указанием года издания

SELECT DISTINCT ON (Books.Book_code)
    Books.*,
    Subscription.Issue_date,
    Subscription.Duration,
    Subscription.Issue_date + Subscription.Duration AS Return_Date
INTO books_return_control
FROM Books
JOIN Subscription
ON Books.Book_code = Subscription.Book_code
WHERE Subscription.Return_mark = FALSE
AND Subscription.Issue_date + Subscription.Duration < CURRENT_DATE
ORDER BY Books.Book_code;


-- 4. Добавить в созданную таблицу книги, у которых до конца срока возврата остался ещё месяц

INSERT INTO books_return_control
SELECT DISTINCT ON (Books.Book_code)
    Books.*,
    Subscription.Issue_date,
    Subscription.Duration,
    Subscription.Issue_date + Subscription.Duration AS Return_Date
FROM Books
JOIN Subscription
ON Books.Book_code = Subscription.Book_code
WHERE Subscription.Return_mark = FALSE
AND Subscription.Issue_date + Subscription.Duration
    BETWEEN CURRENT_DATE AND CURRENT_DATE + 30
AND NOT EXISTS (
    SELECT 1
    FROM books_return_control
    WHERE books_return_control.Book_code = Books.Book_code
)
ORDER BY Books.Book_code;


-- 5. В созданной таблице для всех книг, выпущенных до 1990 года, продлить срок возврата на 2 года

UPDATE books_return_control
SET Return_Date = (Return_Date + INTERVAL '2 years')::DATE
WHERE Publication_year < 1990;


-- 6. Удалить из созданной таблицы записи для всех книг, названия которых начинаются и заканчиваются на одну букву

DELETE FROM books_return_control
WHERE LOWER(LEFT(Title, 1)) = LOWER(RIGHT(Title, 1));


-- 7. Посчитать, сколько раз была выдана каждая из книг, хранящихся в библиотеке

SELECT
    Books.Book_code,
    Books.Title,
    COUNT(Subscription.Book_code) AS Issue_Count
FROM Books
LEFT JOIN Subscription
ON Books.Book_code = Subscription.Book_code
GROUP BY Books.Book_code, Books.Title
ORDER BY Books.Book_code;
