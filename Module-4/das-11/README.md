# 🌐 VPC (Virtual Private Cloud) & CIDR Block-երի Խորացված Ուղեցույց (AWS)

---

## 📚 1. Ինչ է Amazon VPC-ն և CIDR Block-ը

### 🔹 Ինչ է VPC-ն (Virtual Private Cloud)

Amazon VPC-ն ձեր **մեկուսացված վիրտուալ ցանցն է** AWS ամպային միջավայրում (AWS Cloud):

- Այն հանդիսանում է ձեր բոլոր ռեսուրսների (EC2, RDS, ElastiCache, EKS) անվտանգ տեղակայման հիմքը։
- VPC-ն լրիվ վերահսկելի է. դուք եք որոշում IP հասցեների տիրույթը, Subnet-ները, Route Table-ները, Internet/NAT Gateway-ները և Firewall կանոնները (Security Groups & NACL)։

### 🔹 Ինչ է CIDR Block-ը (Classless Inter-Domain Routing)

CIDR բլոկը IP հասցեների տիրույթ (range) սահմանելու ձևաչափ է, որն օգտագործում է `IP/Prefix` տեսքը (օրինակ՝ `10.0.0.0/16`):

- **Prefix-ի իմաստը (Slash Notation):**
  IPv4 հասցեն 32 բիթ է։ `/Prefix`-ի թիվը ցույց է տալիս, թե քանի բիթ է **ֆիքսված** ցանցի ID-ի համար (Network ID): Մնացած $(32 - \text{Prefix})$ բիթերը հատկացվում են host-երին (սերվերներին/IP-ներին)։

- **IP-ների քանակի հաշվարկման բանաձևը:**
  $$\text{IP-ների քանակ} = 2^{(32 - \text{Prefix})}$$

> 💡 **Կանոն:** Ինչքան **փոքր** է Prefix-ի թիվը, այնքան **շատ** IP հասցեներ կան ցանցում:

---

## 🔢 2. CIDR-ի Աշխատանքի Մեխանիզմը և Օրինակներ

### 📊 CIDR Prefix-ների Համեմատական Աղյուսակ

| CIDR Prefix | Host Bits          | Հասանելի IP-ներ (Ընդհանուր) | AWS Subnet-ում Օգտագործելի IP-ներ | Օգտագործման դեպք (AWS-ում)                          |
| :---------- | :----------------- | :-------------------------- | :-------------------------------- | 
| `/16`       | 16 bits ($2^{16}$) | **65,536**                  | 65,531                            | VPC-ի ստանդարտ չափս (Մեծ/Միջին կազմակերպություններ) |
| `/20`       | 12 bits ($2^{12}$) | **4,096**                   | 4,091                             | Խոշոր Subnet-ներ կամ Large VPC                      |
| `/24`       | 8 bits ($2^{8}$)   | **256**                     | **251**                           | Standard Subnet-ի չափս (Web, App, DB tiers)         |
| `/28`       | 4 bits ($2^{4}$)   | **16**                      | **11**                            | AWS VPC CIDR/Subnet-ի մինիմալ թույլատրելի չափսը     |
| `/32`       | 0 bits ($2^{0}$)   | **1**                       | 1                                 | Մեկ կոնկրետ IP (օրինակ՝ Security Group Rule-ում)    |

---

### 🧮 Ինչպես է հաշվարկվում CIDR-ը (Գործնական օրինակներ)

#### 1️⃣ Օրինակ 1: VPC CIDR `10.0.0.0/16`

- **Prefix:** `/16` $\rightarrow 32 - 16 = 16$ բիթ host-երի համար։
- **IP-ների քանակ:** $2^{16} = 65,536$ IP հասցե։
- **Տիրույթ (Range):** `10.0.0.0`-ից մինչև `10.0.255.255`
  - `10.0.0.0` - Network Address
  - `10.0.255.255` - Broadcast Address

#### 2️⃣ Օրինակ 2: Subnet CIDR `10.0.1.0/24`

- **Prefix:** `/24` $\rightarrow 32 - 24 = 8$ բիթ host-երի համար։
- **IP-ների քանակ:** $2^{8} = 256$ IP հասցե։
- **Տիրույթ (Range):** `10.0.1.0`-ից մինչև `10.0.1.255`

---

### ⚠️ AWS Subnet Reserved IP Addresses (Կարևոր Յուրահատկություն)

AWS-ում յուրաքանչյուր Subnet-ից **5 IP հասցե** ռեզերվացվում է AWS-ի կողմից ներքին ցանցային ֆունկցիաների համար։
Եթե դուք ստեղծում եք `/24` Subnet (256 IP), ապա ձեզ հասանելի է լինելու **251 IP**:

**Օրինակ՝ `10.0.1.0/24` Subnet-ի համար ռեզերվացված IP-ները.**

1. `10.0.1.0` - **Network Address** (Ցանցային հասցե)
2. `10.0.1.1` - **VPC Router** (AWS VPC-ի ներքին երթուղղիչ)
3. `10.0.1.2` - **AWS DNS Server** (AmazonProvidedDNS)
4. `10.0.1.3` - **Future Use** (Ապագա ընդլայնումների համար)
5. `10.0.1.255` - **Network Broadcast Address** (AWS-ը broadcast չի աջակցում, բայց հասցեն ռեզերվացված է)

---

## 📐 3. VPC Ճարտարապետություն & CIDR Պլանավորում (Best Practices)

### 🏢 RFC 1918 Private IP Ranges (VPC-ի համար)

AWS VPC-ի համար խորհուրդ է տրվում օգտագործել RFC 1918 մասնավոր IP տիրույթներից մեկը.

- `10.0.0.0/8` (օրինակ՝ `10.0.0.0/16`)
- `172.16.0.0/12` (օրինակ՝ `172.16.0.0/16`)
- `192.168.0.0/16` (օրինակ՝ `192.168.1.0/24`)

> 💡 **AWS VPC Սահմանափակումներ:**
>
> - VPC-ի ամենամեծ CIDR չափսը՝ `/16` (65,536 IP)
> - VPC-ի ամենափոքր CIDR չափսը՝ `/28` (16 IP)

---

### 🏗️ Production VPC-ի Օրինակ (Multi-AZ Architecture)

Ենթադրենք ստեղծում ենք Production VPC `10.0.0.0/16` CIDR-ով `us-east-1` Region-ում (2 Availability Zone-երով՝ `us-east-1a` և `us-east-1b`)։

```
+-----------------------------------------------------------------------------------+
| AWS Cloud - Region: us-east-1                                                     |
| VPC: 10.0.0.0/16 (65,536 IPs)                                                     |
|                                                                                   |
|  +-------------------------------------+   +-----------------------------------+  |
|  | Availability Zone: us-east-1a       |   | Availability Zone: us-east-1b     |  |
|  |                                     |   |                                   |  |
|  | [Public Subnet 1]                   |   | [Public Subnet 2]                 |  |
|  | CIDR: 10.0.1.0/24 (251 IPs)         |   | CIDR: 10.0.2.0/24 (251 IPs)       |  |
|  | (ALB, Bastion Host, NAT Gateway)    |   | (ALB, Bastion Host)               |  |
|  +-------------------------------------+   +-----------------------------------+  |
|                                                                                   |
|  +-------------------------------------+   +-----------------------------------+  |
|  | [Private App Subnet 1]              |   | [Private App Subnet 2]            |  |
|  | CIDR: 10.0.11.0/24 (251 IPs)        |   | CIDR: 10.0.12.0/24 (251 IPs)      |  |
|  | (Backend APIs, Microservices)       |   | (Backend APIs, Microservices)     |  |
|  +-------------------------------------+   +-----------------------------------+  |
|                                                                                   |
|  +-------------------------------------+   +-----------------------------------+  |
|  | [Private DB Subnet 1]               |   | [Private DB Subnet 2]             |  |
|  | CIDR: 10.0.21.0/24 (251 IPs)        |   | CIDR: 10.0.22.0/24 (251 IPs)      |  |
|  | (RDS PostgreSQL, Redis Cache)       |   | (RDS Replica, ElastiCache)        |  |
|  +-------------------------------------+   +-----------------------------------+  |
+-----------------------------------------------------------------------------------+
```

#### CIDR-ների բաշխվածությունը Subnet-ների միջև.

1. **Public Subnet 1 (AZ1):** `10.0.1.0/24` (10.0.1.0 - 10.0.1.255)
2. **Public Subnet 2 (AZ2):** `10.0.2.0/24` (10.0.2.0 - 10.0.2.255)
3. **Private App Subnet 1 (AZ1):** `10.0.11.0/24` (10.0.11.0 - 10.0.11.255)
4. **Private App Subnet 2 (AZ2):** `10.0.12.0/24` (10.0.12.0 - 10.0.12.255)
5. **Private DB Subnet 1 (AZ1):** `10.0.21.0/24` (10.0.21.0 - 10.0.21.255)
6. **Private DB Subnet 2 (AZ2):** `10.0.22.0/24` (10.0.22.0 - 10.0.22.255)

> ⚠️ **Կարևոր Խորհուրդ (VPC Peering/VPN):** Եթե պլանավորում եք ապագայում միացնել տարբեր VPC-ներ իրար (VPC Peering) կամ ձեր օֆիսի/մոդեմի ցանցին (Site-to-Site VPN), **ԵՐԲԵՔ մի օգտագործեք նույն CIDR-ները** (overlapping CIDR-ներ)։ Օրինակ՝ Dev VPC-ն սարքեք `10.1.0.0/16`, Prod VPC-ն՝ `10.2.0.0/16`:

---

## 🛠️ 4. Ինչպես ստեղծել VPC & CIDR AWS-ում (Գործնական Քայլեր)

---

### 1️⃣ Տարբերակ A: AWS Management Console (GUI)

#### Step-by-Step (VPC Wizard):

1. Մտեք **AWS Management Console** -> Փնտրեք **VPC**:
2. Սեղմեք **Create VPC**:
3. Ընտրեք **VPC and more** (սա ավտոմատ կստեղծի VPC, Subnet-ներ, Route Table-ներ և Gateway-ներ)։
4. **Name tag auto-generation:** Գրեք օրինակ՝ `prod-vpc`:
5. **IPv4 CIDR block:** Գրեք `10.0.0.0/16`:
6. **Number of Availability Zones (AZs):** Ընտրեք `2`:
7. **Number of Public subnets:** Ընտրեք `2` (լինելու են `10.0.1.0/24` և `10.0.2.0/24`):
8. **Number of Private subnets:** Ընտրեք `2` (լինելու են `10.0.128.0/24` և `10.0.129.0/24`):
9. **NAT Gateways:** Ընտրեք `1 in 1 AZ` (ծախս խնայելու համար) կամ `1 per AZ` (High Availability-ի համար)։
10. Սեղմեք **Create VPC**: AWS-ը վայրկյանների ընթացքում կկառուցի ամբողջ տոպոլոգիան։

---

### 2️⃣ Տարբերակ B: Infrastructure as Code (Terraform) - _Production Standard_

Արտադրական (Production) տիրույթում VPC-ները կառուցվում են Terraform-ով.

#### `main.tf`

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. VPC Definition
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "terraform-prod-vpc"
    Environment = "production"
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "prod-igw"
  }
}

# 3. Public Subnet (10.0.1.0/24)
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "prod-public-subnet-1a"
  }
}

# 4. Private Subnet (10.0.11.0/24)
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-private-subnet-1a"
  }
}

# 5. Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "prod-public-route-table"
  }
}

# 6. Route Table Association
resource "aws_route_table_association" "public_1a_assoc" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_rt.id
}
```

---

| Հասկացություն        | Ինչ է դա                                          | AWS Օրինակ
| **VPC**              | Ձեր մասնավոր ամպային ցանցը                        | `vpc-0123456789abcdef0` (`10.0.0.0/16`)                                  |
| **CIDR Block**       | IP հասցեների տիրույթը (`IP/Prefix`)               | `10.0.0.0/16` (65,536 IP)                                                |
| **Subnet CIDR**      | VPC-ի ներսում բաժանված փոքր ցանց                  | `10.0.1.0/24` (251 հասանելի IP)                                          |
| **AWS Reserved IPs** | Յուրաքանչյուր Subnet-ից ռեզերվացվող 5 IP-ները     | `.0` (Net), `.1` (Router), `.2` (DNS), `.3` (Future), `.255` (Broadcast) |
| **Public Subnet**    | Subnet, որի Route Table-ը ունի `0.0.0.0/0` -> IGW | Վեբ սերվերներ, Load Balancer-ներ                                         |
| **Private Subnet**   | Subnet առանց ուղիղ IGW երթուղու                   | Տվյալների բազաներ (RDS), Backend APIs                                    |
