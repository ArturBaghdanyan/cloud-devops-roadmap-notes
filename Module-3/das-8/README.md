# 🔒 Module 3: AWS S3 Security — Bucket Policies & Block Public Access

Այս դասի ընթացքում դուք կսովորեք Amazon S3 (Simple Storage Service) անվտանգության հիմնական մեխանիզմները, թե ինչպես են աշխատում Bucket Policies-ը, Access Control List-երը (ACLs), և Block Public Access-ը, ինչպես նաև ինչպես կիրառել դրանք ինտերֆեյսով (Console) և IaC (Terraform) գործիքով։

---

## 🎯 Դասի Նպատակները

1. Հասկանալ S3-ի անվտանգության ճարտարապետությունը (Security Model)։
2. Տիրապետել **Bucket Policies**-ի JSON կառուցվածքին (Principal, Action, Resource, Effect, Condition)։
3. Հասկանալ **S3 Block Public Access**-ի աշխատանքի սկզբունքը և կարևորությունը։
4. Իմանալ, թե ինչպես է AWS-ը գնահատում մուտքի իրավունքները (Access Evaluation Logic)։
5. Կիրառել անվտանգության կանոնները AWS Console-ով, CLI-ով և Terraform-ով։

---

## 📚 1. S3 Անվտանգության Հիմունքները (S3 Security Overview)

default (By default), AWS S3-ում ստեղծված բոլոր Bucket-ները և դրանց մեջ գտնվող Object-ները **մասնավոր են (Private)**: Միայն Bucket-ը ստեղծող AWS Account-ը (կամ դրա root/admin օգտատերերը) ունեն մուտքի իրավունք։

S3-ում մուտքի իրավունքները կառավարվում են 3 հիմնական մակարդակներում.

1. **IAM Policies (Identity-based):** Կցվում են IAM User-ներին, Group-ներին կամ Role-ներին (օրինակ՝ "Թույլ տալ Արամին կարդալ S3 bucket-ը")։
2. **Bucket Policies (Resource-based):** Կցվում են անմիջապես S3 Bucket-ին (օրինակ՝ "Թույլ տալ այս կոնկրետ IP հասցեին ներբեռնել ֆայլեր այս bucket-ից")։
3. **S3 Block Public Access:** Գլոբալ/Bucket մակարդակի անվտանգության "վահան" (Safety net), որը արգելափակում է ցանկացած հանրային (Public) հասանելիություն՝ անկախ Bucket Policy-ի կամ ACL-ի կարգավորումներից։

> 💡 **Best Practice:** Անվտանգության ժամանակակից ստանդարտներով խորհուրդ է տրվում **անջատել ACL-ները (Bucket owner enforced)** և օգտագործել միայն **IAM Policies** ու **Bucket Policies**:

---

## 📜 2. Ինչ է S3 Bucket Policy-ն և ինչպես է այն գրվում

Bucket Policy-ն JSON ձևաչափով գրված փաստաթուղթ է, որը սահմանում է, թե **ով (Principal)**, **ինչ գործողություն (Action)** կարող է անել **որ ռեսուրսի վրա (Resource)**, և **ինչ պայմաններում (Conditions)**։

### 🧱 JSON Կառուցվածքը (Policy Structure)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ExampleStatementId",
      "Effect": "Allow | Deny",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/DevUser"
      },
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": [
        "arn:aws:s3:::my-company-bucket",
        "arn:aws:s3:::my-company-bucket/*"
      ],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "203.0.113.0/24"
        }
      }
    }
  ]
}
```

### 🔍 Բաղադրիչների Բացատրություն

- **`Effect`:** `Allow` (Թույլատրել) կամ `Deny` (Արգելել)։
- **`Principal`:** Ով է ստանում թույլտվությունը (AWS Account, IAM User/Role, կամ `"*"` ցանկացած մարդու համար)։
- **`Action`:** S3-ի API գործողությունները, օրինակ՝
  - `s3:GetObject` — Ֆայլ ներբեռնել (Read)
  - `s3:PutObject` — Ֆայլ ապլոդ անել (Write)
  - `s3:ListBucket` — Bucket-ի պարունակությունը տեսնել (List)
  - `s3:DeleteObject` — Ֆայլ ջնջել (Delete)
- **`Resource`:** AWS ARN (Amazon Resource Name)։
  - `arn:aws:s3:::my-bucket` -> Վերաբերում է ինքնին Bucket-ին (օր.՝ List operations)։
  - `arn:aws:s3:::my-bucket/*` -> Վերաբերում է Bucket-ի ներսի **բոլոր ֆայլերին (Objects)** (օր.՝ GetObject, PutObject)։
- **`Condition` (Ոչ պարտադիր):** Լրացուցիչ պայմաններ (օր.՝ միայն SSL/HTTPS կապ, կոնկրետ IP հասցե, կամ կոնկրետ ժամին)։

---

## 🛠️ 3. Իրական Օրինակներ (Bucket Policy Examples)

### Օրինակ 1. Հանրային Վեբ-Կայքի համար (Public Read Only)

_Եթե S3-ը օգտագործում եք static website hosting-ի համար._

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-public-website-bucket/*"
    }
  ]
}
```

### Օրինակ 2. Սահմանափակում ըստ IP Հասցեի (Restrict to Office IP)

_Թույլատրել ֆայլեր ներբեռնել միայն ընկերության օֆիսային IP-ից (`198.51.100.14/32`):_

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowOfficeIPOnly",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::corporate-docs-bucket/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "198.51.100.14/32"
        }
      }
    }
  ]
}
```

### Օրինակ 3. Պարտադրել HTTPS (Enforce SSL/TLS)

_Արգելել (Deny) ցանկացած հարցում, որը չի օգտագործում HTTPS:_

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceHTTPSRequestsOnly",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::secure-data-bucket",
        "arn:aws:s3:::secure-data-bucket/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
```

---

## 🛡️ 4. S3 Block Public Access (BPA)

**S3 Block Public Access**-ը AWS-ի կողմից ապահովված անվտանգության կրիտիկական շերտ է, որը կանխում է տվյալների պատահական արտահոսքը (data leaks)։ Այն կարող է միացվել **ամբողջ AWS Account-ի** կամ **առանձին Bucket-ի** համար։

BPA-ն ունի 4 հիմնական կանոն (Checkboxes):

| Կանոն (Setting)                            | Ինչ է անում                                                                  |
| :----------------------------------------- | :--------------------------------------------------------------------------- |
| **1. Block public ACLs**                   | Արգելում է նոր **Public ACL**-ների ավելացումը ֆայլերին կամ bucket-ին։        |
| **2. Ignore public ACLs**                  | Անտեսում է եղած բոլոր Public ACL-ները (ֆայլերը դառնում են private)։          |
| **3. Block public bucket policies**        | Արգելում է ավելացնել **նոր Public Bucket Policy** (օր.՝ `Principal: "*"`):   |
| **4. Block public & cross-account access** | Անտեսում է եղած Public Bucket Policy-ները և արգելում Cross-Account access-ը։ |

> ⚠️ **Կարևոր կանոն:**  
> Եթե **Block Public Access**-ը միացված է (ON), ապա նույնիսկ եթե դուք գրեք Public Bucket Policy (`Allow` `Principal: "*"`), AWS-ը **կարգելի (Deny)** մուտքը դեպի bucket: Ինտերնետից կայք ցուցադրելու համար BPA-ն պետք է հատուկ անջատել (OFF):

---

## ⚖️ 5. AWS Access Evaluation Logic (Որոշումների կայացման տրամաբանությունը)

Երբ ինչ-որ մեկը հարցում է ուղարկում S3-ին, AWS-ը որոշում է կայացնում հետևյալ տրամաբանությամբ.

1. **Explicit Deny (Ուղղակի արգելք):** Եթե ԿԱ որևէ `Deny` (IAM-ում, Bucket Policy-ում կամ BPA-ում) -> **ACCESS DENIED**:
2. **Explicit Allow (Ուղղակի թույլտվություն):** Եթե `Deny` չկա և ԿԱ գոնե մեկ `Allow` -> **ACCESS GRANTED**:
3. **Implicit Deny (default արգելք):** Եթե չկա ոչ `Deny`, ոչ `Allow` -> **ACCESS DENIED**:

---

## 🛠️ 6. Ինչպես կառավարել S3 Security-ն տարբեր գործիքներով

### 1. AWS Management Console (Վեբ ինտերֆեյս)

- Գնալ **S3 Service** -> Ընտրել **Bucket-ը** -> Մտնել **Permissions** tab:
- Այնտեղ կարող եք խմբագրել **Block public access (bucket settings)** և **Bucket policy** բաժինները։

### 2. AWS CLI (Command Line Interface)

- **Bucket Policy ավելացնել:**

  ```bash
  aws s3api put-bucket-policy --bucket my-bucket-name --policy file://policy.json
  ```

- **Block Public Access-ը միացնել (Block all):**
  ```bash
  aws s3api put-public-access-block \
      --bucket my-bucket-name \
      --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
  ```

### 3. Terraform (Infrastructure as Code)

```hcl
# 1. Ստեղծել S3 Bucket
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-company-ultra-secure-bucket"
}

# 2. Միացնել Block Public Access (Best Practice)
resource "aws_s3_bucket_public_access_block" "bpa" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Ավելացնել Bucket Policy (Պարտադրել TLS/HTTPS)
resource "aws_s3_bucket_policy" "allow_tls_only" {
  bucket = aws_s3_bucket.secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.secure_bucket.arn,
          "${aws_s3_bucket.secure_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
```

---

## 📝 Գործնական Առաջադրանք (Lab Exercise)

1. **Ստեղծել S3 bucket** `dev-lab-[your-name]` անունով AWS Console-ում կամ CLI-ով։
2. **Ավելացնել Bucket Policy**, որը թույլ է տալիս `s3:GetObject` միայն ձեր ընթացիկ IP հասցեին (`curl ifconfig.me` հրամանով իմացեք ձեր IP-ն)։
3. **Թեստավորել:** Փորձեք ներբեռնել ֆայլը ձեր համակարգչից (պետք է աշխատի) և հեռախոսի ցանցից/VPN-ից (պետք է ստանաք `Access Denied`)։
4. **Միացնել Block Public Access-ը** և ստուգել, թե ինչպես է այն արգելափակում հանրային մուտքերը։

---

## 📌 Summary Cheatsheet

- **IAM Policy:** Վերաբերում է **Օգտատիրոջը** (Who can do what)։
- **Bucket Policy:** Վերաբերում է **Bucket-ին** (Who can access this bucket)։
- **Block Public Access:** Անվտանգության վերին շերտ (Master switch for public access)։
- **Explicit Deny > Explicit Allow:** Եթե կա `Deny`, այն միշտ հաղթում է `Allow`-ին։
