#!/bin/bash

# Initialize the database data directory (if necessary)
# if [ ! -f /var/lib/postgresql/data/PG_VERSION ]; then
#    initdb -D /var/lib/postgresql/data
#fi

# Start PostgreSQL
# PostgreSQL's own logging configurations will handle log output
# pg_ctl -D /var/lib/postgresql/data start
# Changing to postgres user to run the command as the postgres user and not as root
# su - postgres -c "pg_ctl -D /var/lib/postgresql/data start"

# docker-entrypoint.sh postgres &

# Wait until PostgreSQL is ready to accept connections (or timeout after 60s)
COUNTER=0
MAX_TRIES=30
SUCCESS=0

while [[ $COUNTER -lt $MAX_TRIES ]]; do
    # Try to connect to the database. Replace 'your_database' with your actual database name,
    # and 'postgres' with the actual username if different.
    # The command will succeed if the server is ready.
    # pg_isready -d VeGApp -U postgres -h localhost -p 5432
    pg_isready -d postgres -U postgres -h postgresdb -p 5432
    if [[ $? -eq 0 ]]; then
        echo "PostgreSQL has started."
        SUCCESS=1
        break
    else
        sleep 2
        let COUNTER+=1
        echo "Waiting for PostgreSQL to initialize... ($COUNTER attempts so far)"
    fi
done

if [[ $SUCCESS -ne 1 ]]; then
    echo "Failed to start PostgreSQL within the expected time frame."
    exit 1
fi

# Path to PostgreSQL log file 
# By default, PostgreSQL logs are often stored in a directory inside the container, typically at a path like /var/lib/postgresql/data/log/. However, this can vary based on how the PostgreSQL image was built.
#LOG_PATH="/var/lib/postgresql/data/log/postgresql.log"

# Wait until PostgreSQL logs that it's ready (or timeout after 60s)
#COUNTER=0
#grep -q 'database system is ready to accept connections' "$LOG_PATH"
#while [[ $? -ne 0 && $COUNTER -lt 60 ]]; do
#    sleep 2
#    let COUNTER+=2
#    echo "Waiting for PostgreSQL to initialize... ($COUNTER seconds so far)"
#    grep -q 'database system is ready to accept connections' "$LOG_PATH"
#done

# Restore not yet implemented
# Restore from dump # Replace 'your_username', 'your_database', and the path to your dump file as necessary #psql -U your_username -d your_database -f /home/dump/your_dump.sql

# Keep container running
tail -f /dev/null
