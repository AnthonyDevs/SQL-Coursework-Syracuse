from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'my_simple_secret_key'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mssql+pymssql://sa:SU2orange!@localhost/trainerlink'
db = SQLAlchemy(app)

# Database Models
class Trainer(db.Model):
    __tablename__ = 'Trainers'
    username = db.Column(db.String(50), primary_key=True)
    trainer_name = db.Column(db.String(100), nullable=False)
    trainer_age = db.Column(db.Integer, nullable=False)
    trainer_gender = db.Column(db.String(50), nullable=False)
    trainer_fitness_focus = db.Column(db.String(100), nullable=False)
    trainer_zip_code = db.Column(db.String(10), nullable=False)
    trainer_credentials = db.Column(db.Text)
    trainer_availability = db.Column(db.Text)
    trainer_rate = db.Column(db.Numeric(10, 2), nullable=False)
    trainer_distance = db.Column(db.Integer)

class User(db.Model):
    __tablename__ = 'Users'
    username = db.Column(db.String(50), primary_key=True)
    user_name = db.Column(db.String(100), nullable=False)
    user_age = db.Column(db.Integer, nullable=False)
    user_gender = db.Column(db.String(50), nullable=False)
    user_fitness_focus = db.Column(db.String(100), nullable=False)
    user_zip_code = db.Column(db.String(10), nullable=False)
    user_availability = db.Column(db.Text)
    user_distance = db.Column(db.Integer)

class Match(db.Model):
    __tablename__ = 'Matches'
    match_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_username = db.Column(db.String(50), db.ForeignKey('Users.username'))
    trainer_username = db.Column(db.String(50), db.ForeignKey('Trainers.username'))
    match_date = db.Column(db.Date)
    distance = db.Column(db.String(50))

class Payment(db.Model):
    __tablename__ = 'Payments'
    payment_id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    payment_hours = db.Column(db.Integer, nullable=False)
    payment_total = db.Column(db.Numeric(10, 2), nullable=False)
    payment_date = db.Column(db.Date, nullable=False)
    payment_currency = db.Column(db.String(50), nullable=False)
    payment_method = db.Column(db.String(100), nullable=False)
    match_id = db.Column(db.Integer, db.ForeignKey('Matches.match_id'))


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/trainer_login', methods=['GET', 'POST'])
def trainer_login():
    if request.method == 'POST':
        username = request.form.get('username')
        trainer = Trainer.query.filter_by(username=username).first()
        if trainer:
            return redirect(url_for('trainer_dashboard', username=trainer.username))
        else:
            flash('Trainer not found!', 'error')
    return render_template('trainer_login.html')

@app.route('/user_login', methods=['GET', 'POST'])
def user_login():
    if request.method == 'POST':
        username = request.form.get('username')
        user = User.query.filter_by(username=username).first()
        if user:
            return redirect(url_for('user_dashboard', username=user.username))
        else:
            flash('User not found!', 'error')
    return render_template('user_login.html')

@app.route('/user_dashboard/<username>')
def user_dashboard(username):
    user = User.query.filter_by(username=username).first()
    if user:
        matches = db.session.query(Match, Trainer).join(Trainer, Match.trainer_username == Trainer.username)\
                            .filter(Match.user_username == username).all()
        payments = Payment.query.join(Match, Payment.match_id == Match.match_id)\
                                .filter(Match.user_username == username).all()
        return render_template('user_dashboard.html', user=user, matches=matches, payments=payments)
    flash('User not found!', 'error')
    return redirect(url_for('user_login'))

@app.route('/trainer_dashboard/<username>')
def trainer_dashboard(username):
    trainer = Trainer.query.filter_by(username=username).first()
    if trainer:
        # Prepare and execute the SQL query
        sql_query = text("SELECT * FROM TrainerDashboardView WHERE TrainerUsername = :username")
        result = db.session.execute(sql_query, {'username': username})
        trainer_sessions = result.fetchall()

        # Pass data to template
        return render_template('trainer_dashboard.html', trainer=trainer, trainer_sessions=trainer_sessions)
    else:
        flash('Trainer not found!', 'error')
        return redirect(url_for('trainer_login'))

@app.route('/make_payment', methods=['POST'])
def make_payment():
    user_username = request.form.get('user_username')
    trainer_username = request.form.get('trainer_username')
    hours_trained = int(request.form.get('hours_trained'))
    payment_method = request.form.get('payment_method')

    try:
        # Find the match id and trainer's rate
        match = Match.query.filter_by(user_username=user_username, trainer_username=trainer_username).first()
        if not match:
            flash('Match not found!', 'error')
            return redirect(url_for('user_dashboard', username=user_username))

        trainer = Trainer.query.filter_by(username=trainer_username).first()
        if not trainer:
            flash('Trainer not found!', 'error')
            return redirect(url_for('user_dashboard', username=user_username))

        # Calculate total payment
        total_payment = trainer.trainer_rate * hours_trained

        # Create a new payment record
        new_payment = Payment(
            payment_hours=hours_trained,
            payment_total=total_payment,
            payment_date=datetime.date.today(),
            payment_currency='USD',
            payment_method=payment_method,
            match_id=match.match_id
        )

        # Add and commit the new payment record
        db.session.add(new_payment)
        db.session.commit()

        flash('Payment made successfully!', 'success')
    except Exception as e:
        db.session.rollback()
        flash(f'Error making payment: {e}', 'error')

    return redirect(url_for('user_dashboard', username=user_username))

if __name__ == '__main__':
    app.run(debug=True)
