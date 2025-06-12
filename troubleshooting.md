## Troubleshooting Example

### Issue
Tests failed with `ImportError: cannot import name 'Item' from 'app'`.

### Cause
Python treated `app` as a module, not a package. The `Item` model was not exposed correctly.

### Fix
I refactored the structure to make `app/` a package with `__init__.py`, and updated test imports accordingly.

---

### Issue
Terraform alarm resources failed with `Unsupported attribute: module.ec2.instance_id`.

### Fix
I added an `output` block in the `ec2` module to expose the EC2 `instance_id`, allowing the root module to access it for monitoring.
