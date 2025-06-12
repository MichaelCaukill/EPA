import pytest
from unittest.mock import patch
from app import app, db, Item

@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    with app.app_context():
        db.create_all()
        yield app.test_client()
        db.drop_all()

def test_index_redirects(client):
    response = client.get('/')
    assert response.status_code == 302  # Redirect
    assert '/items' in response.location

def test_list_items_empty(client):
    response = client.get('/items')
    assert response.status_code == 200
    assert b"No items" in response.data or b"<html" in response.data  # depending on your template

def test_create_item(client):
    response = client.post('/items/new', data={
        'name': 'Test Item',
        'description': 'A test item description'
    }, follow_redirects=True)
    assert response.status_code == 200
    assert b'Item created successfully!' in response.data

def test_show_item(client):
    # First, insert an item directly
    with app.app_context():
        item = Item(name='Show Test', description='Show desc')
        db.session.add(item)
        db.session.commit()
        item_id = item.id

    response = client.get(f'/items/{item_id}')
    assert response.status_code == 200
    assert b'Show Test' in response.data

def test_edit_item(client):
    with app.app_context():
        item = Item(name='Edit Me', description='Edit desc')
        db.session.add(item)
        db.session.commit()
        item_id = item.id

    response = client.post(f'/items/{item_id}/edit', data={
        'name': 'Edited',
        'description': 'Updated desc'
    }, follow_redirects=True)

    assert response.status_code == 200
    assert b'Item updated successfully!' in response.data

def test_delete_item(client):
    with app.app_context():
        item = Item(name='Delete Me', description='Temp')
        db.session.add(item)
        db.session.commit()
        item_id = item.id

    response = client.post(f'/items/{item_id}/delete', follow_redirects=True)
    assert response.status_code == 200
    assert b'Item deleted successfully!' in response.data

def test_create_item_with_mocked_flash(client):
    with patch("app.app.flash") as mock_flash:
        response = client.post('/items/new', data={
            'name': 'Mocked Flash Item',
            'description': 'This is a test.'
        }, follow_redirects=True)

        assert response.status_code == 200
        mock_flash.assert_called_once_with('Item created successfully!')