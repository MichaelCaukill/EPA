# app.py
from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///app.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Secret key for flash messages
app.secret_key = os.getenv('SECRET_KEY', 'your-secret-key')

db = SQLAlchemy(app)

class Item(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)

# Create database tables if they don't exist
if __name__ == '__main__':
    with app.app_context():
        db.create_all()

@app.route('/')
def index():
    return redirect(url_for('list_items'))

@app.route('/items')
def list_items():
    items = Item.query.all()
    return render_template('list_items.html', items=items)

@app.route('/items/new', methods=['GET', 'POST'])
def create_item():
    if request.method == 'POST':
        name = request.form['name']
        description = request.form.get('description')
        item = Item(name=name, description=description)
        db.session.add(item)
        db.session.commit()
        flash('Item created successfully!')
        return redirect(url_for('list_items'))
    return render_template('create_item.html')

@app.route('/items/<int:item_id>')
def show_item(item_id):
    item = Item.query.get_or_404(item_id)
    return render_template('show_item.html', item=item)

@app.route('/items/<int:item_id>/edit', methods=['GET', 'POST'])
def edit_item(item_id):
    item = Item.query.get_or_404(item_id)
    if request.method == 'POST':
        item.name = request.form['name']
        item.description = request.form.get('description')
        db.session.commit()
        flash('Item updated successfully!')
        return redirect(url_for('show_item', item_id=item.id))
    return render_template('edit_item.html', item=item)

@app.route('/items/<int:item_id>/delete', methods=['POST'])
def delete_item(item_id):
    item = Item.query.get_or_404(item_id)
    db.session.delete(item)
    db.session.commit()
    flash('Item deleted successfully!')
    return redirect(url_for('list_items'))

if __name__ == '__main__':
    # Use PORT environment variable or default to 8000
    port = int(os.getenv('PORT', 8000))
    debug_mode = os.getenv("FLASK_DEBUG", "false").lower() == "true"
    app.run(host='0.0.0.0', port=port, debug=debug_mode) # nosec B104

# Export for testing and reuse
__all__ = ['app', 'db', 'Item']