# AWS Cloud Engineering · Module 2 (IAM Essentials)

## Lesson 2. IAM Policies, Users & Groups


## 1. Ընդհանուր պատկեր

IAM-ում (Identity and Access Management) երկու հարց կա.

- **Authentication («ո՞վ ես»).** օգտատերը ապացուցում է իր ինքնությունը (գաղտնաբառ, MFA, access key)
- **Authorization («ի՞նչ կարող ես անել»).** AWS-ը ստուգում է, թե ինչ թույլտվություններ ունի այդ ինքնությունը

Այս դասը հիմնականում **authorization**-ի մասին է.

| Հասկացություն | Դերը                                                   |
| ------------- | ------------------------------------------------------ |
| **Policy**    | JSON փաստաթուղթ, որը նկարագրում է թույլտվությունները   |
| **User**      | Կոնկրետ մարդու կամ հավելվածի ինքնություն AWS հաշվում   |
| **Group**     | Օգտատերերի հավաքածու, որին policy-ն կցվում է մեկ անգամ |

**Հիմնական կանոն.** նոր ստեղծված IAM user-ը **ոչինչ չի կարող անել**, մինչև նրան (ուղղակի կամ խմբի միջոցով) policy չկցես։

---

## 2. IAM Policies

**Policy-ն** JSON փաստաթուղթ է, որը ասում է՝ **ով/ինչը** կարող է կատարել **ինչ գործողություն** **ինչ ռեսուրսի** վրա (և ըստ ցանկության՝ **ինչ պայմանով**)։

### Policy-ների տեսակները (այս դասում կարևորը առաջին երկուսն է)

- **Identity-based policy.** կցվում է **ինքնությանը** (user, group, role)։ Պատասխանում է «այս ինքնությունը ինչ կարող է անել»
- **Resource-based policy.** կցվում է **ռեսուրսին** (օրինակ՝ S3 bucket policy)։ Պատասխանում է «ով կարող է օգտագործել այս ռեսուրսը»

Երկուսը աշխատում են միասին, իսկ AWS-ը գնահատում է դրանք համատեղ։ Գոյություն ունեն նաև այլ տեսակներ (permissions boundary, SCP, session policy), որոնք հետագա դասերի թեմաներ են։

### Policy-ի կառուցվածքը

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlyForReports",
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": "arn:aws:s3:::my-bucket/reports/*"
    }
  ]
}
```

| Տարր        | Նշանակությունը                                                          |
| ----------- | ----------------------------------------------------------------------- |
| `Version`   | Policy լեզվի տարբերակը. միշտ գրիր `"2012-10-17"`                        |
| `Statement` | Կանոնների ցանկ (մեկ կամ մի քանի)                                        |
| `Sid`       | Կանոնի ընտրովի անուն՝ հեշտ կարդալու համար                               |
| `Effect`    | `Allow` կամ `Deny`                                                      |
| `Action`    | Թույլատրվող/արգելվող գործողությունները (`s3:GetObject`, `s3:PutObject`) |
| `Resource`  | Ռեսուրսները՝ **ARN-ներով** (Lesson 1-ի նյութը)                          |
| `Condition` | Ընտրովի պայման (օրինակ՝ ըստ IP հասցեի կամ MFA-ի առկայության)            |

> Ինչպես կարդալ. «**Effect** (թույլատրել/արգելել) **Action** (այս գործողությունները) **Resource** (այս ռեսուրսների վրա)»։

### Wildcard-ներ Action-ում

```json
"Action": "s3:*"          // S3-ի բոլոր գործողությունները
"Action": "s3:Get*"       // բոլոր Get-ով սկսվող գործողությունները
"Action": "*"             // ամեն ինչ (վտանգավոր)
```

---

## 3. Managed և Inline policies

| Տեսակ                       | Ինչ է                                                               | Երբ օգտագործել                                                                    |
| --------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| **AWS managed policy**      | AWS-ի պատրաստած, պատրաստի policy (օրինակ՝ `AmazonS3ReadOnlyAccess`) | Արագ սկսելու և տիպային դեպքերի համար                                              |
| **Customer managed policy** | Քո ստեղծած առանձին policy, որը կարելի է կցել **մի քանի** ինքնության | Սեփական, կրկին օգտագործվող կանոնների համար (**սովորաբար լավագույն ընտրությունը**) |
| **Inline policy**           | Ուղղակիորեն **մեկ** user-ի, group-ի կամ role-ի մեջ ներդրված policy  | Խիստ եզակի դեպքերի համար, երբ policy-ն երբեք չպետք է վերաօգտագործվի               |

Գործնական նշումներ.

- AWS managed policy-ները հարմար են, բայց հաճախ **չափազանց լայն** են (least privilege-ի տեսանկյունից)
- Customer managed policy-ն կարելի է խմբագրել մեկ տեղում, և փոփոխությունը կգործի ամենուր, որտեղ այն կցված է
- Inline policy-ն ջնջվում է իր ինքնության հետ միասին

---

## 4. Policy evaluation logic (թույլտվության գնահատման տրամաբանությունը)

Երբ ինչ-որ մեկը AWS-ում գործողություն է փորձում, AWS-ը որոշում է այսպես.

1. **Սկզբնական վիճակ. ամեն ինչ արգելված է** (implicit deny)
2. Ստուգվում են բոլոր կիրառելի policy-ները
3. Եթե գոնե մեկում կա **explicit Deny**՝ **արգելվում է**, վերջ։ Deny-ը միշտ հաղթում է
4. Հակառակ դեպքում, եթե կա **Allow**՝ **թույլատրվում է**
5. Եթե Allow էլ չկա՝ **արգելվում է** (implicit deny)

Դասում սա կոչվում է **Deny → Allow → Deny** հոսք.

```
Explicit Deny կա՞ ──── այո ──► ԱՐԳԵԼՎԱԾ
        │ ոչ
        ▼
Explicit Allow կա՞ ──── այո ──► ԹՈՒՅԼԱՏՐՎԱԾ
        │ ոչ
        ▼
Implicit Deny ───────────────► ԱՐԳԵԼՎԱԾ
```

### Օրինակ

Bob-ը երկու policy ունի.

- Policy A. `Allow s3:GetObject` ամբողջ bucket-ի վրա
- Policy B. `Deny s3:GetObject` `bucket/secret/*`-ի վրա

Արդյունք. Bob-ը կարող է կարդալ bucket-ի ամեն ինչ, **բացի** `secret/`-ից, որովհետև Deny-ը հաղթում է։

> Սա պարզեցված տարբերակ է։ Ամբողջական տրամաբանությունը (cross-account, permission boundaries, SCP և այլն) նկարագրված է «Policy evaluation logic» փաստաթղթում (հղումը ներքևում)։

---

## 5. S3 գործողություններ և ARN-ներ (կապը Lesson 1-ի հետ)

Policy գրելիս պետք է իմանալ, որ **S3 գործողություններից մի մասը գործում է bucket-ի վրա, մյուսը՝ օբյեկտների վրա**.

| Գործողություն   | Ինչի վրա է գործում | ARN                        |
| --------------- | ------------------ | -------------------------- |
| `s3:ListBucket` | bucket             | `arn:aws:s3:::my-bucket`   |
| `s3:GetObject`  | օբյեկտ             | `arn:aws:s3:::my-bucket/*` |
| `s3:PutObject`  | օբյեկտ             | `arn:aws:s3:::my-bucket/*` |

### Readers խմբի policy-ի օրինակ

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListTheBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::my-bucket"
    },
    {
      "Sid": "ReadObjects",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

Երկու statement է պետք, որովհետև `ListBucket`-ը և `GetObject`-ը տարբեր ARN-ների վրա են գործում։

### Վերբեռնում միայն մեկ prefix-ի համար (self-study 1)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "UploadOnlyToUploadsPrefix",
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-bucket/uploads/*"
    }
  ]
}
```

Ինչպես է աշխատում. `uploads/*`-ը նշանակում է «միայն այն օբյեկտները, որոնց անունը սկսվում է `uploads/`-ով»։ Այլ տեղ վերբեռնելը կարգելվի (implicit deny)։

> `my-bucket`-ը փոխիր քո bucket-ի իրական անունով։ Ճշգրիտ գործողությունների և ARN-ների ցանկը ստուգիր **Actions, resources and condition keys for Amazon S3** էջում։

---

## 6. IAM Users

**IAM user-ը** AWS հաշվի ներսում ստեղծված ինքնություն է մարդու կամ հավելվածի համար։

### Ինչ կարող է ունենալ user-ը

- **Console գաղտնաբառ.** AWS Management Console մուտք գործելու համար
- **Access key-եր** (Access Key ID + Secret Access Key). CLI-ի, SDK-ի և API-ի համար
- **MFA սարք.** լրացուցիչ պաշտպանություն

### Հիմնական կետեր

- Նոր user-ը **ոչ մի թույլտվություն չունի** (default deny)
- User-ին թույլտվություններ տալու **լավագույն միջոցը խմբերն են**, ոչ թե policy-ի ուղղակի կցումը
- Secret Access Key-ը ցուցադրվում է **միայն ստեղծման պահին**, պահիր անվտանգ տեղում և երբեք մի դիր կոդի մեջ կամ Git-ում
- **Root հաշվով** (հաշվի ստեղծման email-ով) առօրյա աշխատանք չանել

### Ե՞րբ օգտագործել user, և երբ՝ ոչ

IAM user-ը պարզ և հասկանալի մեխանիզմ է ուսումնական նպատակների համար (ինչպես այս դասում), բայց «Security best practices in IAM»-ը խորհուրդ է տալիս մարդկանց համար ավելի ժամանակակից տարբերակներ (**IAM Identity Center**) և հավելվածների համար՝ **role-եր**՝ երկարաժամկետ access key-երի փոխարեն։ Սրանք հաջորդ դասերի թեմաներ են։

---

## 7. IAM Groups

**Group-ը** IAM user-ների հավաքածու է։ Policy-ն կցվում է **խմբին**, և խմբի բոլոր անդամները ավտոմատ ստանում են այդ թույլտվությունները։

**Օրինակ.** `aca-s3-readers` խմբին կցում ենք «կարդալ S3» policy-ն, հետո user-ներին (օրինակ՝ `armine`) ավելացնում ենք այդ խմբի մեջ։ Նոր աշխատակից է եկել՞ Ավելացնում ես խմբի մեջ, և ամեն ինչ պատրաստ է։

### Խմբերի կանոնները

- **User-ը կարող է լինել մի քանի խմբի մեջ.** թույլտվությունները **գումարվում են** (union)
- **Deny-ը շարունակում է հաղթել.** եթե որևէ խմբում կա արգելք, այն գերակայում է
- Խմբերը **չեն կարող ներդրվել** մեկը մյուսի մեջ (group-ի մեջ group չկա)
- Խումբը **ինքնություն չէ, որով կարելի է մուտք գործել**, այն միայն կազմակերպչական գործիք է
- Խումբը **չի կարելի նշել որպես principal** resource-based policy-ում

### Սահմանաչափեր (quotas)

Դասի հղումների համաձայն.

| Սահմանաչափ                        | Արժեք                              |
| --------------------------------- | ---------------------------------- |
| Խմբեր մեկ հաշվում                 | 300 (կարելի է ավելացնել մինչև 500) |
| Խմբեր մեկ user-ի համար            | 10                                 |
| Managed policy-ներ մեկ խմբի համար | 10                                 |
| User-ներ մեկ հաշվում              | 5,000                              |

> Այս թվերը կարող են փոխվել, ուստի ստուգիր «IAM and AWS STS quotas» էջում։

---

## 8. Լավագույն պրակտիկաներ (Security best practices)

- **Least privilege.** տուր միայն անհրաժեշտ թույլտվությունները, ոչ ավելին
- **Թույլտվությունները՝ խմբերի միջոցով.** ոչ թե յուրաքանչյուր user-ին առանձին
- **Միացրու MFA** user-ների համար և հատկապես root-ի համար
- **Խուսափիր `"Action": "*"` և `"Resource": "*"` համադրությունից** (նշանակում է «ամեն ինչ ամենուր»)
- **Մի օգտագործիր root հաշիվը** առօրյա աշխատանքի համար
- **Ջնջիր** չօգտագործվող user-ները և access key-երը
- Երկարաժամկետում՝ մարդկանց համար **Identity Center**, հավելվածների համար **role-եր**

---

## 9. Պրակտիկ քայլեր (Part A, B, C)

Դասի պրակտիկ մասի ընդհանուր հոսքը (Console-ով).

**A. Policy-ի ստեղծում**

1. IAM → Policies → **Create policy**
2. Ընտրիր **JSON** editor-ը և տեղադրիր policy-ի JSON-ը (օրինակ՝ readers policy-ն վերևից)
3. Տուր անուն և պահպանիր

**B. User-ի ստեղծում**

1. IAM → Users → **Create user**
2. Տուր անուն (օրինակ՝ `armine`), ընտրիր console մուտքի տարբերակը
3. Ստեղծելուց հետո **պահիր** գաղտնաբառը (մեկ անգամ ցուցադրվում է)

**C. Խմբի ստեղծում և անդամների ավելացում**

1. IAM → User groups → **Create group**, օրինակ՝ `aca-s3-readers`
2. Կցիր policy-ն խմբին
3. Ավելացրու user-ին խմբի մեջ
4. Մուտք գործիր որպես այդ user և ստուգիր՝ թույլտվությունները աշխատո՞ւմ են

### Ստուգելու գաղափարներ

- Փորձիր կարդալ օբյեկտ (պետք է հաջողվի) և ջնջել օբյեկտ (պետք է արգելվի, `AccessDenied`)
- Եթե `AccessDenied` ես տեսնում, կարդա սխալի տեքստը. այն հաճախ ասում է, թե որ գործողությունն է արգելվել և որ ռեսուրսի վրա

---

## 10. Self-study checklist

- [ ] Տուր readers խմբին վերբեռնման թույլտվություն միայն մեկ prefix-ի համար (`s3:PutObject` `bucket/uploads/*`-ի վրա)
- [ ] Ստեղծիր երկրորդ խումբ և դիր `bob`-ին **երկու** խմբի մեջ. ստուգիր նրա համակցված թույլտվությունները
- [ ] Կարդա AWS-ի **Security best practices in IAM** էջը
- [ ] Ջնջիր `bob`-ին, երբ վերջացնես. պահիր `armine`-ին և `aca-s3-readers`-ը

> Խորհուրդ. `bob`-ին ջնջելիս նախ պետք է հեռացնել նրան խմբերից և հեռացնել նրա credentials-ները (գաղտնաբառ, access key-եր), Console-ը սովորաբար այդ քայլերը առաջարկում է ինքը։

---

## 11. Հաճախ թույլ տրվող սխալներ

- **`ListBucket`-ը օբյեկտի ARN-ով.** `s3:ListBucket`-ի համար պետք է bucket-ի ARN-ը, ոչ թե `/*`-ով ARN-ը
- **Մոռանալ `/*`-ը `GetObject`-ի դեպքում.** bucket-ի ARN-ով օբյեկտները չեն կարդացվի
- **Policy-ն կցել user-ին խմբի փոխարեն.** դժվար է կառավարել, երբ user-ները շատանում են
- **Մոռանալ, որ Deny-ը հաղթում է.** մի խմբի Allow-ը չի օգնի, եթե մյուսում Deny կա
- **Չափազանց լայն թույլտվություններ** (`*`) «որ աշխատի» պատճառաբանությամբ
- **Secret key-ը Git-ում.** այդպիսի key-երը հայտնաբերվում են ավտոմատ սկաներներով և հաճախ հայտնվում հարձակվողների ձեռքում
- **Ժամանակ չտրամադրել IAM փոփոխության տարածմանը.** երբեմն փոփոխությունը մի քանի վայրկյան հետո է երևում

---

## 12. Ինքնաստուգում

1. Ինչ է ստանում նոր ստեղծված IAM user-ը՝ թույլտվությունների առումով։
2. Bob-ը երկու խմբի մեջ է. առաջինը `Allow s3:GetObject`, երկրորդը՝ `Deny s3:GetObject` նույն ռեսուրսի վրա։ Կկարողանա՞ կարդալ։
3. Ինչու են `ListBucket`-ի և `GetObject`-ի համար տարբեր `Resource` ARN-ներ պետք։
4. Ինչ տարբերություն կա customer managed և inline policy-ի միջև։
5. Կարո՞ղ է խումբը պարունակել այլ խումբ։

<details>
<summary>Պատասխաններ</summary>

1. Ոչինչ. default-ով ամեն ինչ արգելված է (implicit deny), քանի դեռ policy չի կցվել։
2. Ոչ. Explicit Deny-ը միշտ հաղթում է Allow-ին։
3. `ListBucket`-ը գործում է bucket-ի վրա (`arn:aws:s3:::my-bucket`), իսկ `GetObject`-ը՝ օբյեկտների վրա (`arn:aws:s3:::my-bucket/*`)։
4. Customer managed policy-ն առանձին ռեսուրս է, որը կարելի է կցել շատ ինքնությունների և խմբագրել մեկ տեղում։ Inline-ը ներդրված է մեկ ինքնության մեջ և ջնջվում է նրա հետ։
5. Ոչ, խմբերը չեն կարող ներդրվել։

</details>

---

## 13. Արագ ամփոփում (cheat sheet)

```
User  ──(անդամ)──►  Group  ──(կցված)──►  Policy
  │                                          │
  └──────── (կարելի է նաև ուղղակի) ──────────┘

Policy = Effect + Action + Resource (+ Condition)
Գնահատում: Explicit Deny > Explicit Allow > Implicit Deny
```

- Policy-ն JSON է. `Version`, `Statement`, `Effect`, `Action`, `Resource`
- Նոր user-ը ոչինչ չի կարող մինչև policy չկցվի
- Թույլտվությունները տուր **խմբերի** միջոցով
- Մի քանի խմբում լինելը **գումարում** է թույլտվությունները, բայց Deny-ը հաղթում է
- S3-ում bucket-ի և օբյեկտների ARN-ները տարբեր են

---

## 14. Օգտակար հղումներ

Հղումները վերցված են դասի «Useful links» էջից (ստուգված՝ 2026 թվականի հոկտեմբերին)։

### 1. Identity policies

- [Policies and permissions in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html), identity-based և resource-based policy-ներ, և ինչպես են դրանք համագործակցում
- [IAM JSON policy element reference](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements.html), Version, Statement, Sid, Effect, Action, Resource, Condition
- [Managed policies and inline policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html), AWS managed, customer managed և inline, երբ ինչ օգտագործել
- [Creating IAM policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create.html), JSON editor-ը (Part A)
- [Policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html), Deny → Allow → Deny հոսքի ամբողջական տարբերակը

### 2. IAM users

- [IAM users](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html), ինչ է IAM user-ը և երբ օգտագործել
- [Create an IAM user in your AWS account](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html), Part B-ի քայլերը

### 3. IAM groups

- [IAM user groups](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups.html), ինչ են խմբերը և ինչ չեն կարող անել
- [IAM and AWS STS quotas](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-quotas.html), սահմանաչափեր
- [Security best practices in IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html), least privilege, MFA, երբ օգտագործել Identity Center և role-եր

### 4. ARNs (Lesson 1-ից)

- [Actions, resources and condition keys for Amazon S3](https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazons3.html), որ S3 գործողություններին է պետք bucket ARN-ը և որոնց՝ օբյեկտի ARN-ը
