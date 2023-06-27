#!/bin/bash

# Retrieve the latest RDS snapshot
latest_snapshot=$(aws rds describe-db-snapshots --snapshot-type automated --query 'reverse(sort_by(DBSnapshots, &SnapshotCreateTime))[0].DBSnapshotIdentifier' --output text)

# Restore the RDS instance from the latest snapshot
aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier dr-digitali-xyz \
    --db-snapshot-identifier "$latest_snapshot" \
    --db-instance-class db.t3.small \
    --vpc-security-group-ids sg-0e21074cbd332e17d \
    --availability-zone ap-southeast-1a \
    --db-subnet-group-name default-vpc-0d0ecd404c13cd626 \
    --publicly-accessible \
    --tags Key=Environment,Value=DR
#sleep for 10mint
# Wait for 10 minutes (600 seconds)
sleep 450
export latest_URL=$(aws rds describe-db-instances --db-instance-identifier dr-digitali-xyz --query 'DBInstances[].Endpoint.Address' --output text)
echo $latest_URL
