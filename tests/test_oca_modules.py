#!/usr/bin/env python3
"""
OCA Module Testing Framework
Tests module installation and basic functionality
"""

import xmlrpc.client
import sys

# Configuration
url = 'http://localhost:8069'
db = 'odoo-db'
username = 'dhquangphuong@gmail.com'
password = 'quangphuong'

# Connect to Odoo
common = xmlrpc.client.ServerProxy(f'{url}/xmlrpc/2/common')
uid = common.authenticate(db, username, password, {})
models = xmlrpc.client.ServerProxy(f'{url}/xmlrpc/2/object')

def test_module_installed(module_name):
    """Check if a module is properly installed"""
    module = models.execute_kw(
        db, uid, password,
        'ir.module.module', 'search_read',
        [[['name', '=', module_name]]],
        {'fields': ['name', 'state']}
    )
    
    if module and module[0]['state'] == 'installed':
        print(f"✅ {module_name} is installed")
        return True
    else:
        print(f"❌ {module_name} is not installed")
        return False

# Test OCA modules
oca_modules_to_test = [
    'base_technical_user',
    'web_responsive',
    'auditlog',
]

for module in oca_modules_to_test:
    test_module_installed(module)