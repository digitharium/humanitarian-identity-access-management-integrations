#!/bin/bash

if [ -z "$1" ]; then
  APP=drupal
else
  APP="$1"
fi

if [ -z "$2" ]; then
  REALM=Humanitarians
else
  REALM="$2"
fi

export PATH=$PATH:/opt/keycloak/bin
TMPFILE=`mktemp`

#KEYCLOAK_ADMIN=admin
#KEYCLOAK_ADMIN_PASSWORD=admin

kcadm.sh config credentials --server http://localhost:8080 \
  --realm master --user "$KEYCLOAK_ADMIN" --password "$KEYCLOAK_ADMIN_PASSWORD"

echo "Using realm '$REALM'"

# Create a realm
kcadm.sh create realms -s realm=$REALM -s enabled=true

# Create a group
GROUP_NAME=$APP-users
kcadm.sh create groups -r $REALM -s name=$GROUP_NAME 2>&1 | tee "$TMPFILE"
GROUP_ID=`cat "$TMPFILE" | cut "-d'" -f2`

# Create a realm role
ROLE_NAME=$APP-users
kcadm.sh create roles -r $REALM -s name=$ROLE_NAME -s "description=Regular $APP user"

# Add a role to a group
kcadm.sh add-roles -r $REALM --gname $GROUP_NAME --rolename $ROLE_NAME

# Create a user
USER_NAME=sebastian
kcadm.sh create users -r $REALM -s username=$USER_NAME -s enabled=true  2>&1 | tee "$TMPFILE"
USER_ID=`cat "$TMPFILE" | cut "-d'" -f2`

## Delete a user
# kcadm.sh delete users/$USER_ID -r $REALM

# Add a user to a group
echo "Adding user $USER_NAME ($USER_ID) to group $GROUP_NAME ($GROUP_ID)"
kcadm.sh update users/$USER_ID/groups/$GROUP_ID -r $REALM -s realm=$REALM \
  -s userId=$USER_ID -s groupId=$GROUP_ID -n

## Remove a user from a group
# kcadm.sh delete users/$USER_ID/groups/$GROUP_ID -r $REALM

# TODO: Create/configure a default group for new (all?) users

# TODO: Add group to another group
