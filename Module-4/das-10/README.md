# 🌐 Ցանցային հիմունքներ (Networking Fundamentals)

Այս ուղեցույցը բացատրում է համակարգչային ցանցերի հիմնական հասկացությունները՝ OSI մոդել, TCP/UDP արձանագրություններ, IP հասցեավորում և CIDR հիմունքներ։

---

## 📚 1. OSI Մոդել (OSI Model)

OSI (Open Systems Interconnection) մոդելը նկարագրում է ցանցային հաղորդակցության 7 շերտերը (Layers).

1. **Layer 7 - Application (Կիրառական):** HTTP, HTTPS, SSH, FTP, DNS (Օգտատիրոջ ինտերֆեյսին մոտ շերտ)։
2. **Layer 6 - Presentation (Ներկայացման):** Տվյալների վերծանում/գաղտնագրում (Encryption/Decryption), SSL/TLS, JSON/XML:
3. **Layer 5 - Session (Սեսիայի):** Հաղորդակցման սեսիայի կառավարում (RPC, NetBIOS):
4. **Layer 4 - Transport (Տրանսպորտային):** Տվյալների փոխանցում հանգույցների միջև՝ **TCP** (հուսալի) և **UDP** (արագ) արձանագրություններ, Port-եր (օր.՝ Port 80, 443, 22, 53)։
5. **Layer 3 - Network (Ցանցային):** Երթուղավորում (Routing), **IP հասցեավորում** (IPv4, IPv6), Router-ներ։
6. **Layer 2 - Data Link (Կապուղային):** Տվյալների կադրեր (Frames), **MAC հասցեներ**, Switch-եր։
7. **Layer 1 - Physical (Ֆիզիկական):** Էլեկտրական ազդանշաններ, մալուխներ (Ethernet), Wi-Fi:

---

## 🔄 2. TCP vs UDP (Layer 4 Protocols)

OSI-ի 4-րդ (Transport) շերտում հիմնական աշխատող արձանագրություններն են **TCP**-ն և **UDP**-ն։

### 🤝 TCP (Transmission Control Protocol)

- **Connection-oriented:** Նախքան տվյալներ ուղարկելը հաստատում է կապ (3-Way Handshake: SYN -> SYN-ACK -> ACK):
- **Հուսալիություն:** Երաշխավորում է, որ բոլոր փաթեթները կհասնեն ճիշտ հերթականությամբ։
- **Օգտագործման ոլորտներ:** Web (HTTP/HTTPS - Port 80/443), SSH (Port 22), Database (PostgreSQL - 5432, MySQL - 3306), Email:

### 🚀 UDP (User Datagram Protocol)

- **Connectionless:** Տվյալներն ուղարկվում են առանց նախնական միացման սպասելու։
- **Անհուսալի, բայց արագ:** Չի երաշխավորում հասնելը, չկա լրացուցիչ overhead:
- **Օգտագործման ոլորտներ:** Streaming (Video/Audio), Online Gaming, DNS (Port 53), VoIP (Zoom, Skype):

| Հատկանիշ                 | TCP                                   | UDP                             |
| :----------------------- | :------------------------------------ | :------------------------------ |
| **Միացում (Connection)** | Connection-oriented (3-way handshake) | Connectionless                  |
| **Արագություն**          | Ավելի դանդաղ                          | Շատ արագ                        |
| **Հուսալիություն**       | Բարձր (երաշխավորված հերթականություն)  | Ցածր (կարող են փաթեթներ կորչել) |
| **Header-ի չափսը**       | 20 Bytes                              | 8 Bytes                         |

---

## 🌍 3. IP Հասցեներ (IPv4 Addresses)

- **IPv4 կառուցվածք:** 32 բիթանոց հասցե, որը բաժանված է 4 օկտետների (0-255, օր.՝ `192.168.10.5`):
- **Մաքսիմում քանակ:** $2^{32} \approx 4.3$ միլիարդ հասցե։

### 🔒 Private vs 🌐 Public IP-ներ

- **Private IP (Մասնավոր):** Օգտագործվում է ներքին ցանցերում (LAN, VPC)։ Ինտերնետից ուղղակիորեն հասանելի չէ։
  - `10.0.0.0/8`
  - `172.16.0.0/12`
  - `192.168.0.0/16`
- **Public IP (Հանրային):** Գլոբալ ունիկալ IP հասցե Ինտերնետում միանալու համար։

---

## 📏 4. CIDR (Classless Inter-Domain Routing)

CIDR-ը մեթոդ է, որով սահմանվում է IP հասցեների տիրույթը՝ օգտագործելով `/` նշանը (Prefix length)։

- `/32` $\rightarrow$ 1 IP (`203.0.113.10/32`)
- `/24` $\rightarrow$ 256 IP (`192.168.1.0/24` -ից `192.168.1.255`)
- `/16` $\rightarrow$ 65,536 IP (`10.0.0.0/16` -ից `10.0.255.255`)

> 💡 **Կանոն:** Ինչքան **փոքր** է prefix-ի թիվը (օր. `/16`), այնքան **շատ** IP հասցեներ կան ցանցում:

---

## ☁️ 5. AWS Load Balancers & Layer 4/7

- **ALB (Application Load Balancer):** Ուղղորդում է տրաֆիկը Layer 7 մակարդակում (HTTP/HTTPS, վեբ հավելվածների համար)։
- **NLB (Network Load Balancer):** Ուղղորդում է տրաֆիկը Layer 4 մակարդակում (TCP, UDP, TLS)՝ ապահովելով գերարագ աշխատանք և միլիոնավոր request-ներ/վրկ։

---

## 🛠️ 6. Ինչ գործիքներով կարող եք կատարել/կառավարել AWS-ում

AWS-ում ցանց ստեղծելու, կարգավորելու և դրանց միանալու համար օգտագործվում են հետևյալ հիմնական գործիքները.

### 1. AWS Management Console (GUI)

- Վեբ ինտերֆեյս AWS-ի պաշտոնական կայքում։
- Հարմար է սկսնակների, թեստավորման և ցանցային տոպոլոգիան վիզուալ հասկանալու համար (օրինակ՝ VPC Wizard-ի միջոցով սերվերներ ստեղծելիս)։

### 2. AWS CLI (Command Line Interface)

- Հրամանային տողի գործիք՝ ավտոմատացման և արագ կառավարման համար։
- **Օրինակներ:**

  ```bash
  # Ստեղծել VPC `10.0.0.0/16` CIDR-ով
  aws ec2 create-vpc --cidr-block 10.0.0.0/16

  # Ստեղծել Subnet VPC-ի ներսում
  aws ec2 create-subnet --vpc-id vpc-12345678 --cidr-block 10.0.1.0/24

  # Նայել առկա Security Group-ները
  aws ec2 describe-security-groups
  ```

## 3. IaC (Infrastructure as Code) - Ամենատարածված արտադրական (Production) տարբերակը

🅰️ Terraform (HashiCorp)
Ամենապոպուլյար cross-cloud գործիքն է՝ VPC, Subnet-ներ, Security Group-ներ (TCP/UDP կանոններով) և CIDR բլոկներ կառուցելու համար։

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "My-Production-VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# TCP Security Group-ի օրինակ
resource "aws_security_group" "web_sg" {
  name   = "web-server-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}