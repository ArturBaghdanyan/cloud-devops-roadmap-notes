# AWS Cloud Engineering · Module 2 (IAM Essentials)

## Lesson 3. IAM Roles


## 1. Ընդհանուր պատկեր

Lesson 2-ում սովորեցինք **user-ներ** և **group-եր**. նրանք ունեն **մշտական ինքնություն** (գաղտնաբառ, access key-եր)։ Բայց AWS-ում շատ հաճախ գործողություններ պետք է անի ոչ թե կոնկրետ մարդը, այլ.

- **EC2 սերվերը**, որը պետք է կարդա S3-ից
- **Lambda ֆունկցիան**, որը պետք է գրի DynamoDB-ում
- **Մեկ այլ AWS հաշվի** աշխատակիցը, որը ժամանակավոր մուտք է պետք
- **Արտաքին ինքնություն** (օրինակ՝ company login, GitHub Actions)

Այս բոլոր դեպքերում access key-եր բաժանելը և դրանք կոդի մեջ պահելը **վատ գաղափար է** (կարող են արտահոսել, պետք է ձեռքով փոխել, չեն սահմանափակվում ժամանակով)։ Լուծումը **IAM Role**-ն է։

> **Պարզ համեմատություն.** User-ը **անձնագիր ունեցող աշխատակից** է՝ իր անձնական քարտով։ Role-ը **ժամանակավոր անցաթուղթ (badge)** է, որը կախված է դռան մոտ. ով իրավասու է, վերցնում է, մտնում է, և երբ ժամանակը լրանում է, անցաթուղթը դադարում է գործել։ Անցաթուղթը պատկանում է **դերին** (օրինակ՝ «սերվերային սենյակի այցելու»), ոչ թե կոնկրետ մարդուն։

| Հարց                     | Պատասխան                                                                              |
| ------------------------ | ------------------------------------------------------------------------------------- |
| Ի՞նչ է Role-ը            | Ինքնություն՝ թույլտվություններով, որը **կարելի է ժամանակավորապես ստանձնել** (assume)  |
| Ո՞վ կարող է ստանձնել     | User, այլ role, AWS ծառայություն, այլ հաշվի ինքնություն, արտաքին ինքնություն          |
| Ի՞նչ է ստանում ստանձնողը | **Ժամանակավոր credentials**, որոնք ավտոմատ լրանում են                                 |
| Ինչի՞ համար              | Access key-երից խուսափելու, ծառայություններին մուտք տալու, cross-account մուտքի համար |

**Հիմնական կանոն.** Role-ը **ոչ մեկին չի պատկանում** և **երկարաժամկետ credentials չունի**։ Այն միշտ ստանձնվում է, ու ստանձնողը ստանում է **ժամանակավոր** թույլտվություններ։

---

## 2. Ի՞նչ է IAM Role-ը

**IAM Role-ը** AWS հաշվի ներսում ստեղծված ինքնություն է, որը ունի **թույլտվությունների policy-ներ**, բայց **կապված չէ կոնկրետ մարդու** հետ։

### Ինչով է role-ը տարբերվում user-ից

| Հատկանիշ               | **User**                  | **Role**                                   |
| ---------------------- | ------------------------- | ------------------------------------------ |
| Գաղտնաբառ / access key | Ունի (մշտական)            | **Չունի**                                  |
| Credentials            | Երկարաժամկետ              | **Ժամանակավոր** (լրանում են)               |
| Ո՞վ է օգտագործում      | Մեկ կոնկրետ մարդ/հավելված | **Յուրաքանչյուր, ով իրավասու է ստանձնել**  |
| Ինչպե՞ս է աշխատում     | Մուտք գործում ես նրանով   | Ստանձնում ես (**AssumeRole**)              |
| Տիպային դեպք           | Ուսումնական/պարզ դեպքեր   | Ծառայություններ, cross-account, federation |

### Ինչ կարող է ունենալ role-ը

- **Permissions policy** (թույլտվությունների policy). ինչ կարող է անել role-ը
- **Trust policy** (վստահության policy). ով կարող է ստանձնել այս role-ը
- Օպտիմալ պայմաններ (օրինակ՝ MFA-ի առկայություն, `ExternalId`)

---

## 3. Role-ի երկու policy-ները (ամենակարևոր գաղափարը)

Role-ի մեջ **երկու տարբեր հարց** կա, և դրանց պատասխանում են երկու տարբեր policy-ներ.

| Policy                 | Հարցը                                          | Օրինակ                                    |
| ---------------------- | ---------------------------------------------- | ----------------------------------------- |
| **Trust policy**       | **Ո՞վ** կարող է ստանձնել այս role-ը            | «EC2 ծառայությունը» կամ «`armine` user-ը» |
| **Permissions policy** | Role-ը ստանձնելուց հետո **ի՞նչ** կարելի է անել | «կարդալ S3 bucket-ից»                     |

```
        ┌─────────────── ROLE ───────────────┐
Ով?  ─► │  Trust policy      (դուռը)         │
        │  «ո՞վ կարող է ներս մտնել»          │
        ├────────────────────────────────────┤
Ինչ? ─► │  Permissions policy (սենյակի իրավունքները) │
        │  «ներս մտնելուց հետո ի՞նչ կարող ես անել»  │
        └────────────────────────────────────┘
```

> **Հիշիր.** Եթե trust policy-ն քեզ չի վստահում, չես կարող ստանձնել role-ը, նույնիսկ եթե permissions-ը շատ մեծ են։ Եթե trust-ը կա, բայց permissions policy չկա, role-ը ստանձնելուց հետո **ոչինչ չես կարող անել** (implicit deny, ինչպես Lesson 2-ում)։

### Trust policy-ի օրինակ (EC2-ը կարող է ստանձնել)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Սա **resource-based policy** է (Lesson 2-ից), որը կցված է հենց role-ին։ Նկատիր երկու նոր տարր.

| Տարր                     | Նշանակությունը                                                               |
| ------------------------ | ---------------------------------------------------------------------------- |
| `Principal`              | **Ով** է թույլատրվում (user, role, հաշիվ, ծառայություն, արտաքին ինքնություն) |
| `Action: sts:AssumeRole` | Գործողությունը՝ «ստանձնել role-ը» (STS = Security Token Service)             |

### Trust policy-ի այլ Principal-ներ

```json
"Principal": { "Service": "lambda.amazonaws.com" }                  // Lambda ծառայությունը
"Principal": { "AWS": "arn:aws:iam::111122223333:user/armine" }     // կոնկրետ user
"Principal": { "AWS": "arn:aws:iam::111122223333:root" }            // 111122223333 հաշվի ինքնությունները*
```

\* `:root`-ը այստեղ **root user չէ**, այլ նշանակում է «այդ հաշիվը». ապա կոնկրետ ով կարող է ստանձնել, որոշվում է այդ հաշվի **իր** policy-ներով։

### Permissions policy-ի օրինակ (կարդալ S3-ից)

Սա նույն տեսակի identity-based policy է, ինչ Lesson 2-ում։

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket", "s3:GetObject"],
      "Resource": ["arn:aws:s3:::my-bucket", "arn:aws:s3:::my-bucket/*"]
    }
  ]
}
```

---

## 4. Ինչպես է աշխատում Role-ը (AssumeRole հոսքը)

```
1. Ստանձնող (user / EC2 / Lambda / ...)
        │   «Ուզում եմ ստանձնել Role X-ը»  (sts:AssumeRole)
        ▼
2. AWS STS ստուգում է Role X-ի TRUST policy-ն
        │   «Այս ստանձնողը թույլատրվա՞ծ է»
        ├── ոչ ──► AccessDenied
        ▼ այո
3. STS տալիս է ԺԱՄԱՆԱԿԱՎՈՐ credentials
        │   (Access Key ID + Secret Access Key + Session Token)
        ▼
4. Ստանձնողը օգտագործում է դրանք
        │   Գործում են միայն Role X-ի PERMISSIONS policy-ի սահմաններում
        ▼
5. Ժամանակը լրանում է ──► credentials-ը դադարում է գործել
```

### Ժամանակավոր credentials

- Բաղկացած են **երեք մասից**. Access Key ID, Secret Access Key և **Session Token**
- Ունեն **ժամկետ** (session duration). լռելյայն՝ **1 ժամ**. role-ի համար կարելի է սահմանել մինչև **12 ժամ**
- Ժամկետը լրանալուց հետո դադարում են գործել. պետք չէ ձեռքով ջնջել կամ «պտտել» (rotate)
- Եթե արտահոսեն, վնասը սահմանափակ է ժամանակով (long-term key-ի համեմատ)

### Կարևոր նրբություն. ստանձնելիս նախկին իրավունքները կորչում են

Երբ **user-ը** ստանձնում է role, այդ session-ի ընթացքում նա ունի **միայն role-ի** թույլտվությունները, **ոչ թե** իր սեփականները + role-ինը։ Վերադառնալով իր սովորական ինքնությանը, նա նորից ստանում է իր սկզբնական թույլտվությունները։

---

## 5. Role-երի տեսակներն ու օգտագործման դեպքերը

### 5.1. Role AWS ծառայության համար (service role)

Ամենատարածված դեպքը. **ծառայությանը** տալիս ես թույլտվություններ՝ առանց key-երի։

| Ծառայություն  | Ինչի համար է role-ը                                       | Trust policy-ի Principal  |
| ------------- | --------------------------------------------------------- | ------------------------- |
| **EC2**       | Սերվերի վրա աշխատող կոդը մուտք ունենա S3, DynamoDB և այլն | `ec2.amazonaws.com`       |
| **Lambda**    | Ֆունկցիան կարողանա գրել logs, կարդալ S3                   | `lambda.amazonaws.com`    |
| **ECS tasks** | Container-ը մուտք ունենա այլ ծառայությունների             | `ecs-tasks.amazonaws.com` |

**EC2-ի դեպքում** role-ը EC2 instance-ին կցվում է **instance profile**-ի միջոցով (role-ի «փաթեթ» EC2-ի համար)։ Console-ում role ստեղծելիս instance profile-ը սովորաբար ստեղծվում է ավտոմատ։ Instance-ի ներսում AWS CLI/SDK-ը credentials-ը ստանում է **ինքնուրույն**, և քո կոդում key-երի կարիք չկա։

> **Ինչու է սա կարևոր.** Սա ճիշտ այն բանն է, որ երբեք չպետք է անես. `AWS_ACCESS_KEY_ID`-ը գրել EC2-ի վրա կամ կոդի մեջ։ Role-ով key-երը **գոյություն չունեն**, հետևաբար չեն կարող արտահոսել Git-ում։

### 5.2. Cross-account role (մուտք մեկ այլ հաշվից)

**Սցենար.** Քո ընկերությունը ունի երկու AWS հաշիվ (օրինակ՝ `dev` և `prod`)։ Dev հաշվի user-ը պետք է ժամանակավոր մուտք ունենա prod հաշվի S3-ին։

```
Dev հաշիվ (111111111111)              Prod հաշիվ (222222222222)
   user: armine  ──── AssumeRole ───►   role: ProdS3Reader
                                         trust: «վստահում եմ 111111111111-ին»
                                         permissions: կարդալ S3
```

Այսպես prod հաշվում **չես ստեղծում ևս մի user**. role ես ստեղծում, ու ուրիշ հաշվի ինքնությունը ստանձնում է այն։

### 5.3. Federation (արտաքին ինքնություններ)

Երբ օգտատերերը արդեն ունեն ինքնություն **AWS-ից դուրս**.

- **IAM Identity Center / SAML** (ընկերության login). մարդիկ մուտք են գործում կորպորատիվ հաշվով, ստանում role
- **OIDC** (օրինակ՝ GitHub Actions). CI/CD-ը ստանձնում է role՝ առանց AWS key-երը GitHub-ում պահելու

Սա հենց այն «ավելի ժամանակակից տարբերակն» է, որի մասին Lesson 2-ում ասվել էր (մարդկանց համար՝ Identity Center, հավելվածների համար՝ role-եր)։

### 5.4. Service-linked role

**AWS ծառայության հետ կապված հատուկ role**, որը ստեղծվում և կառավարվում է **հենց AWS-ի կողմից**։ Դրա permissions-ը կանխորոշված են ծառայության կողմից, և դու չես կարող փոխել դրանք։ Սովորաբար ստեղծվում է ավտոմատ, երբ առաջին անգամ օգտագործում ես տվյալ ծառայությունը։ Դասի մակարդակով բավական է իմանալ, որ այդպիսին կա։

### Ամփոփ աղյուսակ

| Տեսակ               | Ով է ստանձնում                    | Տիպային նպատակ                       |
| ------------------- | --------------------------------- | ------------------------------------ |
| Service role        | AWS ծառայություն (EC2, Lambda...) | Ծառայությանը մուտք տալ առանց key-երի |
| Cross-account role  | Այլ հաշվի user/role               | Ժամանակավոր մուտք այլ հաշվին         |
| Federated role      | Արտաքին ինքնություն (SAML/OIDC)   | Company login, CI/CD                 |
| Service-linked role | AWS ծառայությունը ինքը            | Ծառայության ներքին աշխատանք          |

---

## 6. Ինչպես user-ը ստանձնում է role (օրինակ)

**Սցենար.** `armine` user-ը ժամանակավորապես պետք է ստանձնի `S3AdminRole`-ը։

### Քայլ 1. Role-ի trust policy (թույլ է տալիս `armine`-ին)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "AWS": "arn:aws:iam::111122223333:user/armine" },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Քայլ 2. User-ի կողմից թույլտվություն (ցանկալի է. օրինակ՝ խմբի policy)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::111122223333:role/S3AdminRole"
    }
  ]
}
```

> **Երկու կողմն էլ.** Պարզության համար սովորիր պահել երկուսն էլ. **role-ը վստահում է user-ին** (trust policy) և **user-ը թույլատրված է ստանձնել role-ը** (identity policy)։ Cross-account դեպքում **երկուսն էլ պարտադիր են**։ Նույն հաշվի ներսում կան նրբություններ՝ կախված նրանից, թե trust policy-ում ինչ է նշված Principal-ում, բայց երկու կողմը թույլատրելը ամենաանվտանգն ու ամենահասկանալին է։

### Քայլ 3. Ստանձնում

**Console-ով.** վերևի աջ անկյունում քո անունի վրա սեղմիր → **Switch role** → լրացրիր account ID-ն և role-ի անունը։

**CLI-ով.**

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::111122223333:role/S3AdminRole \
  --role-session-name armine-session
```

Պատասխանում կստանաս `AccessKeyId`, `SecretAccessKey`, `SessionToken` և `Expiration`։

### Ստուգում՝ ո՞վ եմ ես հիմա

```bash
aws sts get-caller-identity
```

Դա ցույց է տալիս ընթացիկ ինքնությունը. role-ը ստանձնելուց հետո ARN-ում կերևա `assumed-role/...`։ **Շատ օգտակար է ստուգելու համար, թե որ ինքնությամբ ես աշխատում։**

---

## 7. Role-ը և Policy evaluation (կապը Lesson 2-ի հետ)

Role-ի վրա **նույն կանոնները** են գործում.

1. Ամեն ինչ սկզբում **արգելված է** (implicit deny)
2. **Explicit Deny** միշտ հաղթում է
3. Կա **Allow**՝ թույլատրվում է. չկա՝ արգելվում է

Role-ի դեպքում լրացուցիչ **երկու քայլ**.

- **Ստանձնելը** որոշվում է **trust policy**-ով (և ստանձնողի իրավունքներով)
- **Ստանձնելուց հետո** թույլտվությունները որոշվում են role-ի **permissions policy**-ով

```
Ստանձնել կարո՞ղ եմ?  ──► Trust policy (+ ստանձնողի sts:AssumeRole)
Ինչ կարո՞ղ եմ անել?  ──► Role-ի permissions policy (Deny > Allow > Implicit Deny)
```

> Ամբողջական տրամաբանությունը (permissions boundary, SCP, session policy) հետագա դասերի թեմաներ են։

---

## 8. Role թե՞ User. ինչպես ընտրել

| Իրավիճակ                                                | Ինչ օգտագործել                           |
| ------------------------------------------------------- | ---------------------------------------- |
| EC2 / Lambda / ECS պետք է մուտք ունենա AWS ռեսուրսներին | **Role**                                 |
| Երկու AWS հաշվի միջև մուտք                              | **Role** (cross-account)                 |
| CI/CD-ը (օրինակ՝ GitHub Actions) պետք է deploy անի      | **Role** (OIDC)                          |
| Մարդիկ ընկերության login-ով                             | **Identity Center** (ներքևում role-երով) |
| Ուսումնական/փորձարկման պարզ դեպք (ինչպես Lesson 2)      | User (+ խումբ)                           |

**Ընդհանուր կանոն.** Երբ կարող ես role օգտագործել՝ օգտագործիր role, ոչ թե երկարաժամկետ access key-եր։

---

## 9. Լավագույն պրակտիկաներ (Security best practices)

- **Նախընտրիր role-երը** երկարաժամկետ access key-երից
- **Least privilege.** role-ի permissions policy-ն տուր միայն անհրաժեշտը (ոչ `"Action": "*"` + `"Resource": "*"`)
- **Trust policy-ն նեղ պահիր.** նշիր կոնկրետ Principal-ներ, ոչ թե ամբողջ հաշիվ կամ `"*"`
- **Սահմանափակիր session duration-ը** ըստ անհրաժեշտության (կարճ՝ ավելի անվտանգ)
- **MFA պայման** զգայուն role-երի համար (`Condition`-ով)
- **Cross-account/երրորդ կողմի դեպքում** օգտագործիր `ExternalId`՝ «confused deputy» խնդրից պաշտպանվելու համար
- **Մի՛ դիր** `iam:PassRole`-ը լայն Resource-ով. այն թույլ է տալիս ծառայությանը «փոխանցել» role, ինչը կարող է հանգեցնել իրավունքների ընդլայնման
- **Ջնջիր** չօգտագործվող role-երը
- **Օգտագործիր CloudTrail**՝ նայելու, թե ով ինչ role է ստանձնել

---

## 10. Պրակտիկ քայլեր (Part A, B, C)

Դասի պրակտիկ մասի ընդհանուր հոսքը (Console-ով).

**A. Role ստեղծել EC2-ի համար (S3 read)**

1. IAM → Roles → **Create role**
2. **Trusted entity type** → **AWS service**, ընտրիր **EC2** (սա ստեղծում է trust policy՝ `ec2.amazonaws.com`)
3. **Add permissions**. որոնիր և ընտրիր `AmazonS3ReadOnlyAccess` (կամ քո customer managed readers policy-ն Lesson 2-ից)
4. Տուր անուն (օրինակ՝ `aca-ec2-s3-reader`) և **Create role**
5. Բացիր ստեղծված role-ը և նայիր երկու ներդիրները. **Permissions** և **Trust relationships**

**B. Role-ը կցել EC2 instance-ին**

1. EC2 → ընտրիր instance → **Actions** → **Security** → **Modify IAM role**
2. Ընտրիր `aca-ec2-s3-reader`-ը և **Update IAM role**
3. Instance-ին միանալուց հետո փորձիր (key-եր **չկարգավորած**).

```bash
aws sts get-caller-identity
aws s3 ls s3://my-bucket
```

Առաջինը ցույց կտա `assumed-role/aca-ec2-s3-reader/...`, երկրորդը կաշխատի։

**C. User-ը ստանձնում է role (cross-role practice)**

1. Ստեղծիր role՝ trusted entity **AWS account** (նույն հաշիվը), և նշիր `armine`-ին trust-ում
2. Role-ին կցիր S3 read policy
3. Կցիր `sts:AssumeRole` թույլտվությունը `aca-s3-readers` խմբին (կամ `armine`-ին) այդ role-ի ARN-ով
4. Մուտք գործիր որպես `armine` → **Switch role** → ստուգիր, որ աշխատում է
5. Վերադարձիր սկզբնական ինքնությանը (**Switch back**)

### Ստուգելու գաղափարներ

- Role-ը ստանձնելուց հետո փորձիր ինչ-որ բան, որ role-ի permissions-ում **չկա**. պետք է ստանաս `AccessDenied`
- Հեռացրու trust policy-ից `armine`-ին և նորից փորձիր ստանձնել. պետք է ձախողվի
- `aws sts get-caller-identity`-ով համեմատիր ինքնությունը ստանձնելուց առաջ և հետո

---

## 11. Self-study checklist

- [ ] Role-ի permissions policy-ն փոխիր այնպես, որ կարողանա միայն **`uploads/` prefix**-ին գրել (`s3:PutObject` `bucket/uploads/*`-ի վրա)
- [ ] Trust policy-ին ավելացրու **MFA պայման** և հասկացիր՝ ինչպես է այն աշխատում (`aws:MultiFactorAuthPresent`)
- [ ] Փոխիր role-ի **maximum session duration**-ը և նայիր, թե ինչ է փոխվում
- [ ] Կարդա AWS-ի **Security best practices in IAM** էջը՝ role-երի մասին մասերը
- [ ] Ջնջիր փորձարկման role-երը և instance-ը, երբ վերջացնես. պահիր `armine`-ին և `aca-s3-readers`-ը

> Խորհուրդ. EC2-ին կցված role-ը ջնջելուց առաջ նախ **անջատիր այն instance-ից**, հետո ջնջիր role-ը (Console-ը սովորաբար նաև instance profile-ը ջնջելու առաջարկ է անում)։

---

## 12. Հաճախ թույլ տրվող սխալներ

- **Trust և permissions policy-ները շփոթել.** Trust-ը ասում է **ով** կարող է ստանձնել, permissions-ը՝ **ինչ** կարող է անել
- **Trust policy-ում `"Principal": "*"`.** նշանակում է «ցանկացողը», ինչը շատ վտանգավոր է
- **Մոռանալ permissions policy-ն.** Role-ը ստեղծվել է, trust-ը կա, բայց ոչ մի policy կցված չէ, ուստի role-ը ոչինչ չի կարող անել
- **Կարծել, որ role-ը ավելացնում է իրավունքները.** user-ը ստանձնելուց հետո ունի **միայն role-ի** իրավունքները, ոչ թե իր + role-ինը
- **Cross-account-ում միայն մեկ կողմը թույլատրել.** Պետք են և trust policy-ն (target հաշվում), և `sts:AssumeRole` թույլտվությունը (source հաշվում)
- **EC2-ում role-ը չկցել instance-ին**, իսկ կոդում փնտրել key-եր
- **Երկարաժամկետ key դնել EC2-ի վրա** role-ի փոխարեն
- **Wildcard-երով `iam:PassRole`**
- **Ժամանակ չտրամադրել փոփոխության տարածմանը.** IAM փոփոխությունը երբեմն մի քանի վայրկյան հետո է երևում

---

## 13. Ինքնաստուգում

1. Ինչ է IAM Role-ը և ինչով է այն տարբերվում user-ից։
2. Ինչ է trust policy-ն և ինչ է permissions policy-ն։
3. Ինչ է ստանում ստանձնողը, երբ ստանձնում է role։ Որքա՞ն ժամանակ է այն գործում։
4. EC2 սերվերին պետք է մուտք S3-ին։ Ինչու է role-ը ավելի լավ, քան access key-երը։
5. Ինչ է նշանակում `"Principal": { "Service": "ec2.amazonaws.com" }`։
6. `armine`-ը ստանձնել է role։ Նրա սեփական policy-ները դեռ գործո՞ւմ են այդ session-ի ընթացքում։
7. Որ դեպքում է անհրաժեշտ և՛ trust policy, և՛ identity policy-ի `sts:AssumeRole`։

<details>
<summary>Պատասխաններ</summary>

1. Role-ը ժամանակավոր ստանձնվող ինքնություն է՝ թույլտվություններով։ Ի տարբերություն user-ի, այն **չունի գաղտնաբառ կամ երկարաժամկետ access key-եր**, ու դրանով կարող է աշխատել ցանկացած իրավասու ինքնություն։
2. **Trust policy**-ն որոշում է, թե **ով** կարող է ստանձնել role-ը։ **Permissions policy**-ն որոշում է, թե ստանձնելուց հետո **ինչ** կարելի է անել։
3. **Ժամանակավոր credentials** (Access Key ID, Secret Access Key, Session Token)։ Լռելյայն՝ 1 ժամ. role-ի համար կարելի է սահմանել մինչև 12 ժամ։
4. Role-ով key-եր **գոյություն չունեն**. չեն արտահոսում Git-ում, ավտոմատ լրանում և թարմացվում են, ու չի պահանջվում ձեռքով rotation։
5. Trust policy-ում թույլատրվում է **EC2 ծառայությանը** ստանձնել այս role-ը։
6. Ոչ։ Session-ի ընթացքում գործում են **միայն role-ի** թույլտվությունները։ Սեփականները վերադառնում են, երբ դուրս ես գալիս role-ից։
7. **Cross-account** դեպքում. target հաշվի role-ի trust policy-ն պետք է վստահի ստանձնողին, և source հաշվի ինքնությունը պետք է ունենա `sts:AssumeRole` թույլտվություն։

</details>

---

## 14. Արագ ամփոփում (cheat sheet)

```
Ստանձնող ──(sts:AssumeRole)──► Role ──(permissions)──► AWS ռեսուրսներ
              ▲                  │
              │                  └─ Trust policy:      «ով կարող է ստանձնել»
              └─ ժամանակավոր      └─ Permissions policy: «ինչ կարող է անել»
                 credentials

Role = Trust policy + Permissions policy
Credentials = ժամանակավոր (Access Key + Secret + Session Token)
```

- Role-ը **ստանձնվող** ինքնություն է, ոչ մեկին չի պատկանում
- Չունի գաղտնաբառ/երկարաժամկետ key-եր. ստանձնելիս ստանում ես **ժամանակավոր** credentials
- **Trust policy** = ով կարող է ստանձնել. **Permissions policy** = ինչ կարող է անել
- Ծառայությունների համար (EC2, Lambda) **միշտ role**, ոչ թե access key-եր
- Cross-account մուտքը կատարվում է role-ով (trust + `sts:AssumeRole`)
- Ստանձնելուց հետո գործում են **միայն role-ի** իրավունքները
- Evaluation-ը նույնն է. **Explicit Deny > Explicit Allow > Implicit Deny**

---

## 15. Օգտակար հղումներ

Հղումները AWS-ի պաշտոնական փաստաթղթերից են. եթե որևէ էջ տեղափոխված լինի, որոնիր վերնագրով։

### 1. IAM roles

- [IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html), ինչ է role-ը և երբ օգտագործել
- [Roles terms and concepts](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_terms-and-concepts.html), հիմնական հասկացություններ
- [Common scenarios for roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_common-scenarios.html), տիպային օգտագործման դեպքեր
- [Create a role for an AWS service](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html), Part A-ի քայլերը
- [Using service-linked roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html), service-linked role-եր

### 2. Ստանձնում և ժամանակավոր credentials

- [Temporary security credentials in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp.html), ինչպես են աշխատում ժամանակավոր credentials-ը
- [Switch to an IAM role (console)](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html), Part C-ի քայլերը
- [IAM roles for Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html), role-եր EC2-ի համար, instance profile

### 3. Trust policy և PassRole

- [AWS JSON policy elements: Principal](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_principal.html), Principal-ի տարբերակները trust policy-ում
- [Grant a user permissions to pass a role to an AWS service](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html), `iam:PassRole`

