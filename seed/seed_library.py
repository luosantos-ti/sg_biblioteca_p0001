import os
import random
from datetime import timedelta, datetime
from faker import Faker
from sqlalchemy import create_engine, text

# DATABASE CONFIG
DB_USER = "seu_admin"
DB_PASSWORD = "sua_senha"
DB_HOST = "localhost"
DB_PORT = "3306"
DB_NAME = "seu_bd"

DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
print(DATABASE_URL)

fake = Faker("pt_BR")
engine = create_engine(DATABASE_URL)

NUM_RECORDS = 200

# ------------------------------------------------------------
# 1. DATA GENERATORS
# ------------------------------------------------------------

def generate_author_data(num):
    data = []
    for _ in range(num):
        data.append({
            'aut_first_name': fake.first_name(),
            'aut_last_name': fake.last_name(),
            'aut_date_birth': fake.date_of_birth(minimum_age=25, maximum_age=90),
            'aut_nationality': random.choice(['Brasileira', 'Americana', 'Inglesa', 'Francesa', 'Espanhola']),
        })
    return data


def generate_user_data(num):
    data = []
    for _ in range(num):
        first = fake.first_name()
        last = fake.last_name()
        data.append({
            'usr_first_name': first,
            'usr_last_name': last,
            'usr_email': f"{first.lower()}.{last.lower()}{random.randint(1,99)}@emailficticio.com",
            'usr_registration_date': fake.date_this_year(),
            'usr_is_active': random.choice([True, True, True, False]),
        })
    return data


def generate_publisher_data(num):
    data = []
    fake.unique.clear()
    for _ in range(num):
        data.append({
            'pub_name': fake.unique.company() + " Editora",
            'pub_city': fake.city(),
            'pub_country': fake.country(),
        })
    return data


def generate_book_data(num, publisher_ids):
    data = []
    fake.unique.clear()

    genres = [
        "Ficção", "Fantasia", "Drama", "Terror", "Suspense",
        "Romance", "Ciência", "História", "Tecnologia",
        "Aventura", "Biografia", "Autoajuda", "Poesia"
    ]

    for _ in range(num):
        isbn = fake.unique.isbn13().replace("-", "")
        isbn = isbn.ljust(17, "0")  # ensure 17 chars

        data.append({
            'book_isbn': isbn,
            'book_title': fake.sentence(nb_words=5).title(),
            'book_publication_year': random.randint(1990, 2024),
            'book_publisher_id': random.choice(publisher_ids),
            'book_page_count': random.randint(120, 800),
            'book_description': fake.paragraph(nb_sentences=3),
            'book_genre': random.choice(genres),  # NEW FIELD
        })

    return data



def generate_junction_data(book_isbns, author_ids):
    data = []
    for isbn in book_isbns:
        num_authors = random.choice([1, 1, 2])  # some books with 1 author, some with 2
        for aut_id in random.sample(author_ids, num_authors):
            data.append({
                'book_isbn': isbn,
                'aut_id': aut_id
            })
    return data


def generate_loan_data(user_ids, book_isbns, num):
    data = []

    for _ in range(num):
        loan_date = fake.date_time_this_year()
        due_date = loan_date + timedelta(days=random.randint(7, 30))

        status = random.choice(['Ongoing', 'Returned', 'Overdue'])

        # Return date rules depending on loan status
        if status == 'Returned':
            return_date = loan_date + timedelta(days=random.randint(1, (due_date - loan_date).days))
        elif status == 'Overdue':
            return_date = due_date + timedelta(days=random.randint(1, 60))
        else:
            return_date = None

        data.append({
            'usr_id': random.choice(user_ids),
            'book_isbn': random.choice(book_isbns),
            'loan_date': loan_date,
            'loan_due_date': due_date,
            'loan_return_date': return_date,
            'loan_status': status,
        })

    return data

# ------------------------------------------------------------
# 2. SEEDING PROCESS
# ------------------------------------------------------------

def seed_database():
    fake.unique.clear()

    print("Generating data...")

    authors = generate_author_data(NUM_RECORDS)
    publishers = generate_publisher_data(NUM_RECORDS)
    users = generate_user_data(NUM_RECORDS)

    print("Inserting authors, publishers and users...")

    datasets_initial = {
        "author": authors,
        "publisher": publishers,
        "users": users,
    }

    with engine.connect() as conn:
        # Insert initial entities (with auto-increment IDs)
        for table, data_list in datasets_initial.items():
            columns = ", ".join(data_list[0].keys())
            placeholders = ", ".join([f":{c}" for c in data_list[0].keys()])
            stmt = text(f"INSERT INTO {table} ({columns}) VALUES ({placeholders})")

            conn.execute(stmt, data_list)
            conn.commit()
            print(f" ✔ Inserted {len(data_list)} records into {table}")

        # Retrieve generated IDs
        author_ids = [row[0] for row in conn.execute(text("SELECT aut_id FROM author")).fetchall()]
        publisher_ids = [row[0] for row in conn.execute(text("SELECT pub_id FROM publisher")).fetchall()]
        user_ids = [row[0] for row in conn.execute(text("SELECT usr_id FROM users")).fetchall()]

        # Generate dependent data
        books = generate_book_data(NUM_RECORDS * 2, publisher_ids)
        book_isbns = [b['book_isbn'] for b in books]

        book_author = generate_junction_data(book_isbns, author_ids)
        loans = generate_loan_data(user_ids, book_isbns, NUM_RECORDS * 3)

        datasets_later = {
            "book": books,
            "book_author": book_author,
            "loan": loans
        }

        # Insert dependent entities
        for table, data_list in datasets_later.items():
            columns = ", ".join(data_list[0].keys())
            placeholders = ", ".join([f":{c}" for c in data_list[0].keys()])
            stmt = text(f"INSERT INTO {table} ({columns}) VALUES ({placeholders})")

            conn.execute(stmt, data_list)
            conn.commit()
            print(f" ✔ Inserted {len(data_list)} records into {table}")

    print("\n Seeding completed successfully!")


if __name__ == "__main__":
    seed_database()
