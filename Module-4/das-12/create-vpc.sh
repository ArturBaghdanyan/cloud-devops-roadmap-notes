#!/bin/bash

# 1. Ստեղծել VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=cli-demo-vpc}]' \
  --query 'Vpc.VpcId' \
  --output text)

echo "Created VPC ID: $VPC_ID"

# 2. Ակտիվացնել DNS Hostnames
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames '{"Value":true}'

# 3. Ստեղծել Public Subnet (10.0.1.0/24)
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=cli-demo-public-subnet-1a}]' \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Created Public Subnet ID: $PUBLIC_SUBNET_ID"

# 4. Ստեղծել Private Subnet (10.0.11.0/24)
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.11.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=cli-private-subnet-1a}]' \
  --query 'Subnet.SubnetId' \
  --output text)

echo "Created Private Subnet ID: $PRIVATE_SUBNET_ID"

# 5. Ստեղծել Internet Gateway (IGW) և կցել VPC-ին
IGW_ID=$(aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=cli-demo-igw}]' \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

aws ec2 attach-internet-gateway \
  --vpc-id $VPC_ID \
  --internet-gateway-id $IGW_ID

echo "Created & Attached IGW ID: $IGW_ID"

# 6. Ստեղծել Route Table Public Subnet-ի համար
ROUTE_TABLE_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=cli-demo-public-rt}]' \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

echo "Created Route Table ID: $ROUTE_TABLE_ID"

# 7. Կապել Route Table-ը Public Subnet-ին
aws ec2 associate-route-table \
  --subnet-id $PUBLIC_SUBNET_ID \
  --route-table-id $ROUTE_TABLE_ID

echo "Associated Public Route Table with Public Subnet successfully!"