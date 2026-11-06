# 🌍 AWS Global Infrastructure — Availability Zones (AZ) & Regions

> **Availability Zone (AZ)** — AWS-ի Region-ում գտնվող մեկ կամ մի քանի ֆիզիկապես առանձնացված **Data Center**-ներ են, որոնք ունեն ինքնավար էլեկտրասնուցում (power), հովացում (cooling), ցանցային կապ (networking) և բարձր հասանելիություն (connectivity):

---

## 📌 1. AWS Global Infrastructure-ի Կառուցվածքը

AWS-ի աշխարհագրական ենթակառուցվածքը բաժանվում է 3 հիմնական մակարդակի.

AWS Global Infrastructure
├── Regions (օր.՝ us-east-1, eu-central-1)
│ ├── Availability Zone A (օր.՝ us-east-1a) -> [Data Center 1] [Data Center 2]
│ ├── Availability Zone B (օր.՝ us-east-1b) -> [Data Center 3]
│ └── Availability Zone C (օր.՝ us-east-1c) -> [Data Center 4]
└── Edge Locations / CloudFront PoPs (CDN & Caching)

## 🏛 Regions vs. Availability Zones (AZ)

| Հասկացություն              | Անվանում (Naming)                                       | Ինչ է իրենից ներկայացնում                                                 | Հեռավորություն և Կապ                                                                           |
| :------------------------- | :------------------------------------------------------ | :------------------------------------------------------------------------ | :--------------------------------------------------------------------------------------------- |
| **AWS Region**             | `us-east-1` (N. Virginia)<br>`eu-central-1` (Frankfurt) | Աշխարհագրական առանձին տարածաշրջան, որը պարունակում է մի քանի AZ-ներ:      | Region-ները ֆիզիկապես, ցանցային առումով և իրավականորեն լիովին **անկախ են** միմյանցից:          |
| **Availability Zone (AZ)** | `us-east-1a`<br>`us-east-1b`                            | Մեկ կամ մի քանի ֆիզիկական Data Center-ների խումբ՝ նույն Region-ի ներսում: | AZ-ները միմյանց հետ կապված են **high-bandwidth, ultra-low latency** օպտիկամանրաթելային ցանցով: |

## 🛡️ 3. Ինչու՞ են անհրաժեշտ AZ-ները (Key Benefits)

1. **High Availability (HA) — Բարձր հասանելիություն**
   - Հավելվածը/սերվերները տեղակայելով մի քանի AZ-ներում (Multi-AZ)՝ ապահովում ենք անխափան աշխատանք։
2. **Fault Tolerance (FT) — Խափանակայունություն**
   - Եթե մեկ AZ-ում տեղի ունենա հոսանքազրկում, ջրհեղեղ կամ ապարատային վթար, մյուս AZ-ները շարունակում են աշխատել առանց ընդհատման։
3. **Low Latency Redundancy**
   - AZ-ների միջև latency-ն շատ ցածր է (< 2ms), ինչը թույլ է տալիս իրականացնել տվյալների synchronous replication (օր.՝ Multi-AZ RDS):

---

## ⚙️ 4. Multi-AZ Architecture (DevOps Perspective)

DevOps-ում production ենթակառուցվածք նախագծելիս ոսկե կանոն է **միշտ օգտագործել Multi-AZ**:

- **Compute (EC2 / EKS):** EC2 instance-ները կամ Kubernetes pod-երը բաշխել առնվազն 2 AZ-ների միջև Load Balancer-ի (ALB) հետևում։
- **Database (RDS):** Մեկ AZ-ում Primary DB-ն է, իսկ մյուս AZ-ում՝ Standby Replica-ն (վթարի դեպքում ավտոմատ կատարվում է Failover):
- **Networking (VPC Subnets):** VPC-ում ստեղծվում են Public/Private Subnet-ներ ամեն AZ-ի համար առանձին։

---

## ⚡ 5. Additional Global Concepts

- **Edge Locations (CloudFront):**
  - AWS-ի Global Network-ի մաս կազմող հարյուրավոր կետեր աշխարհով մեկ, որոնք օգտագործվում են static content-ի caching-ի (CDN) և Latency-ն նվազեցնելու համար։
- **AZ ID vs. AZ Name:**
  - `us-east-1a`-ն տարբեր AWS Account-ների համար կարող է մատնանշել տարբեր ֆիզիկական Data Center-ներ (AWS-ը randomization է անում load-ը հավասարակշռելու համար)։ Exact ֆիզիկական AZ-ն identificator-ով է որոշվում (օր.՝ `use1-az1`):

---

## 🎯 6. Best Practices & Cheat Sheet

1. **Never Single-AZ in Production:** Production միջավայրերը երբեք չպետք է կախված լինեն միայն մեկ AZ-ից։
2. **Data Residency & Compliance:** Region ընտրելիս հաշվի առնել օրենսդրական պահանջները (օր.՝ GDPR Եվրոպայում) և latency-ն օգտատերերին մոտ լինելու տեսանկյունից։
3. **Data Transfer Costs:** Նույն AZ-ի ներսում տվյալների փոխանցումն անվճար է, իսկ տարբեր AZ-ների կամ Region-ների միջև տվյալների փոխանցումը (Data Transfer) ունի լրացուցիչ արժեք։
