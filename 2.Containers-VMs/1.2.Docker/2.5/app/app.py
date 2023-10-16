from flask import Flask, render_template, request, redirect
import psycopg2

app = Flask(__name__) 

host="postgres"
port="5432"
user="postgres" 
password="postgres"
dbname="postgres"


# Gets all books
@app.route('/books')
def books():
    conn = psycopg2.connect(dbname=dbname, user=user, password=password, host=host, port=port) # Connect your app to the remote database.    
    cur = conn.cursor() # Opens a cursor for database operations

    query = '''select * from books;'''
    cur.execute(query) # executes a query    
    books = cur.fetchall() # retrive/read/show all data 
    conn.commit() # saves changes
    conn.close() # closes connection    
  
    return render_template('books.html', books=books)

# Add new books
@app.route('/addbook') # handles get requests by default
def addbook():
    return render_template('addbook.html') 

@app.route('/submitbook', methods=['POST'])   
def submitbook(): # 
    conn = psycopg2.connect(dbname=dbname, user=user, password=password, host=host, port=port)     
    cur = conn.cursor() 

    name  = request.form['name']
    author = request.form['author'] 
    
    query = '''insert into books(name,author) values(%s, %s);'''
    cur.execute(query,(name, author)) 

    conn.commit() 
    conn.close()
    
    return redirect('/books')

# update books
@app.route('/updatebooks')
def updatebooks():
    conn = psycopg2.connect(dbname=dbname, user=user, password=password, host=host, port=port) 
    cur = conn.cursor()
    query = '''select * from books;'''
    cur.execute(query)
    books=cur.fetchall()
    conn.commit() 
    conn.close() 
    return render_template('updatebooks.html', books=books)

@app.route('/update', methods=['post'])
def update():
    conn = psycopg2.connect(dbname=dbname, user=user, password=password, host=host, port=port) 
    cur = conn.cursor()

    newname = request.form['newname']
    newauthor = request.form['newauthor']
    id = request.form['id']

    query = '''UPDATE books SET name=%s, author=%s WHERE id=%s;''' # finds & updates row with new inputs     
    cur.execute(query,(newname, newauthor, id))
           
    conn.commit()
    conn.close()
    return redirect('/books')

# deletes books
@app.route('/delete', methods=['post'])
def delete():
    conn = psycopg2.connect(dbname=dbname, user=user, password=password, host=host, port=port) 
    cur = conn.cursor()

    id = request.form['id']
    query = '''DELETE FROM books WHERE id=%s;'''
    cur.execute(query,(id))
           
    conn.commit()
    conn.close()
    return redirect('/books')

# for health checks
@app.route('/app_health_check')
def health_chech():
    return "seccess"

if __name__ == "__main__": # we need add this code, when we add DB 
    app.run(host='0.0.0.0', port=5000, debug=True) # runs app

