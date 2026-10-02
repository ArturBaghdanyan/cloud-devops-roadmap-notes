# ☁️ Cloud & DevOps IAM (Identity & Access Management) — Guide & Notes

> **IAM Cloud-ում** — Համակարգ է, որը վերահսկում է, թե **ՈՎ** (Identity) ի՞նչ **ԻՐԱՎՈՒՆՔՆԵՐՈՎ** (Permissions) կարող է կատարել ի՞նչ **ԳՈՐԾՈՂՈՒԹՅՈՒՆՆԵՐ** (Actions) Cloud-ի որևէ **ՌԵՍՈՒՐՍԻ** (Resources) վրա։

---

## 📌 1. Հիմնական Հասկացությունները (Core Identities)

Cloud-ում (օրինակ՝ AWS / GCP / Azure) IAM-ը աշխատում է հետևյալ բաղադրիչներով.

1. **Root User / Account Owner**
   - Ամենազոր օգտատերը, որը ստեղծվում է Cloud Account բացելիս։
   - ⚠️ **Best Practice:** Չօգտագործել ամենօրյա գործերի համար։ Միացնել 2FA/MFA և պահել անվտանգ տեղում։

2. **Users (Օգտատերեր)**
   - Իրական մարդիկ (DevOps, Developers, Admins), ովքեր մուտք են գործում Cloud Console կամ CLI:

3. **Groups (Խմբեր)**
   - Օգտատերերի միավորում։ Իրավունքները տրվում են խմբին, ոչ թե անհատ օգտատիրոջը (օր.՝ `Devs-Group`, `DevOps-Group`, `Auditors-Group`):

4. **Roles / Service Accounts (Դերեր / Ծառայության հաշիվներ)**
   - **Ժամանակավոր իրավունքներ:** Տրվում են ոչ թե մարդկանց, այլ **Cloud ծառայություններին** (օր.՝ EC2 սերվերին, Lambda-ին, Kubernetes Pod-ին) կամ այլ Account-ներին։
   - ❌ **Bad Practice:** API Key-երը կամ Access Key-երը hardcode անել EC2/Code-ի մեջ։
   - ✅ **Good Practice:** Attach անել IAM Role համապատասխան resource-ին։

---

## 🛡️ 2. Policies & Permissions (Քաղաքականություններ)

IAM Policy-ն JSON փաստաթուղթ է, որը սահմանում է թույլտվությունները։

### 📄 Policy-ի կառուցվածքը (AWS Example):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow", // Allow կամ Deny
      "Action": [
        // Ինչ գործողություն (Read, Write, Delete)
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::my-company-bucket/*" // Որ ռեսուրսի վրա
    }
  ]
}
```

## ⚙️ 3. DevOps & Cloud IAM Best Practices

Principle of Least Privilege (PoLP): Տալ միայն այն նվազագույն իրավունքները, որոնք անհրաժեշտ են տվյալ աշխատանքը կատարելու համար (ոչ մի \* wildcard production-ում)։

1. Enforce MFA: Բոլոր իրական օգտատերերի համար պարտադիր դարձնել Multi-Factor Authentication:

2. Rotate Credentials: Ավտոմատացնել API Key-երի և Access Key-երի պարբերական փոխարինումը։

3. Use Roles for Automation (CI/CD): GitHub Actions-ի, GitLab CI-ի կամ Terraform-ի համար օգտագործել IAM Roles (OIDC-ի միջոցով)՝ երկարաժամկետ Secret Key-եր չպահելու համար։

4. Audit & Monitoring: Հետևել լոգերին (օր.՝ AWS CloudTrail)՝ հասկանալու համար, թե ով, երբ և ինչ գործողություն է արել Cloud-ում։
