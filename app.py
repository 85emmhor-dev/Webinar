import os
from datetime import datetime
from flask import Flask, render_template, request
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Hämta databaslänken från miljövariabeln (som vi sätter i setup-scriptet)
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class Registration(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    company = db.Column(db.String(100), nullable=True)
    title = db.Column(db.String(100), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

with app.app_context():
    db.create_all()

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        name = request.form.get('name')
        email = request.form.get('email')
        company = request.form.get('company')
        title = request.form.get('title')
        
        if name and email:
            new_reg = Registration(name=name, email=email, company=company, title=title)
            db.session.add(new_reg)
            db.session.commit()
            # En snyggare tack-sida
            return f"""
            <div style="font-family: sans-serif; text-align: center; margin-top: 50px;">
                <h1 style="color: green;">Tack {name}!</h1>
                <p>Din plats är säkrad.</p>
                <p><a href='/registrations'>Se alla anmälda (Admin)</a></p>
                <a href='/'>Tillbaka</a>
            </div>
            """
        else:
            return "Fel: Namn och E-post måste fyllas i.", 400
    return render_template('index.html')

@app.route("/registrations")
def registrations():
    all_regs = Registration.query.order_by(Registration.created_at.desc()).all()
    html = """
    <div style="font-family: sans-serif; max-width: 800px; margin: 20px auto;">
        <h1>Anmälda deltagare</h1>
        <ul style="list-style: none; padding: 0;">
    """
    for reg in all_regs:
        html += f"""
        <li style="background: #f4f4f4; margin: 10px 0; padding: 15px; border-radius: 5px;">
            <strong>{reg.name}</strong> <small>({reg.email})</small><br>
            <span style="color: #666;">{reg.company or 'Inget företag'} - {reg.title or '-'}</span>
        </li>
        """
    html += "</ul><br><a href='/'>Tillbaka</a></div>"
    return html

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001)
