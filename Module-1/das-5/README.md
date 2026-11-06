# AWS Cloud Engineering · Module 2 (IAM Essentials)

## Lesson 1. Amazon Resource Names (ARNs)

Այս README-ը իմ անձնական կոնսպեկտն է ARN-ների մասին՝ բացատրություններով, օրինակներով և փորձարկման առաջադրանքներով։

---

## 1. Ինչ է ARN-ը և ինչու է այն պետք

**ARN (Amazon Resource Name)** AWS-ում ցանկացած ռեսուրսի **եզակի «հասցեն»** է։

Պատկերացրու, որ AWS-ում միլիոնավոր ռեսուրսներ կան՝ S3 bucket-ներ, EC2 մեքենաներ, IAM օգտատերեր, Lambda ֆունկցիաներ։ Եթե ուզում ես ասել «**հենց այս** ռեսուրսը», անունը միշտ չէ, որ բավարար է (տարբեր հաշիվներում կամ տարբեր ռեգիոններում կարող են լինել նույն անունով ռեսուրսներ)։ ARN-ը ճշգրիտ ցույց է տալիս՝ **ո՞ր հաշվի**, **ո՞ր ռեգիոնի**, **ո՞ր ծառայության**, **ո՞ր ռեսուրսն** ենք նկատի ունենում։

**ARN է պահանջվում, երբ պետք է ռեսուրսը միանշանակ նշել ամբողջ AWS-ի մասշտաբով.**

- **IAM policy-ներում** (`Resource` դաշտ)՝ ասելու համար, թե որ ռեսուրսին է վերաբերում թույլտվությունը
- **API կանչերում** և **AWS CLI**-ում
- **Tag-երում** և այլ ծառայությունների կոնֆիգուրացիաներում (օրինակ՝ RDS)

> Պարզ անալոգիա. եթե ռեսուրսի անունը «Արամ Սարգսյան» է, ARN-ը լրիվ փոստային հասցեն է՝ երկիր, քաղաք, փողոց, շենք, բնակարան։

---

## 2. ARN-ի ընդհանուր ձևաչափը

```
arn:partition:service:region:account-id:resource
```

Բաժանարարը **երկու կետն է (`:`)**։ Ստացվում է 6 մաս։

| #   | Մաս          | Նշանակությունը                                           | Օրինակ                       |
| --- | ------------ | -------------------------------------------------------- | ---------------------------- |
| 1   | `arn`        | Միշտ նույնն է. ցույց է տալիս, որ սա ARN է                | `arn`                        |
| 2   | `partition`  | AWS-ի «բաժանմունքը», սովորաբար `aws`                     | `aws`                        |
| 3   | `service`    | AWS ծառայությունը                                        | `iam`, `s3`, `ec2`, `lambda` |
| 4   | `region`     | Ռեգիոնի կոդը (որոշ ծառայությունների համար դատարկ է)      | `us-east-1`, `eu-west-1`     |
| 5   | `account-id` | Ռեսուրսի տիրոջ AWS հաշվի 12-նիշ ID-ն՝ **առանց գծիկների** | `123456789012`               |
| 6   | `resource`   | Հենց ռեսուրսի նույնացուցիչը (անուն, ID կամ ուղի)         | `user/john`                  |

### Partition-ի արժեքներ

- `aws`՝ սովորական AWS ռեգիոններ (ամենահաճախ հանդիպողը)
- `aws-cn`՝ Չինաստանի ռեգիոններ
- `aws-us-gov`՝ AWS GovCloud (ԱՄՆ)

### Ռեսուրս մասի (6-րդ) տարբերակները

Ռեսուրս մասի գրելաձևը կախված է ծառայությունից։ Հանդիպում են երեք հիմնական ձևեր.

```
resource-id
resource-type/resource-id
resource-type:resource-id
```

Երբեմն ռեսուրսն ունի **ծնող** (`sub-resource-type/parent-resource/sub-resource`) կամ **քվալիֆիկատոր**, օրինակ՝ տարբերակ (`resource-type:resource-name:qualifier`)։

---

## 3. Օրինակներ տարբեր ծառայություններից

| Ռեսուրս         | ARN                                                           |
| --------------- | ------------------------------------------------------------- |
| IAM user        | `arn:aws:iam::123456789012:user/john`                         |
| IAM group       | `arn:aws:iam::123456789012:group/Developers`                  |
| IAM role        | `arn:aws:iam::123456789012:role/S3Access`                     |
| IAM policy      | `arn:aws:iam::123456789012:policy/UsersManageOwnCredentials`  |
| Հաշվի root      | `arn:aws:iam::123456789012:root`                              |
| S3 bucket       | `arn:aws:s3:::my-bucket`                                      |
| S3 օբյեկտ       | `arn:aws:s3:::my-bucket/photos/cat.jpg`                       |
| EC2 instance    | `arn:aws:ec2:us-east-1:123456789012:instance/i-0abc123def456` |
| Lambda ֆունկցիա | `arn:aws:lambda:us-east-1:123456789012:function:my-function`  |

> Վերջին վեց տողերի ճշգրիտ ձևաչափը կախված է ծառայությունից։ Կոնկրետ ռեսուրսի ARN-ը ստուգելու ամենահուսալի տեղը **Service Authorization Reference**-ն է (հղումները՝ ներքևում)։

### Ինչու են որոշ դաշտեր դատարկ

Նկատի՞ր `arn:aws:iam::123456789012:user/john`-ի երկու կողք-կողքի երկու կետը (`::`)։ Դա նշանակում է, որ **region-ը դատարկ է**։

- **IAM-ը գլոբալ ծառայություն է**, այն կապված չէ կոնկրետ ռեգիոնի հետ, ուստի region չկա
- **S3 bucket-ի ARN-ում** (`arn:aws:s3:::my-bucket`) դատարկ են և region-ը, և account-id-ն, քանի որ bucket-ի անունը եզակի է ամբողջ AWS-ում

Դատարկ դաշտը **չի հանվում**, միայն երկու կետը մնում է (`::`), որպեսզի դիրքերը չշեղվեն։

---

## 4. Ուղիներ (Paths) ARN-ներում

Ռեսուրսի անունը կարող է ներառել **ուղի**՝ թեք գծերով (`/`)։

- **S3-ում** օբյեկտի անունը կարող է ունենալ թեք գծեր, որոնք կազմում են «թղթապանակների» կառուցվածք (իրականում սա պարզապես անունն է)
- **IAM user և group անուններն** էլ կարող են ունենալ ուղի

```
arn:aws:iam::123456789012:user/Development/product_1234/john
arn:aws:s3:::my-bucket/reports/2026/october/summary.pdf
```

Ուղիները թույլ են տալիս ռեսուրսները կազմակերպել հիերարխիկ, օրինակ՝ `user/Development/...` և `user/Marketing/...`, և հետագայում policy-ներում թիրախավորել մի ամբողջ խումբ։

---

## 5. Wildcard-ներ (`*` և `?`)

IAM policy-ներում ARN-ի որոշ մասերում կարելի է օգտագործել wildcard.

- `*`՝ ցանկացած թվով ցանկացած նիշ
- `?`՝ մեկ ցանկացած նիշ

```
arn:aws:iam::123456789012:role/*            ← բոլոր role-երը այդ հաշվում
arn:aws:iam::123456789012:role/service-*    ← բոլոր role-երը, որոնց անունը սկսվում է service-ով
arn:aws:iam::123456789012:user/*            ← բոլոր user-ները
arn:aws:s3:::my-bucket/*                    ← bucket-ի բոլոր օբյեկտները
```

### Սահմանափակումներ

Wildcard-ը **կարելի չէ ցանկացած տեղ դնել**։ Օրինակ՝ IAM ARN-ում ծառայության մասի կամ ռեսուրսի տիպի մասի մասնակի wildcard-ը չի թույլատրվում.

```
arn:aws:iam::123456789012:u*     ← ՉԻ թույլատրվում
```

---

## 6. ARN-ը IAM policy-ում

Ամենատարածված օգտագործումը. policy-ի `Resource` դաշտում ասում ենք, թե **որ ռեսուրսի վրա** է գործում թույլտվությունը։

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

Կարդում ենք այսպես. **թույլատրվում է** (`Allow`) կարդալ օբյեկտներ (`s3:GetObject`) `my-bucket` bucket-ի **բոլոր** օբյեկտների վրա։

> Ուշադրություն. `arn:aws:s3:::my-bucket` (bucket-ը) և `arn:aws:s3:::my-bucket/*` (bucket-ի ներսի օբյեկտները) **տարբեր ռեսուրսներ են**։ Սա ամենահաճախ թույլ տրվող սխալներից մեկն է։ `s3:ListBucket` գործողությունը գործում է bucket-ի վրա, իսկ `s3:GetObject`՝ օբյեկտների վրա։

---

## 7. Ինչպես գտնել ARN-ը

1. **AWS Console.** ռեսուրսի էջում (details / summary), հաճախ կա «ARN» դաշտ՝ պատճենելու կոճակով
2. **AWS CLI.** օրինակ՝ իմանալու, թե ով եմ ես՝

   ```bash
   aws sts get-caller-identity
   ```

   Արդյունքում կտեսնես քո `Account` ID-ն և `Arn`-ը։

3. **Service Authorization Reference.** յուրաքանչյուր ծառայության էջում կա «Resource types» աղյուսակ՝ ARN-ի ձևաչափով
4. **IAM user-ի ARN-ը** կարելի է տեսնել Console → IAM → Users → ընտրել user → Summary

---

## 8. Հաճախ թույլ տրվող սխալներ

- **Account ID-ն գծիկներով գրել.** AWS account ID-ն 12 թվանշան է՝ **առանց գծիկների** (`123456789012`)
- **Region դնել IAM ARN-ում.** IAM-ը գլոբալ է, region-ը պետք է մնա դատարկ (`::`)
- **Մոռանալ `/*`-ը S3-ում.** bucket-ը և նրա օբյեկտները տարբեր ARN-եր ունեն
- **Սխալ partition.** `aws` փոխարեն օգտագործել `aws-cn` կամ հակառակը
- **Կոպի-փեյսթի ժամանակ սխալ ռեգիոն.** `us-east-1` և `eu-west-1` ռեսուրսները տարբեր են
- **Wildcard-ը չափազանց լայն դնել.** `"Resource": "*"` նշանակում է **բոլոր** ռեսուրսները, ինչը անվտանգության տեսանկյունից վտանգավոր է։ Պահպանիր **least privilege** սկզբունքը

---

## 9. Ինքնաստուգում

Վերլուծիր հետևյալ ARN-ը մասերով.

```
arn:aws:lambda:eu-west-1:210987654321:function:process-orders
```

<details>
<summary>Պատասխան</summary>

| Մաս        | Արժեք                                                                |
| ---------- | -------------------------------------------------------------------- |
| partition  | `aws`                                                                |
| service    | `lambda`                                                             |
| region     | `eu-west-1`                                                          |
| account-id | `210987654321`                                                       |
| resource   | `function:process-orders` (տիպ՝ `function`, անուն՝ `process-orders`) |

</details>

**Հարցեր**

1. Ինչու IAM ARN-ում region-ի դաշտը դատարկ է։
2. Ի՞նչ տարբերություն կա `arn:aws:s3:::data` և `arn:aws:s3:::data/*` միջև։
3. Ինչ է նշանակում `arn:aws:iam::123456789012:role/service-*`։
4. Ո՞ր 3 տեղում է պահանջվում ARN։

<details>
<summary>Պատասխաններ</summary>

1. Քանի որ IAM-ը գլոբալ ծառայություն է, այն կապված չէ կոնկրետ ռեգիոնի հետ։
2. Առաջինը հենց bucket-ն է, երկրորդը՝ bucket-ի ներսի բոլոր օբյեկտները։
3. Այդ հաշվի բոլոր role-երը, որոնց անունը սկսվում է `service-`-ով։
4. IAM policy-ներում, API կանչերում, tag-երում (և այլ ծառայությունների կոնֆիգուրացիաներում)։

</details>

---

## 10. Արագ ամփոփում (cheat sheet)

```
arn : partition : service : region : account-id : resource
 │        │          │        │          │           │
 │        │          │        │          │           └─ user/john, instance/i-..., function:name
 │        │          │        │          └─ 12 թվանշան, առանց գծիկների
 │        │          │        └─ us-east-1 ... (IAM-ի և S3-ի համար դատարկ)
 │        │          └─ iam, s3, ec2, lambda ...
 │        └─ aws (aws-cn, aws-us-gov)
 └─ միշտ "arn"
```

- ARN-ը ռեսուրսի **եզակի հասցեն** է ամբողջ AWS-ում
- Դատարկ դաշտը գրվում է որպես `::`
- `*` wildcard-ը թույլ է տալիս թիրախավորել ռեսուրսների խումբ
- Կոնկրետ ձևաչափը փնտրիր **Service Authorization Reference**-ում

---

## 11. Օգտակար հղումներ

- [Identify AWS resources with Amazon Resource Names (ARNs)](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference-arns), IAM փաստաթղթերում ARN-ի հիմնական էջը
- [IAM identifiers](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_identifiers.html), IAM-ի տարբեր նույնացուցիչները (friendly name, ARN, unique ID)
- [Service Authorization Reference](https://docs.aws.amazon.com/service-authorization/latest/reference/), յուրաքանչյուր ծառայության ռեսուրսների ARN ձևաչափերը
- [AWS ARNs and namespaces (General Reference)](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html)
- [Regional endpoints](https://docs.aws.amazon.com/general/latest/gr/rande.html#regional-endpoints), ռեգիոնների կոդերի ցանկ
