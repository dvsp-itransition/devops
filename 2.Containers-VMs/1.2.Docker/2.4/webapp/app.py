from flask import Flask, render_template

app = Flask(__name__) 

@app.route('/') 
def index():   
    return render_template('index.html')

@app.route('/contacts') 
def contacts():
    return render_template('contacts.html')

@app.route('/login') 
def login():
    return render_template('login.html')

app.run(host='0.0.0.0', port=5000) # runs app