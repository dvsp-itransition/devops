import psycopg2

# creates table on default DB
def create_table():    
    conn = psycopg2.connect(dbname="postgres", user="postgres", password="postgres", host="localhost", port="5432") # Connect your app to the remote database.
    cur = conn.cursor() # Opens a cursor for database operations
    cur.execute('''create table books(id serial, name text, author text);''') # executes a query
    print("Table created!")
    conn.commit() # saves changes
    conn.close() # closes connection

# create_table()   

def insert_data(): # def insert_data(name, age, address)
    conn = psycopg2.connect(dbname="postgres", user="postgres", password="postgres", host="localhost", port="5432")
    cur = conn.cursor() 

    name = input("input name: ")
    author = input("input author: ")
    
    query = '''insert into books(name,author) values(%s, %s);'''
    cur.execute(query,(name, author)) 

    print("New data inserted!")
    conn.commit() 
    conn.close()  

insert_data()

