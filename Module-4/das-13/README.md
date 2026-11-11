## Firewalls & NAT

# 1. Firewall-ի գաղափարը

**Firewall-ը** անվտանգության մեխանիզմ է, որը վերահսկում է ցանցային
traffic-ը և որոշում՝ թույլատրել այն, թե արգելել։

Պատկերացրու, որ ունես գրասենյակ։

- Inbound traffic --- մարդիկ, որոնք փորձում են մտնել գրասենյակ։
- Outbound traffic --- մարդիկ, որոնք դուրս են գալիս գրասենյակից։
- Firewall --- անվտանգության աշխատակիցը, որը ստուգում է՝ ով կարող է
  ներս մտնել կամ դուրս գալ։
- Port --- մուտքի կոնկրետ դուռը։
- Protocol --- հաղորդակցության տեսակը։

### 📥 Inbound vs Outbound

Inbound Traffic, որը գալիս է Browser-ը միանում է
դեպի քո server-ը EC2-ին՝ TCP 443-ով

Outbound Traffic, որը դուրս է EC2-ն հարցում է
գալիս քո server-ից ուղարկում արտաքին
API-ին՝ TCP 443-ով

---

### 🧠 Հիշելու պարզ տարբերակ

- **Security Group** --- պաշտպանում է կոնկրետ սերվերը։
- **NACL** --- պաշտպանում է ամբողջ subnet-ը։
- **AWS Network Firewall** --- ստուգում և զտում է VPC-ի միջով անցնող
  network traffic-ը։
- **AWS WAF** --- պաշտպանում է վեբ հավելվածը վնասակար HTTP/HTTPS
  հարցումներից։

---

# 3. Security Group (SG) --- Instance-ի Firewall-ը

**Security Group-ը AWS-ի Virtual Firewall-ն է**, որը կցվում է EC2
instance-ին կամ նրա Elastic Network Interface-ին (ENI)։

Այն որոշում է՝ ինչ inbound և outbound traffic է թույլատրվում։

### ⚠️ Default Security Group

- Inbound --- թույլատրում է traffic նույն Security Group-ին պատկանող
  resource-ներից։
- Outbound --- թույլատրում է բոլոր outbound traffic-ը։

> 📌 **Security Group-ը չունի Deny rule։** Եթե traffic-ը չի
> համապատասխանում որևէ Allow rule-ի, այն չի թույլատրվում։

---

# 4. Network ACL (NACL) --- Subnet-ի Firewall-ը

**Network ACL-ը subnet մակարդակի firewall է**։ Այն վերահսկում է subnet մտնող և դուրս եկող traffic-ը։

Եթե Security Group-ը պաշտպանում է EC2-ը, ապա NACL-ը կիրառվում է subnet-ի ամբողջ traffic-ի նկատմամբ։

### ⚙️ NACL-ի հիմնական հատկությունները

1.  **Stateless է** --- չի հիշում կապի վիճակը։
2.  Աջակցում է և՛ **Allow**, և՛ **Deny** կանոններին։
3.  Կանոնները ստուգվում են Rule Number-ի աճման հերթականությամբ։
4.  Առաջին համապատասխան կանոնը որոշում է՝ traffic-ը թույլատրվո՞ւմ է, թե՞
    արգելվում։
5.  Յուրաքանչյուր subnet կապված է մեկ NACL-ի հետ։
6.  Նոր custom NACL ստեղծելիս սկզբնական կանոնները պետք է կարգավորել ըստ
    պահանջի։

### Օրինակ --- NACL Rules

    Rule Number Type            Port Source              Action

            100 HTTP              80 `0.0.0.0/0`         ALLOW
            110 HTTPS            443 `0.0.0.0/0`         ALLOW
            120 SSH               22 `203.0.113.10/32`   ALLOW
            200 All traffic      All `0.0.0.0/0`         DENY
            `*` All traffic      All `0.0.0.0/0`         DENY

Սա միայն **Inbound Rules**-ի օրինակ է։ Outbound Rules-ը պետք է առանձին սահմանել։

### Default NACL vs Custom NACL

Default NACL Թույլատրում է բոլոր inbound և outbound traffic-ը

Custom NACL Սկզբնական շրջանում արգելում է traffic-ը, մինչև կանոններ ավելացվեն

---

---

# 5. Stateful vs Stateless

Սա Security Group-ի և NACL-ի ամենակարևոր տարբերությունն է։

### 🧠 Stateful --- Security Group

Stateful firewall-ը հիշում է արդեն հաստատված կապի վիճակը։

Օրինակ՝ EC2-ն հարցում է ուղարկում արտաքին API-ին՝ HTTPS `443` port-ով։

```text
EC2: 10.0.2.10:50000
          |
          | Outbound HTTPS request
          v
API: 203.0.113.50:443
          |
          | Response
          v
EC2: 10.0.2.10:50000
```

Եթե Security Group-ը թույլատրել է outbound հարցումը, նույն կապի
վերադարձող պատասխանը ավտոմատ թույլատրվում է։

Առանձին inbound rule ավելացնելու կարիք չկա միայն այդ պատասխանը ստանալու
համար։

### 🧠 Stateless --- Network ACL

NACL-ը չի հիշում կապի վիճակը։

Պետք է առանձին թույլատրել՝

- Outbound request-ը։
- Inbound response-ը։

# 7. NAT --- Network Address Translation

**NAT-ը նշանակում է Network Address Translation**՝ ցանցային հասցեների
փոխակերպում։

AWS-ում NAT Gateway-ի հիմնական նպատակներից մեկն է՝ թույլ տալ Private
Subnet-ում գտնվող EC2 instance-ին ինտերնետից օգտվել՝ առանց նրան Public
IP տալու։

### 🤔 Ինչու է NAT անհրաժեշտ

Ենթադրենք ունենք Private EC2՝

```text
Private IP: 10.20.2.41
Public IP:  ՉԿԱ
```

Այդ EC2-ն պետք է՝

- ներբեռնի Linux package update-ներ,
- միանա արտաքին API-ին,
- ներբեռնի ծրագրային dependency-ներ,
- կապ հաստատի արտաքին repository-ի հետ։

Բայց այն չունի Public IP և ուղիղ Internet Gateway route չունի։

Այս խնդիրը լուծում է NAT Gateway-ը։

### 🔄 Ինչպես է աշխատում NAT Gateway-ը

```text
Private EC2
10.20.2.41
     |
     | 1. Outbound request
     v
NAT Gateway
Elastic IP: 3.x.x.x
     |
     v
Internet Gateway
     |
     v
INTERNET
```

Քայլերով՝

1.  Private EC2-ն ուղարկում է հարցում դեպի արտաքին server։
2.  Հարցումը հասնում է NAT Gateway-ին։
3.  NAT Gateway-ը փոխակերպում է source IP-ն՝ օգտագործելով իր public
    կողմի հասցեն։
4.  Հարցումը հասնում է ինտերնետ։
5.  Արտաքին server-ը պատասխանում է NAT Gateway-ին։
6.  NAT Gateway-ը պատասխանը փոխանցում է սկզբնական Private EC2-ին։

### ⚠️ NAT-ը Firewall չէ

NAT-ի հիմնական գործառույթը հասցեների փոխակերպումն է, ոչ թե firewall
կանոնների ամբողջական փոխարինումը։

- NAT Gateway-ը թույլ է տալիս Private EC2-ին սկսել outbound IPv4
  կապեր։
- Պատասխանները վերադառնում են նույն կապի շրջանակում։
- NAT Gateway-ը չի թույլատրում ինտերնետից սկսել նոր, unsolicited
  inbound կապ դեպի Private EC2։
- Security Group-ը և NACL-ը շարունակում են վերահսկել traffic-ը։

### Public NAT Gateway vs Private NAT Gateway

---

Public NAT Gateway Private NAT Gateway

---

Տեղադրվում է Public Subnet-ում Օգտագործվում է Private connectivity-ի համար

Ունի Elastic IP Չունի public Elastic IP

Կարող է ապահովել outbound IPv4 Ինքնուրույն ինտերնետային ելք internet access չի ապահովում

Օգտագործվում է Private Subnet-ից Օգտագործվում է այլ private ցանցերի
ինտերնետ դուրս գալու համար հետ կապի համար

---

---

# 8. Internet Gateway vs NAT Gateway

Շատ կարևոր է չշփոթել այս երկու ծառայությունները։

### 🌐 Internet Gateway (IGW)

Internet Gateway-ը VPC-ի և ինտերնետի միջև ինտերնետային connectivity ապահովող բաղադրիչն է։
Public Subnet-ի Route Table-ում սովորաբար կա՝

```text
Destination: 0.0.0.0/0
Target:      Internet Gateway
```

EC2-ն IPv4 ինտերնետից անմիջապես հասանելի լինելու համար պետք է ունենա Public IPv4 կամ Elastic IP, 
ճիշտ route և թույլատրող firewall կանոններ։

### 🔄 NAT Gateway

NAT Gateway-ը Private Subnet-ի resource-ներին թույլ է տալիս outbound IPv4 կապեր սկսել՝ առանց Public IP ունենալու։

Private Subnet-ի Route Table-ում՝

```text
Destination: 0.0.0.0/0
Target:      NAT Gateway
```

### Համեմատություն

---

IGW NAT Gateway

---

VPC-ի ինտերնետային gateway-ն է Private resource-ների outbound IPv4 connectivity:

Կցվում է VPC-ին Ստեղծվում է կոնկրետ Subnet-ում:

Public subnet-ի route target է Private subnet-ի route target է

EC2-ին պետք է public IPv4՝ Private EC2-ին public IPv4 պետք չէ անմիջական IPv4 ինտերնետային հասանելիության համար

Չի փոխարինում Security Group-ին Չի փոխարինում Security Group-ին

---

> 💡 **Հիշելու ձև․** IGW-ը VPC-ի դուռն է դեպի ինտերնետ, իսկ NAT Gateway-ը private սերվերի միջնորդն է՝ 
                      արտաքին կապեր սկսելու համար։

---

# 9. Public և Private Subnet-ների ճարտարապետություն

Public Subnet `10.20.1.0/24` NAT Gateway, Load
Balancer, public
resources

Private Subnet `10.20.2.0/24` Application Server,
Backend, Database

---

### Public Subnet

Public Subnet-ի Route Table-ում կա՝

```text
10.20.0.0/16 -> local
0.0.0.0/0    -> IGW
```

Այն ունի ուղիղ route դեպի Internet Gateway։

### Private Subnet

Private Subnet-ի Route Table-ում կա՝

```text
10.20.0.0/16 -> local
0.0.0.0/0    -> NAT Gateway
```

Այն ինտերնետ է դուրս գալիս NAT Gateway-ի միջոցով։

- Load Balancer-ը public subnet-ներում է։
- Backend/Application server-ները private subnet-ներում են։
- Database-ը private subnet-ներում է։
- Backend-ը անհրաժեշտության դեպքում NAT Gateway-ով դուրս է գալիս
  ինտերնետ։
- Database-ին սովորաբար outbound internet access պետք չէ։

### ⚠️ Կարևոր ճշտում

Subnet-ը public կամ private է դառնում հիմնականում իր Route Table-ի
route-երի հիման վրա, ոչ թե անվան։

Միայն `0.0.0.0/0 -> IGW` route ունենալը բավարար չէ EC2-ին անմիջապես
ինտերնետից հասանելի դարձնելու համար․ պետք են նաև public IPv4/EIP և
թույլատրող firewall կանոններ։

---

# 12. Հարցազրույցի Cheat Sheet

### Ամենակարևոր հարցերն ու պատասխանները

**1. Ի՞նչ է Firewall-ը։**

Firewall-ը մեխանիզմ է, որը վերահսկում է network traffic-ը և թույլատրում
կամ արգելում է կապերը սահմանված կանոնների հիման վրա։

**2. Ի՞նչ է Security Group-ը։**

AWS-ի Stateful Virtual Firewall է, որը կցվում է EC2 instance-ին կամ
ENI-ին և վերահսկում է inbound/outbound traffic-ը։

**3. Ի՞նչ է NACL-ը։**

Subnet մակարդակի Stateless firewall է, որն ունի Allow և Deny կանոններ։

**4. Ո՞րն է SG-ի և NACL-ի տարբերությունը։**

SG-ն գործում է resource մակարդակում և Stateful է։ NACL-ը գործում է
subnet մակարդակում և Stateless է։

**5. Ի՞նչ է NAT-ը։**

Network Address Translation՝ IP հասցեների փոխակերպում։

**6. Ինչո՞ւ է պետք NAT Gateway։**

Private Subnet-ի resource-ներին թույլ տալու outbound IPv4 կապեր հաստատել
ինտերնետի հետ՝ առանց Public IP ունենալու։

**7. NAT Gateway-ը կարո՞ղ է փոխարինել Firewall-ին։**

Ոչ։ NAT-ը հասցեների փոխակերպման ծառայություն է և չի փոխարինում SG/NACL
կանոններին։

**8. Որտե՞ղ է տեղադրվում Public NAT Gateway-ը։**

Public Subnet-ում՝ Elastic IP-ով։

**9. Ի՞նչ է Stateful-ը։**

Firewall-ը հիշում է կապի վիճակը և թույլատրում է նույն կապի վերադարձող
traffic-ը։

**10. Ի՞նչ է Stateless-ը։**

Firewall-ը չի հիշում կապի վիճակը, հետևաբար երկու ուղղությունների
կանոնները պետք է առանձին սահմանել։

**11. Ինչո՞ւ Database-ը պետք է լինի Private Subnet-ում։**

Որպեսզի այն անմիջապես հասանելի չլինի ինտերնետից։ Մուտքը պետք է
սահմանափակվի միայն անհրաժեշտ application resource-ներով։

**12. Ինչո՞վ են տարբերվում AWS WAF-ը և Network Firewall-ը։**

WAF-ը պաշտպանում է web request-ները, իսկ Network Firewall-ը վերահսկում է
network traffic-ը։

---