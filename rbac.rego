# Role-based Access Control (RBAC)
# --------------------------------
#
# This example defines an RBAC model for a Blog API. The Blog API allows users to:
#
#   * Read Posts, 
#   * Comment on Posts, 
#   * Edit and Delete Own Unpublished Posts,
#   * Edit and Delete Own Published Posts,
#   * Publish Own Posts,
#   * Edit, Delete and Publish Any Posts, and so on.
# 
# The policy controls which users can perform actions on which resources. 
# The policy implements a classic Role-based Access Control model where users are 
# assigned to roles and roles are granted the ability to perform some action(s) on 
# some type of resource.
#
# This example shows how to:
#
#	* Define an RBAC model in Rego that interprets role mappings represented in JSON.
#	* Iterate/search across JSON data structures (e.g., role mappings)
#

package cnapp.rbac

import data.cnapp.rbac.roles                                   # import roles list from data.cnapp.rbac
import data.cnapp.rbac.permissions                             # import permissions list from data.cnapp.rbac
import data.cnapp.rbac.blacklist                               # import blacklist permissions list from data.cnapp.rbac

import input                                                   # import input.json


# By default, deny requests.
default allow = false

# More than one OR Condition for a variable `allow`

# Allow admins to do anything.
allow {
	user_is_admin
}

# Allow the action if the user is granted permission to perform the action.
allow {
    # check for blacklisted grants for user
	not user_grant_is_blacklisted
    
	# Find grants for the user.
	some grant
	user_is_granted[grant]

	# Check if the grant permits the action. And Condition
	input.action == grant.action
	input.type == grant.type
}

# user_is_admin is true if...
user_is_admin {

	# for some `i`...
	some i

	# "admin" is the `i`-th element in the user->role mappings for the identified user.
	roles[input.user][i] == "admin"
}

# user_is_granted is a set of grants for the user identified in the request.
# The `grant` will be contained if the set `user_is_granted` for every...
user_is_granted[grant] {
	some i, j

	# `role` assigned an element of the user_roles for this user...
	role := roles[input.user][i]

	# `grant` assigned a single grant from the grants list for 'role'...
	grant := permissions[role][j]
}

# user permission has been blacklisted to perform the action.
user_grant_is_blacklisted = true {
	# for some `i`...
	some i
    
	# `grant` assigned a single blacklist grant from the 'blacklist' user list...
	grant := blacklist[input.user][i]

	# Check if the grant permits the action.
	input.action == grant.action
	input.type == grant.type
} else = false

# who_are is a set of users who has roles identified in the request.
who_are[user] {
    # for some `user`...
	some user
    
	# `roleList` assigned a single user roles list...
	roleList := roles[user]
    
    # Check if the roleList matches the input role
    roleList[_] == input.role
}

# who_all_are is a set of users along with roles list who has roles identified in the request.
who_all_are[{ user: roleList }] {
    # for some `user` and `role`...
	some user, role
    
	# `roleList` assigned a single user roles list...
	roleList := roles[user]
    
    # Check if the roleList matches the input role list
    roleList[_] == input.roles[role]
}

# roles_can is a set of roles who has grants identified in the request.
roles_can[role] {
    # for some `role` and `permission`...
	some role, permission
    
	# `roleList` assigned a single permission role list...
	roleList := permissions[role]

    # `grant` assigned a single grant from all grants list...
    grant := roleList[permission]
    
    # Check if the grant permits the action.
	input.grant.action == grant.action
	input.grant.type == grant.type
}

# users_can is a set of roles who has grants identified in the request.
users_can[user] {
    # for some `role` and `permission`...
	some role, permission
    
	# `roleList` assigned a single permission role list...
	roleList := permissions[role]

    # `grant` assigned a single grant from all grants list...
    grant := roleList[permission]
    
    # Check if the grant permits the action.
	input.grant.action == grant.action
	input.grant.type == grant.type

	 # for some `user`
	some user
    
	# `askedRoleList` assigned a single user roles list...
	askedRoleList := roles[user]
    
    # Check if the askedRoleList matches the selected role from upper iteration
    askedRoleList[_] == role
	
}
