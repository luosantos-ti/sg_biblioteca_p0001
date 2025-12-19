/*
4.1 Consultar Livros Atualmente Atrasados (Overdue)
Objetivo: Identificar rapidamente os livros que deveriam ter sido devolvidos, mas que ainda não tiveram o campo loan_return_date preenchido, e rastrear o usuário responsável. Esta consulta é crucial para a gestão da disponibilidade do acervo.
*/
SELECT
    l.loan_id,
    b.book_title AS book_title,
    CONCAT(u.usr_first_name, ' ', u.usr_last_name) AS user_name,
    u.usr_email AS user_email,
    l.loan_due_date AS due_date,
    DATEDIFF(CURRENT_TIMESTAMP(), l.loan_due_date) AS days_overdue
FROM loan l
JOIN book b ON l.book_isbn = b.book_isbn
JOIN users u ON l.usr_id = u.usr_id
WHERE
    l.loan_status = 'Ongoing' AND
    l.loan_due_date < CURRENT_TIMESTAMP();

/*
4.2 Determinar Autores Mais Populares e Suas Editoras
Objetivo: Gerar um ranking dos autores mais emprestados para guiar decisões de aquisição de novo acervo e renovação de licenças.
*/
SELECT
    CONCAT(a.aut_first_name, ' ', a.aut_last_name) AS author_name,
    p.pub_name AS main_publisher,
    COUNT(l.loan_id) AS total_loans
FROM author a
JOIN book_author ba ON a.aut_id = ba.aut_id
JOIN book b ON ba.book_isbn = b.book_isbn
JOIN loan l ON b.book_isbn = l.book_isbn
JOIN publisher p ON b.book_publisher_id = p.pub_id
GROUP BY
    author_name, p.pub_name
ORDER BY
    total_loans DESC
LIMIT 10;

/*
4.3 Listar Livros com Múltiplos Autores (Essencial para Acervo Acadêmico)
Objetivo: Isolar e listar todos os livros que possuem colaboração, validando o uso da tabela de junção book_author e auxiliando na categorização de pesquisa
*/
SELECT
    B.book_title AS book_title,
    COUNT(BA.aut_id) AS author_count,
    GROUP_CONCAT(A.aut_last_name ORDER BY A.aut_last_name SEPARATOR ', ') AS last_names_list
    
FROM book_author BA
JOIN book B ON BA.book_isbn = B.book_isbn
JOIN author A ON BA.aut_id = A.aut_id
GROUP BY
    B.book_title
HAVING
    author_count > 1
ORDER BY
    author_count DESC;

/*
4.4 Consultar o Histórico de Usuários Inativos
Objetivo: Identificar usuários que estão inativos (usr_is_active = FALSE) para fins de governança de dados ou reengajamento, juntamente com o último livro que eles emprestaram
*/
SELECT
    CONCAT(u.usr_first_name, ' ', u.usr_last_name) AS user_name,
    u.usr_email AS email,
    l.last_loan_date,
    b.book_title AS last_book_title
FROM users u
LEFT JOIN (
    SELECT
        usr_id,
        MAX(loan_date) AS last_loan_date
    FROM loan
    GROUP BY usr_id
) l ON u.usr_id = l.usr_id
LEFT JOIN loan lo ON lo.usr_id = u.usr_id AND lo.loan_date = l.last_loan_date
LEFT JOIN book b ON b.book_isbn = lo.book_isbn
WHERE u.usr_is_active = FALSE
ORDER BY l.last_loan_date DESC;

/*
4.5 Identificar Editoras com Maior Tempo Médio de Retenção de Livros
Objetivo: Calcular o tempo médio (em dias) que os livros de cada editora permanecem emprestados antes de serem devolvidos. Isso ajuda a identificar editoras cujos livros são mais populares, têm maior retenção ou demandam mais atenção na gestão do acervo
*/
SELECT
    P.pub_name AS publisher_name,
    COUNT(L.loan_id) AS total_loans,
    AVG(DATEDIFF(L.loan_return_date, L.loan_date)) AS avg_loan_days,
    MAX(DATEDIFF(L.loan_return_date, L.loan_date)) AS max_loan_days
FROM loan L
JOIN book B ON L.book_isbn = B.book_isbn
JOIN publisher P ON B.book_publisher_id = P.pub_id
WHERE
    L.loan_status = 'Returned'
    AND L.loan_return_date IS NOT NULL
GROUP BY P.pub_name
HAVING
    total_loans > 3  -- Only considers publishers with at least 3 loans
ORDER BY
    avg_loan_days DESC;




