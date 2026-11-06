# 🌐 Module 4: AWS S3 Static Website Hosting

Այս դասի ընթացքում դուք կսովորեք, թե ինչպես հոսթինգ անել ստատիկ վեբ-կայքեր (HTML, CSS, JavaScript, React/Vue build-եր) Amazon S3-ի միջոցով։ Դասն ընդգրկում է անհրաժեշտ կարգավորումները, S3 Block Public Access-ի և Bucket Policy-ի ճիշտ կոնֆիգուրացիան, ինչպես նաև CloudFront (CDN) integration-ի հիմունքները։

## 🎯 Դասի Նպատակները

1. Հասկանալ, թե ինչ է S3 Static Website Hosting-ը և ինչով է այն տարբերվում դինամիկ սերվերներից։
2. Կարգավորել **Index** և **Error** փաստաթղթերը S3 Bucket-ում։
3. Ճիշտ կոնֆիգուրացնել **Block Public Access (BPA)**-ը և **Bucket Policy**-ն՝ կայքը հանրային (Public) դարձնելու համար։
4. Հասկանալ S3 Endpoint URL-ի և S3 REST API URL-ի տարբերությունը։
5. Կառուցել ստատիկ հոսթինգ AWS Console-ով, CLI-ով և Terraform-ով։

---

## 📚 1. Ինչ է S3 Static Website Hosting-ը

Amazon S3-ը թույլ է տալիս հոսթինգ անել ստատիկ վեբ-կայքեր առանց web server-ներ (օր.՝ Nginx, Apache) կառավարելու։

- **Ստատիկ բովանդակություն (Supported):** HTML, CSS, JavaScript, պատկերներ, տեսանյութեր, Client-side SPA (Single Page Applications - React, Vue, Angular):
- **Դինամիկ բովանդակություն (Not Supported):** Server-side սկրիպտներ (PHP, Python, Node.js express), որոնք պահանջում են database միացումներ սերվերի կողմից։

### 🔗 S3 Website Endpoint Ձևաչափը

Երբ միացնում եք Static Website Hosting-ը, S3-ը տրամադրում է վեբ-էնդփոյնթ հետևյալ ձևաչափերով (կախված region-ից).

- `http://<bucket-name>.s3-website.<region>.amazonaws.com`
- `http://<bucket-name>.s3-website-<region>.amazonaws.com`

> ⚠️ **Կարևոր է:** S3 Static Website Endpoint-ները լռելյայն աջակցում են **միայն HTTP** (առանց native HTTPS/SSL support-ի): HTTPS ապահովելու համար օգտագործվում է **AWS CloudFront**:

---

## 🏗️ 2. Քայլ առ Քայլ Կարգավորման Գործընթացը

Ստատիկ կայքը S3-ում հաջողությամբ հոսթինգ անելու համար պահանջվում է 4 հիմնական քայլ.

```
+-----------------------------------------------------------------------+
| 1. Create S3 Bucket                                                   |
|    (e.g., my-awesome-website-2026)                                    |
+-----------------------------------------------------------------------+
                                  |
                                  v
+-----------------------------------------------------------------------+
| 2. Disable S3 Block Public Access (BPA)                               |
|    (Allow public read policies for this specific bucket)              |
+-----------------------------------------------------------------------+
                                  |
                                  v
+-----------------------------------------------------------------------+
| 3. Add Public Read Bucket Policy                                      |
|    (Allow Principal: "*" for s3:GetObject action)                      |
+-----------------------------------------------------------------------+
                                  |
                                  v
+-----------------------------------------------------------------------+
| 4. Enable Static Website Hosting                                      |
|    (Set index.html & error.html)                                      |
+-----------------------------------------------------------------------+
```

---

## 📜 3. Անհրաժեշտ Bucket Policy JSON

Վեբ-կայքի ֆայլերը (HTML/CSS/JS) Ինտերնետից բոլոր այցելուներին հասանելի դարձնելու համար պետք է կցել հետևյալ Bucket Policy-ն.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::<YOUR-BUCKET-NAME>/*"
    }
  ]
}
```

> 🚨 **Զգուշացում:** Քանի որ այս policy-ն հանրային է (`Principal: "*"`), Bucket-ում **մի տեղադրեք** գաղտնի տվյալներ (API keys, `.env` ֆայլեր, private data):

---

## 🛠️ 4. Իրականացումը Տարբեր Գործիքներով

### 1. AWS CLI (Command Line Interface)

Ահա ամբողջական automated script-ը CLI-ով.

```bash
# 1. Ստեղծել Bucket
aws s3api create-bucket \
    --bucket my-cool-site-2026 \
    --region us-east-1

# 2. Անջատել Block Public Access-ը
aws s3api put-public-access-block \
    --bucket my-cool-site-2026 \
    --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

# 3. Ավելացնել Public Read Policy
aws s3api put-bucket-policy \
    --bucket my-cool-site-2026 \
    --policy '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "PublicReadGetObject",
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::my-cool-site-2026/*"
        }
      ]
    }'

# 4. Միացնել Static Website Hosting-ը
aws s3 website s3://my-cool-site-2026/ \
    --index-document index.html \
    --error-document error.html

# 5. Ապլոդ անել HTML ֆայլերը
aws s3 cp index.html s3://my-cool-site-2026/
aws s3 cp error.html s3://my-cool-site-2026/
```

---

### 2. Terraform (Infrastructure as Code)

Production միջավայրերում S3 Website ստեղծելու լավագույն եղանակը Terraform-ն է.

```hcl
# 1. S3 Bucket
resource "aws_s3_bucket" "website" {
  bucket = "my-company-static-website-2026"
}

# 2. Static Website Hosting Configuration
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# 3. Disable Block Public Access
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Public Bucket Policy
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.website.id

  # Ապահովում ենք, որ policy-ն կիրառվի BPA-ն անջատելուց ՀԵՏՈ
  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}
```

---

## 🚀 5. Production Best Practice: S3 + AWS CloudFront + ACM

Իրական արտադրական (Production) նախագծերում S3 Bucket-ը **ուղղակիորեն հանրային չեն դարձնում**: Դրա փոխարեն օգտագործվում է հետևյալ ճարտարապետությունը.

```
+----------+      HTTPS      +-------------------+    OAC (Private)    +---------------+
| Visitor  | --------------> | Amazon CloudFront | ------------------> | S3 Bucket     |
| (Browser)|                 | (CDN / Edge)      |                     | (Private Only)|
+----------+                 +-------------------+                     +---------------+
                                       |
                                       v
                             +-------------------+
                             | AWS Certificate   |
                             | Manager (SSL)     |
                             +-------------------+
```

### Առավելությունները.

1. **HTTPS / Custom Domain support:** Հնարավորություն է տալիս կապել սեփական դոմենը (օր.՝ `https://example.com`) SSL սերտիֆիկատով։
2. **Անվտանգություն (OAC - Origin Access Control):** S3 Bucket-ը մնում է **Private** (Block Public Access ON): Միայն CloudFront-ն ունի իրավունք կարդալ ֆայլերը։
3. **Caching & Speed:** Կայքի ֆայլերը քեշավորվում են AWS Edge Location-ներում ամբողջ աշխարհում (ավելի արագ բեռնում)։

---

## 📝 Գործնական Առաջադրանք (Lab Exercise)

1. **Ստեղծել տեղական ֆայլեր.**
   - Ստեղծեք `index.html` (պարզ `<h1>Hello S3 Website</h1>` տեքստով):
   - Ստեղծեք `error.html` (պարզ `<h1>404 Page Not Found</h1>` տեքստով):
2. **Կարգավորել AWS Console-ում.**
   - Ստեղծեք S3 Bucket `my-web-lab-[your-name]` անունով։
   - **Permissions** բաժնում անջատեք **Block Public Access**-ը։
   - Ավելացրեք **Public Read Bucket Policy**-ն։
   - **Properties** բաժնում միացրեք **Static website hosting**-ը և նշեք `index.html` ու `error.html`:
3. **Թեստավորել.**
   - Վերբեռնեք ֆայլերը Bucket-ում։
   - Բացեք S3 Website Endpoint URL-ը բրաուզերում։
   - Փորձեք բացել գոյություն չունեցող հասցե (օր.՝ `/test-404`) և ստուգեք, որ ցուցադրվում է `error.html`-ը։

---

## 📌 Summary Cheatsheet

| Հայեցակարգ                  | Նկարագրություն                                                                 |
| --------------------------- | ------------------------------------------------------------------------------ |
| **Endpoint Format**         | `http://<bucket-name>.s3-website.<region>.amazonaws.com`                       |
| **BPA State**               | Պետք է լինի **OFF** (եթե օգտագործվում է առանց CloudFront-ի)                    |
| **Bucket Policy Action**    | `s3:GetObject` `Resource: arn:aws:s3:::bucket/*`                               |
| **SSL/HTTPS Support**       | S3-ը native չի աջակցում, պահանջվում է **AWS CloudFront**                       |
| **SPA (React/Vue) Routing** | Error Document-ը նույնպես դնում ենք `index.html` (Client-side routing-ի համար) |
