CREATE TABLE author (
    aut_id INT PRIMARY KEY AUTO_INCREMENT,
    aut_first_name VARCHAR(100) NOT NULL,
    aut_last_name VARCHAR(100) NOT NULL,
    aut_date_birth DATE,
    aut_nationality VARCHAR(50), 
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE publisher (
    pub_id INT PRIMARY KEY AUTO_INCREMENT,
    pub_name VARCHAR(150) NOT NULL UNIQUE,
    pub_city VARCHAR(100),
    pub_country VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE users (
    usr_id INT PRIMARY KEY AUTO_INCREMENT,
    usr_first_name VARCHAR(100) NOT NULL,
    usr_last_name VARCHAR(100) NOT NULL,
    usr_email VARCHAR(255) NOT NULL UNIQUE,
    usr_registration_date DATE NOT NULL,
    usr_is_active BOOLEAN NOT NULL DEFAULT TRUE, 
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE book (
    book_isbn VARCHAR(17) PRIMARY KEY, 
    book_title VARCHAR(255) NOT NULL,
    book_publication_year INT NOT NULL,
    book_publisher_id INT NOT NULL,
    book_page_count INT,
    book_description TEXT,
    book_genre VARCHAR(100) NOT NULL, 
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY (book_publisher_id) REFERENCES publisher(pub_id)
);


CREATE TABLE book_author (
    book_author_id INT PRIMARY KEY AUTO_INCREMENT,
    book_isbn VARCHAR(17) NOT NULL,
    aut_id INT NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,

    FOREIGN KEY (book_isbn) REFERENCES book(book_isbn),
    FOREIGN KEY (aut_id) REFERENCES author(aut_id),
    UNIQUE (book_isbn, aut_id)
);

CREATE TABLE loan (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    usr_id INT NOT NULL,
    book_isbn VARCHAR(17) NOT NULL,
    loan_date TIMESTAMP NOT NULL,
    loan_due_date TIMESTAMP NOT NULL,
    loan_return_date TIMESTAMP,
    loan_status VARCHAR(50) NOT NULL DEFAULT 'Ongoing',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY (usr_id) REFERENCES users(usr_id),
    FOREIGN KEY (book_isbn) REFERENCES book(book_isbn)
);
