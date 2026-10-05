# ☁️ AWS Cloud Fundamentals — Deep Dive & Study Guide

> **Դասընթացի Ամփոփում:** Cost Management, Global Infrastructure, Default VPC, EC2, Security Groups, Key Pairs, և Connection Methods (SSH / Instance Connect / PuTTY):

---

## 📖 Բովանդակություն

1. [AWS Budgets & Cost Management](#1-aws-budgets--cost-management)
2. [Global Infrastructure: Regions & AZs](#2-global-infrastructure-regions--azs)
3. [The Default VPC (Virtual Private Cloud)](#3-the-default-vpc-virtual-private-cloud)
4. [Amazon EC2 (Elastic Compute Cloud)](#4-amazon-ec2-elastic-compute-cloud)
5. [Connecting to your Instance (EC2 Access Methods)](#5-connecting-to-your-instance-ec2-access-methods)
6. [❓ Հաճախ տրվող հարցազրույցի հարցեր (Interview Q&A)](#6--հաճախ-տրվող-հարցազրույցի-հարցեր-interview-qa)

---

## 💰 1. AWS Budgets & Cost Management

### 📌 Ի՞նչ է և Ինչի՞ համար է

- **Էությունը:** Ծախսերի վերահսկման, պլանավորման և ավտոմատ ծանուցումների (Alerts) համակարգ AWS-ում։
- **Նպատակը:** Կանխել անսպասելի հաշիվները (Cost Spikes), վերահսկել Free Tier-ի սահմանաչափերը և խուսափել "Cloud Billing Surprise"-ից։

### 🛠️ Key Concepts & Mechanics

- **Budget Templates:**
  - **Zero Spend Budget:** Ծանուցում է ուղարկում, երբ ծախսը գերազանցում է **$0.01**-ը (հոյակապ է Free Tier-ով աշխատողների համար)։
  - **Free Tier Budget:** Ծանուցում է, երբ մոտենում ես Free Tier-ի սահմանաչափերին (օր.՝ 80%-ին)։
  - **Monthly Cost Budget:** Սահմանում ես կոնկրետ գումար (օր.՝ $50/ամիս)։
- **Alert Types (Ծանուցման տեսակները):**
  - **Actual Spend Alert:** Ծանուցում, երբ իրականացված ծախսն _արդեն_ հասել է սահմանված %-ին (օր.՝ բյուջեի 80%-ը արդեն ծախսվել է)։
  - **Forecasted Spend Alert:** Ծանուցում, երբ AWS-ի AI/Machine Learning ալգորիթմը _կանխատեսում է_, որ մինչև ամսվա վերջ բյուջեն կգերազանցվի։
- **Գնագոյացում (Pricing):**
  - Առաջին **2 բյուջեները անվճար են**։
  - Monitoring-ը և Alerts-ը (Email/SNS) անվճար են։
  - Վճարովի են միայն **Action-enabled budgets**-ները (երբ բյուջեն գերազանցելիս AWS-ն ավտոմատ կերպով անջատում է EC2 instance-ները)։
- ⚠️ **Կարևոր նշում:** Forecasted alert-ների համար պահանջվում է մոտ 5 շաբաթվա ծախսերի պատմություն (նոր account-ներում սկզբում աշխատում են միայն Actual alert-ները)։

---

## 🌍 2. Global Infrastructure: Regions & AZs

### 📌 Ի՞նչ է և Ինչի՞ համար է

- **Էությունը:** AWS-ի աշխարհագրական ցանցի կառուցվածքը (Regions, AZs, Edge Locations):
- **Նպատակը:** Հավելվածների High Availability (HA) և Fault Tolerance (FT) ապահովումը։

### 🛠️ Regions, AZ Names, and AZ IDs

| Հասկացություն  | Օրինակ | Ի՞նչ է իրենից ներկայացնում| Կարևոր Նրբություն|
| :------------- | :-------------------------- | :-------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------ |
| **AWS Region** | `us-east-1`, `eu-central-1` | Աշխարհագրական առանձին տարածք, որը պարունակում է **նվազագույնը 3 AZ**: | Region-ները ֆիզիկապես, ցանցային և իրավական առումով անկախ են։                                                              |
| **AZ Name**    | `us-east-1a`, `us-east-1b`  | Լոկալ անվանում նույն Region-ի ներսում։                                | **Տարբեր AWS Account-ներում `us-east-1a`-ն հղվում է ՏԱՐԲԵՐ ֆիզիկական Data Center-ների** (AWS-ի load balancing-ի համար)։   |
| **AZ ID**      | `use1-az1`, `use1-az2`      | Ֆիզիկական, անփոփոխ ID:                                                | Օգտագործվում է, երբ պետք է տարբեր AWS Account-ների միջև ապահովել, որ ռեսուրսները գտնվում են _ճիշտ նույն_ Data Center-ում։ |

---

## 🌐 3. The Default VPC (Virtual Private Cloud)

### 📌 Ի՞նչ է և Ինչի՞ համար է

- **Էությունը:** AWS-ի կողմից ամեն Region-ում out-of-the-box տրամադրվող վիրտուալ ցանց։
- **Նպատակը:** Սկսնակներին թույլ տալ անմիջապես launch անել EC2 instance-ներ՝ առանց networking-ի բարդ կարգավորումների։

## 💡 VPC-ի Հիմնական Concept-ները (Quick Checklist)

- **VPC** — Քո մասնավոր «պարիսպապատ» տարածքը ամպում (Virtual Network):

- **CIDR** — IP հասցեների բլոկը (օր.՝10.0.0.0/16`):

- **Subnet** — VPC-ի ներսում IP-ների ենթատիրույթ (Public = ունի route դեպի IGW, Private = չունի):

- **Internet Gateway (IGW)** — Դուռ դեպի արտաքին ինտերնետ (Public Subnet-ի համար):

- **NAT Gateway** — «Միակողմանի փական» Private Subnet-ի համար (ելք դեպի ինտերնետ կա, մուտք դրսից՝ ոչ):

- **Route Table** — Երթուղային քարտեզ (ով ուր կարող է գնալ):

- **Security Group vs NACL** — SG-ն աշխատում է EC2 Instance-ի մակարդակով (Stateful), իսկ NACL-ը՝ Subnet-ի մակարդակով (Stateless):
- **Auto-assign Public IP:** Default Subnet-ներում ստեղծված EC2-ները ավտոմատ ստանում են Public IP հասցե։
- 🛠️ **Management:** Եթե պատահաբար ջնջես Default VPC-ն, այն կարող ես վերասկսել VPC Dashboard-ից՝ `Actions -> Create Default VPC`:

---

## 💻 4. Amazon EC2 (Elastic Compute Cloud)

### 📌 Ի՞նչ է և Ինչի՞ համար է

- **Էությունը:** AWS-ի վիրտուալ սերվերները (IaaS — Infrastructure as a Service)։
- **Նպատակը:** Web application-ներ, backend API-ներ կամ computation-ներ աշխատեցնելու համար։

### 🛠️ Launch Steps & Key Concepts

1. **AMI (Amazon Machine Image):** Սերվերի "Template"-ն է (Օպերացիոն համակարգը, օր․՝ Amazon Linux 2023, Ubuntu, Windows Server):
2. **Instance Type (օր.՝ `t3.micro`):**
   - **`t`** -> Instance Family (General Purpose, Burstable)
   - **`3`** -> Generation (3-րդ սերունդ)
   - **`micro`** -> Size (1 vCPU, 1 GiB RAM)
3. **Security Group (Virtual Firewall):**
   - **Stateful** է (եթե Inbound-ով թույլատրված է, Outbound պատասխանը ավտոմատ անցնում է)։
   - Default-ով բոլոր Inbound (մուտքային) հարցումները արգելափակված են, իսկ Outbound-ը՝ թույլատրված։
   - SSH-ով միանալու համար պետք է բացել **Port 22**-ը։
4. **Key Pair (Asymmetric Encryption):**
   - **Public Key:** AWS-ը պահում է EC2 սերվերի ներսում (`~/.ssh/authorized_keys`):
   - **Private Key (`.pem` / `.ppk`):** Ներբեռնում ես քո համակարգչում (այլևս հնարավոր չէ կրկին ներբեռնել AWS-ից)։

---

## 🔌 5. Connecting to your Instance (EC2 Access Methods)

### 1️⃣ EC2 Instance Connect (Browser Terminal) — _Ամենաարագը_

- **Ինչպես է աշխատում:** AWS Console-ից browser-ի միջոցով մուտք Terminal:
- **Պահանջներ:**
  - EC2-ը պետք է լինի Public Subnet-ում և ունենա Public IP:
  - Security Group-ում **Port 22 (SSH)**-ը պետք է բաց լինի EC2 Instance Connect Service IP-ների համար։
- **Առավելություն:** Չի պահանջում local SSH key-եր պահպանել։

### 2️⃣ Native SSH Client (macOS, Linux, Windows PowerShell)

1. Պահպանիր `.pem` ֆայլը քո համակարգչում։
2. **Permissions (Կարևոր step):** Linux/macOS-ում SSH-ը չի աշխատի, եթե key-ի ֆայլի իրավունքները չափից շատ բաց են։
   ```bash
   chmod 400 your-key.pem
   ```
3. **Connect Command:**
   ```bash
   ssh -i "your-key.pem" ec2-user@<YOUR-EC2-PUBLIC-IP>
   ```
   _(Նշում: Ubuntu-ի համար username-ը `ubuntu` է, Amazon Linux-ի համար՝ `ec2-user`):_

### 3️⃣ Windows Users: PuTTY Connection

- **Ինչու PuTTY:** PuTTY-ն չի ճանաչում AWS-ի `.pem` ֆորմատը, ուստի պահանջում է `.ppk` (PuTTY Private Key):
- **Step 1: Convert Key (PuTTYgen)**
  - Բացիր **PuTTYgen** -> `Conversions` -> `Import Key` -> Ընտրիր `.pem` ֆայլը։
  - Սեղմիր `Save private key` -> Պահպանիր որպես `.ppk` ֆայլ։
- **Step 2: Connect (PuTTY)**
  - Host Name: `ec2-user@<YOUR-EC2-PUBLIC-IP>`
  - Port: `22`
  - Nav: `Connection` -> `SSH` -> `Auth` -> `Credentials` -> Browse `.ppk` ֆայլը։
  - Սեղմիր `Open`:

---

## 6. ❓ Հաճախ տրվող հարցազրույցի հարցեր (Interview Q&A)

### Q1: Ի՞նչ տարբերություն AZ Name-ի (`us-east-1a`) և AZ ID-ի (`use1-az1`) միջև։

**Պատասխան:** AZ Name-ը (`us-east-1a`) տրամաբանական անվանում է, որը տարբեր AWS Account-ներում կարող է հղվել տարբեր ֆիզիկական Data Center-ների։ AZ ID-ն (`use1-az1`) ֆիզիկական անփոփոխ ID-ն է, որը նույնն է բոլոր AWS Account-ների համար։

### Q2: Ի՞նչ կլինի, եթե կորցնեմ EC2 Key Pair-ի `.pem` ֆայլը։

**Պատասխան:** AWS-ը չի պահում Private Key-ի պատճենը։ Սերվեր մուտք գործելու համար պետք է օգտագործել EC2 Instance Connect (եթե կարգավորված է), Systems Manager Session Manager, կամ stop անել EC2-ը, EBS volume-ը կցել մեկ այլ EC2-ի և փոխել `authorized_keys` ֆայլը։

### Q3: Արդյո՞ք Security Group-ը Stateful է, թե՞ Stateless:

**Պատասխան:** Security Group-ը **Stateful** է։ Եթե Inbound rule-ով թույլատրում ես traffic-ը (օր.՝ Port 80), ապա Outbound response-ը ավտոմատ կերպով թույլատրվում է՝ անկախ Outbound rule-երից։

### Q4: Ո՞րն է Default VPC-ի հիմնական առավելությունը։

**Պատասխան:** Այն թույլ է տալիս արագ սկսել աշխատանքը EC2-ների հետ, քանի որ արդեն ունի կարգավորված Public Subnet-ներ, Internet Gateway և Route Table:
