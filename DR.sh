#!/bin/bash
#Written By Harishankar

# Generate a random suffix for the DB instance identifier
random_suffix=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)

# Create the DB instance identifier with a static prefix and random suffix
db_instance_identifier="dr-digitali-$random_suffix"

# Retrieve the latest RDS snapshot
latest_snapshot=$(aws rds describe-db-snapshots --db-instance-identifier digitali --snapshot-type automated --query 'reverse(sort_by(DBSnapshots, &SnapshotCreateTime))[0].DBSnapshotIdentifier' --output text)

# Restore the RDS instance from the latest snapshot
aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier "$db_instance_identifier" \
    --db-snapshot-identifier "$latest_snapshot" \
    --db-instance-class db.t3.small \
    --vpc-security-group-ids sg-0e21074cbd332e17d \
    --availability-zone ap-southeast-1a \
    --db-subnet-group-name default-vpc-0d0ecd404c13cd626 \
    --publicly-accessible \
    --tags Key=Environment,Value=DR

# Wait for 10 minutes (600 seconds)
sleep 450

# Get the latest URL
latest_URL=$(aws rds describe-db-instances --db-instance-identifier "$db_instance_identifier" --query 'DBInstances[].Endpoint.Address' --output text)
echo "$latest_URL"
pm2 restart all
