#opa test -v rbac.rego rbac_test.rego

# Same package name as policy name
package cnapp.rbac

import data.cnapp.rbac

# Mock Data
roles = {
    "raghu": ["admin", "author"],  
    "sushil": ["subscriber"],
    "ashok": ["subscriber"]
}

permissions = {
    "subscriber": [
        {
            "action": "read",
            "type": "post"
        },
        {
            "action": "comment",
            "type": "post"
        }
    ]
}

blacklist = {
    "sushil": [
        {
            "action": "comment",
            "type": "post"
        }
    ]
}

test_admin_allowed {
    allow with input as {"user": "raghu"} with rbac.roles as roles
}

test_non_admin_not_allowed {
    not allow with input as {"user": "sushil"} with rbac.roles as roles
}

test_grants_allowed {
    allow with input as {"user": "sushil", "action": "read", "type": "post"} with rbac.roles as roles with rbac.permissions as permissions
}

test_grants_not_allowed {
    not allow with input as {"user": "sushil", "action": "publish", "type": "post"} with rbac.roles as roles with rbac.permissions as permissions
}

test_grants_allowed_list {
    user_is_granted[{"action": "read", "type": "post"}] with input as {"user": "sushil", "action": "read", "type": "post"} with rbac.roles as roles with rbac.permissions as permissions
    user_is_granted[{"action": "comment", "type": "post"}] with input as {"user": "sushil", "action": "read", "type": "post"} with rbac.roles as roles with rbac.permissions as permissions
}

test_grants_not_blacklisted {
    not user_grant_is_blacklisted with input as {"user": "sushil", "action": "read", "type": "post"} with rbac.roles as roles with rbac.permissions as permissions with rbac.blacklist as blacklist
}

test_grants_blacklisted {
    user_grant_is_blacklisted with input as {"user": "sushil", "action": "comment", "type": "post"} with rbac.roles as roles with rbac.permissions as permissions with rbac.blacklist as blacklist
}

test_grants_not_allowed_if_blacklisted {
    not allow with input as {"user": "sushil", "action": "comment", "type": "post"} with rbac.roles as roles with rbac.permissions as permissions with rbac.blacklist as blacklist
}

test_grants_allowed_if_not_blacklisted {
    allow with input as {"user": "sushil", "action": "read", "type": "post"} with rbac.roles as roles with rbac.permissions as permissions with rbac.blacklist as blacklist
}

test_who_are_list {
    who_are["sushil"] with input as {"role": "subscriber"} with rbac.roles as roles
    who_are["ashok"] with input as {"role": "subscriber"} with rbac.roles as roles
}

test_not_in_who_are_list {
    not who_are["raghu"] with input as {"role": "subscriber"} with rbac.roles as roles
}

test_roles_can_list {
    roles_can["subscriber"] with input as {"grant": {"action": "comment", "type": "post"}} with rbac.permissions as permissions
    roles_can["subscriber"] with input as {"grant": {"action": "read", "type": "post"}} with rbac.permissions as permissions
}

test_not_in_roles_can_list {
    not roles_can["subscriber"] with input as {"grant": {"action": "post", "type": "post"}} with rbac.permissions as permissions
}

test_users_can_list {
    users_can["sushil"] with input as {"grant": {"action": "comment", "type": "post"}} with rbac.roles as roles with rbac.permissions as permissions
    users_can["ashok"] with input as {"grant": {"action": "read", "type": "post"}} with rbac.roles as roles with rbac.permissions as permissions
}

test_not_in_users_can_list {
    not users_can["raghu"] with input as {"grant": {"action": "comment", "type": "post"}} with rbac.roles as roles with rbac.permissions as permissions
}