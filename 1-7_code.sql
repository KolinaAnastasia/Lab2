-- Выбрать все книги у которых прошел срок возврата
SELECT
    b.Book_code,
    b.Title,
    b.Publication_year,
    s.Reader_code,
    s.Issue_date,
    s.Duration,
    s.Issue_date + s.Duration AS Return_Date
FROM Books b
JOIN Subscription s ON b.Book_code = s.Book_code
WHERE s.Return_mark = FALSE
  AND s.Issue_date + s.Duration < CURRENT_DATE;

-- Выбрать все книги, выпущенные издательствами, в названии которых есть слово "Москва"
SELECT *
FROM Books
WHERE Publisher ILIKE '%Москва%';

-- Создать таблицу, содержащую данные 1 запроса с указанием года издания
CREATE TABLE books_return_control AS
SELECT
    b.Book_code,
    b.Title,
    b.Publication_year,
    b.Publisher,
    s.Reader_code,
    s.Issue_date,
    s.Duration,
    s.Return_mark,
    s.Issue_date + s.Duration AS Return_Date
FROM Books b
JOIN Subscription s ON b.Book_code = s.Book_code
WHERE s.Return_mark = FALSE
  AND s.Issue_date + s.Duration < CURRENT_DATE;

-- В созданной таблице для всех книг, выпущенных до 1990 года, продлить срок возврата на 2 года
INSERT INTO books_return_control
SELECT
    b.Book_code,
    b.Title,
    b.Publication_year,
    b.Publisher,
    s.Reader_code,
    s.Issue_date,
    s.Duration,
    s.Return_mark,
    s.Issue_date + s.Duration AS Return_Date
FROM Books b
JOIN Subscription s ON b.Book_code = s.Book_code
WHERE s.Return_mark = FALSE
  AND s.Issue_date + s.Duration BETWEEN CURRENT_DATE
                                    AND CURRENT_DATE + 30
  AND NOT EXISTS (
      SELECT 1
      FROM books_return_control c
      WHERE c.Book_code = b.Book_code
        AND c.Reader_code = s.Reader_code
        AND c.Issue_date = s.Issue_date
  );

--  Удалить из созданной таблицы записи для всех книг, названия которых начинаются и заканчиваются на одну букву
DELETE FROM books_return_control
WHERE LOWER (LEFT(Title,1)) = LOWER(RIGHT(Title,1));

-- Посчитать сколько раз была выдана каждая из книг, хранящаяся в библиотеке
SELECT
    b.Book_code,
    b.Title,
    COUNT(s.Book_code) AS Issue_Count
FROM Books b
LEFT JOIN Subscription s ON b.Book_code = s.Book_code
GROUP BY b.Book_code, b.Title
ORDER BY b.Book_code;
