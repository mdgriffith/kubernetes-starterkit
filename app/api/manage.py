import os
import psycopg2
from flask import Flask

app = Flask(__name__)
# connection = None
# cursor = None
#
# app.config.update(dict(
#     POSTGRES_DATABASE = os.getenv('POSTGRES_DATABASE', None),
#     POSTGRES_USER = os.getenv('POSTGRES_USER', None),
#     POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD', None),
#     POSTGRES_HOST = "postgres",
#     POSTGRES_PORT = "5432"
#
# ))

@app.route("/")
def hello():
    return "Hello World!"


@app.route("/test-database")
def test_database():

    config = dict(
        POSTGRES_DATABASE = os.getenv('POSTGRES_DATABASE', None),
        POSTGRES_USER = os.getenv('POSTGRES_USER', None),
        POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD', None),
        POSTGRES_HOST = "postgres",
        POSTGRES_PORT = "5432"
    )
    print config
    connection = psycopg2.connect(database=config['POSTGRES_DATABASE'], user=config['POSTGRES_USER'], password=config['POSTGRES_PASSWORD'], host=config['POSTGRES_HOST'], port=config['POSTGRES_PORT'])
    cursor = connection.cursor()
    if not table_exists(cursor, "vegetables"):
        create_test_table(cursor)
        connection.commit()

    cursor.execute("SELECT name FROM vegetables;")
    vegetable = cursor.fetchone()
    return "Here's a value I got from the database: " + str(vegetable)



# @app.route("/test-database")
# def test_database():
#     cursor.execute("SELECT name FROM vegetables;")
#     vegetable = cursor.fetchone()
#     return "Here's a value I got from the database: " + str(vegetable)


def create_test_table(cursor):
    print "loading test data"
    cursor.execute("CREATE TABLE vegetables (id serial PRIMARY KEY, rating integer, name varchar);")
    cursor.execute("INSERT INTO vegetables (rating, name) VALUES (%s, %s)", (72, "Zucchini"))
    # connection.commit()

def table_exists(cursor, table):
    cursor.execute("SELECT exists(select * from information_schema.tables where table_name=%s)", (table,))
    return cursor.fetchone()[0]
    # pass


if __name__ == "__main__":

    # connection = psycopg2.connect(database=database, user=user, password=password, host=host, port=port)
    # cursor = connection.cursor()
    # if not table_exists("vegetables"):
    #     create_test_table()

    app.run()
