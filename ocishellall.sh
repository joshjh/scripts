#!/bin/bash

# ocishell.sh - A simple shell script to run OCI containers using runc

COMPARTMENT_ID="ocid1.tenancy.oc1..aaaaaaaavubqhreuolyn4sgauasnx4kohuftpd7h4b6aec7y6thczvw32rqa"

# Check if command line argument is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 {start|stop|list}"
  exit 1
fi

COMMAND=$1

get_db_ids() {
  DB_LIST=$(oci db autonomous-database list --compartment-id "$COMPARTMENT_ID" --all)
  DB_IDS=$(echo "$DB_LIST" | jq -r .data[].id)
  echo "$DB_IDS"
}

list_databases() {
  DB_LIST=$(oci db autonomous-database list --compartment-id "$COMPARTMENT_ID" --all)
  echo "$DB_LIST" | jq -r '.data | map([.id, .["db-name"], .["lifecycle-state"]] | @tsv)[]' | column -t -s $'\t' -N "ID,DB Name,Lifecycle State"
  exit 0
}

start_databases() {

  DB_IDS=$(get_db_ids)
  # Check if there are any stopped databases
  if [ -z "$DB_IDS" ]; then
    echo "No stopped autonomous databases found in the specified compartment."
    exit 0
  else
    echo "Stopped autonomous databases found: $DB_IDS"
    echo "$DB_IDS" | while read -r id; do
    echo "Starting database: $id"
    oci db autonomous-database start --autonomous-database-id "$id"
      done
  fi
}

stop_databases() {
  DB_IDS=$(get_db_ids)
  # Check if there are any running databases
  if [ -z "$DB_IDS" ]; then
    echo "No running autonomous databases found in the specified compartment."
    exit 0
  else
    echo "Running autonomous databases found: $DB_IDS"
    echo "$DB_IDS" | while read -r id; do
    echo "Stopping database: $id"
    oci db autonomous-database stop --autonomous-database-id "$id"
      done
  fi
}

case $COMMAND in
  start)
    start_databases
    ;;
  stop)
    stop_databases
    ;;
    list)
    list_databases
    ;;
  *)
    echo "Invalid command: $COMMAND"
    echo "Usage: $0 {start|stop|list}"
    exit 1
    ;;
esac


