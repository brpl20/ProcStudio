# ProcStudio API
- [![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
- API Reference [API DOC](API_DOC.md) and ```public\openapi.yaml```

## FrontEnd 
[FrontEnd Repo](https://github.com/brpl20/procstudio_front)

## DB
- Postgres
- You can check DB Schema Here ====> /public/DER_Procstudio_v2.mwb

## Hosting & Files 
- Aws EC2
- Aws S3

## Specs 
- Ruby 3.0.0
- Rails 7.0.4.2

## Project Description  
This project was born under the premisse of helping lawyers generate documents in a easy way. Simple documents and mass documents. The original idea was only create some legal documents. Specially documents between the lawyer and it's final client. But, with the document generation we have a lot ot components to deal with (like the Customer details, and the Work details) and we need a database and a system around it. We've choosen Ruby on Rails to deal with it.

In the first phase of the developing we are working only with Lawyers and Customers documents. This will be the MVP. In the future we want create more layers of the documents.  Like documents regarding Lawyer and final documents. Mayber related to the Justice System or B2B/B2C contracts for example. The third layer will be mass documents.  

- First layer documents: Lawyer x Customers
- Second layer documents: Lawyer x Final Work (Justice or other procedures: contracts and so on).
- Third layer documents: Mass generation of documents.

As time went by, we realized that creating documents alone would be insufficient for our audience. He would still need to print the documents, call the client to sign somewhere physical. Or even the client would receive these documents by email and then have to print and then scan or deliver them to the responsible lawyer. All of this creates a lot of friction and business is lost. Therefore, it is essential that we have a signature process on the documents as well.

We are considering [DocuSeal](https://www.docuseal.co/) as an alternative for creating signatures. Paid and well-known tools like DocuSign are not viable for us and our end customers. Leveraging this hook, our niche will be lawyers with small to medium firms, who will be at an intermediate stage of their journey, looking for a viable tool to create processes and automate small daily activities.

We were also a little naive thinking that our system would generate perfect documents and at the beginning we delivered the document as a PDF. This proved to be problematic, because in our initial tests users wanted to make small (or large) changes to the final version of the document. So we also need, before generating the signature process, there is a way to review the documents online within the platform. API options with Microsoft and Google are also viable. However, these services should not be a requirement for using the system. There is no need for implementation in this MVP.

So in an ideal world the scenario we will have will be the following: A lawyer, our system user will be in a face-to-face or remote meeting with his client. They discuss matters of the specific case, agree details of the case and the fees, how the billing will be, in short, all the details of the case. Details are in the Work model. He takes advantage of this moment and enters the customer's data, a person or a company, into the system. Which will automatically send the documents to the customer according to the chosen delivery method (an email or a link). The customer will now be able to review the information and sign the document. Which will be returned to the lawyer within the system.

## Install 
- Clone
- Configure DB ```config/database.yml```
- Run: ```rails staging:setup```

## Models 
Brief explanation of the main Models (/models):

1. Admin: Central users of the platform, those who will use the system. They will be the lawyers who use the system. It is directly related to the ProfileAdmin, which will store all data and determine other attributes, such as whether they are a lawyer, paralegal, intern, secretary, accountant (?), or external accountant (?). It may seem strange, but here in Brazil, we have some situations where it is important to have an accountant working alongside a lawyer. The word was incorrectly translated into English. The term "counter" means a user who will have powers similar to a lawyer. The "excounter" will be an accountant with limited powers, usually only to monitor the work of their clients, typically in tax cases that require specific knowledge of tax calculations. Additionally, there are attributes such as "status," "civil_status," and others. There is an error that will be discussed shortly in the logic between the lawyer and the office.

**Code Repair:** There's a error in the code at `models/profile_admin.rb : line 4` that has set the optional option as `true`. In fact, really an Admin, lawyer or any other system user will have access to the system without the need of being attached to an office. This is due the fact that a individual lawyer can work on it's own with need an office in fact. #TODO-BACK#1

So we need to fix this, otherwise the initial seed won't work and the system won't be able to start running, because it needs and Office before the user (admin). So we always will need a systema that allow an individual user to register and configure it's own Office.

We need to setup the users permissions because inside the Admin we will have those layers of users (/profile_admin.rb). #TODO-BACK#2

Also excounter (external aaccountant) is not being created when needs to be created. #TODO-BACK#3

Finally, `ProfileAdmin` is related with some models to create nested attributes: `admin_addressses, admin_phones, admin_emails, admin_bank_accounts, profile_admin_works`

Please also check User Permissions.

2. Customer: The lawyer's client who will use our platform. The Customer also has access to the system, where they can consult data from their cases, download documents, and check the work being done by the lawyer/office. Customer will be created when they information is setup in the system. An e-mail will be generated and they will receive a simple access. They do not have and route to access the system, the permissions are not set up #TODO-BACK#4 and the front is not ready #TODO-FRONT#1.

3. Document: The model used to create documents. At this moment, these documents are related to Works, which will be discussed next in the SERVICES.

4. Honorary: When creating a work, it's important to set up the honorary amount that customers will be charged. There are four types of fees: Work (fixed rate), Success (% of gains), Both (both ways), and Bonus (Free pro bonus).

5. Job: A job is a small action that one of the system users will perform. It can be linked to a Work, which is a more comprehensive task, or it can be a standalone task related to a client. Many clients, before finalizing a deal and before the work officially begins, may need some basic tasks, consultations, or simple research. We always need to register at least one client and one responsible party. This is where much of the task delegation will occur, for example, from a lawyer to a paralegal.

6. JobWork: Connection between a job and a work. This is used when the job is linked to a specific task within a larger project, breaking down the work into smaller activities to facilitate the overall process.

7. Office: The office to which the lawyer is attached. Remember we can have a Lawyer that uses the system without an office. The offices can also have one or multiple lawyers.

8. Pending Document: This model is only a checklist of the pending documents. Probably we will add a notification in the future to remember the client to send us the pending documents.

9. Power: Power is related to the authority the lawyer has on a specific work regarding the representation of the customer. At the model file (/models/power.rb) you will find the specific category of the Powers. And the rake file will create the specific powers ```lib/tasks/powers.rake```. You will be able to check the powers at Work/new. Some of them are equal so right now, you will probably see repeated lines as we do not have the logic done. #TODO-FRONT#2

10. Profiles (admin/admin_work/customer): The profile where we input all specific data about the relation models.

11. Represent: "Representante" is when a person cannot act on their own behalf, by their own will. Usually, it refers to people who do not have all their mental faculties (relatively incapable) or people with no capacity at all (absolutely incapable). Companies also need to be represented by a partner who is an individual.

12. Work: Works are related to Client These are tasks that the office will execute for the client. Within each work, there can be various "jobs."

13. Recommendation: People that have association with the lawyers and will send clints to the Lawyer and will receive an certain amount of money to the "recommendation".

14. /filters: Just helpers to filter some information attached to the models.

15. /services/customers: Only in testing mode. Create a Customer and a CustomerProfile to access the system and look for information.

16. /services/generate_docs: Docs Generation. Takes a template file from aws bucket and replace according to the information. I think this model is not used. This is the first version of the Docx Gem. Probably here only for consulting. Please check Services regarding to the document generation.

17. /serializers: Api Serializers

18. Other models not mentioned: address, bank, email, phone and other just informational models.


### User Permissions => role and status (#TODO-BACK#5)
role: and status: are the main fields of the admin, this will be helpful to set up the system permissions, acording to each profile:

1. lawyer: more access (full crud)
2. paralegal: less access (some restrictions will be applyed)
3. trainee: less access (view only)
4. secretary: less access (some restrictions will be applyed)
5. counter: this will be accessed by
6. excounter:

#### Lawyer Access
**Lawyer Full Admin:** The main and first Admin of the system. Will be able to have full access to it, FULL CRUD. 
- CRUD: Admins, Offices, Customers, Works, Jobs, GenerateDoc's

**Lawyer Level 1:** The second lawyer in the hierarchy, will be able to have the following crud options: 
- CRUD: Offices, Customers, Works, Jobs, GenerateDocs. 

#### Paralegal Access and Lawyer Level 2
Paralegal will be the lawyers assistants, will help in the daily routine, will have the following powers: 

- CRU: Customers. 
- D: Under supervision of Admin(lawyers): Customers. 
- CRUD: Works, Jobs, GenerateDocs. Destroy only what is created by _self_. If is from others will need permission from Admin(laywer) - Full Admin or Lawyer Level 1. 

#### Trainee
Helps the Lawyers and the paralegals in the deaily routines. 

- CR: Customers (cannot read or update :bank_details), Works, Jobs, GenerateDocs 
- UD: Customers, Works, Jobs, GenerateDocs, Only: created by _self_. 
- UD: Customers, Works, Jobs, GenerateDocs from other users, only with permission from Admins, Lawyers and Paralegals.  

#### Secretary 
Schedule apointments, meetings and helps the team in general.

- CR: Customers (cannot update :bank_details), Works, Jobs, GenerateDocs 
- UD: Customers, Works, Jobs, GenerateDocs, Only: created by _self_. 
- UD: Customers, Works, Jobs, GenerateDocs from other users, only with permission from Admins, Lawyers and Paralegals. 

#### Counter / accountant
The accountant is an specific user that is a accountant, sometimes they help the lawyers with some cases, so it's important that they have access to the system. 

- CRU customers
- CRU works => Only tributary -- PERDCOMP 
    - http://localhost:3000/cadastrar?type=trabalho
    - Create an specific route that will have access to only this kind of work: 
        - Tributário Pis/Cofins 
- CRU jobs related to the specific works 

#### Excounter / external accountant 
Sometimes the company has an accountant that whants follow up the works from the lawyers office, so we created a simplified view to this kind of users.  
- R: Specific Client/Work attached to it: 
    * List view INDEX
    * View by :id 


## Services Details => Document Generation
- ```profile_customers and works```

This service creates documents, which are the main part of the system. Currently, they are divided between documents related to "profile_customers" and "works." When we create a customer profile, the system automatically generates a simple procuration of attorney, only for consultation purposes. It includes basic initial information about the client and the lawyer and office (if it's ok), which are pre-configured.

Subsequently, when a work is registered, a new procuration of attorney is generated. This document contains more data and offers greater customization options. In addition to the power of attorney, some other documents are also generated.

We need to review the entire service and address outstanding issues, including integrating ActiveStorage with S3. #TODO-BACK#6 #TODO-BACK#7

Currently, the powers of attorney are being generated with templates directly from a file on the server. This solution proves to be faster but more challenging to manage.

I believe the ideal approach is to have a basic master template on AWS and then some customized templates for clients. We need to think of solutions to make template changes simple and to implement new documents in the system in the same straightforward manner.

Another issue is how to list and access these documents easily and quickly, as well as the destruction of these documents when they are no longer needed.

```template_documents``` The Document template.

We use ```docx``` gem for [this](https://github.com/ruby-docx).

We will also need to correct defects and imperfections in the document, a kind of final review. This should be implemented because not all fields will always be perfect. It is always advisable to have a final review by the lawyer regarding this. This is still a solution that has not been considered. #TODO-BACK#8

## API Review #TODO-BACK#11
Many issues and inconsistencies in the API, including errors related to API names and fields.

### Customer Person
- The INSS password is not being saved
- Email in the contact section is also not saving

### Customer Company
- Sends all fields, but not all of them are received in the GET request. (Verify if the data is being saved)

### Work
- Sends all fields, but not all of them are received in the GET request. (Verify if the data is being saved)


## What we need to do after all?

### Backend #TODO-BACK#ALL
We need this beta version running so we can get more tests and deliver a final and functional MVP version. So there's some things we need to sort, I created a brief explanation: 

1. Fix relation problem between Admin and Offices.
```
The first problem you will notice is that when the seeds are created, they come with two Offices or more. This is due an error in the relationship database. We have at line 15 a belongs to with an exception, wich, does not work. We need to fix it because it's NOT required that an Lawyer need to be attached to an Office. He can practice law by himself as a person. And in the first time he will make the login to test our plataform he will not want a system that requires an office to make a longin (long time to fill all the required information).
```

2. SetUp Users Permissions;

3. Create externalcounter user and profile;

4. services/customers:
  * Fix ActionMailer
  * Create Customer Route
  * Create Customer and CustomerProfile when Customer is Created
  * Send email to Customer
  * Adjust API
  * Adjust Front
  * Create CustomerProfile and send an e-mail to Customer.

5. Create Admin Permissions
  * Adjust Api to Front

6. Fix/Setup ActiveStorage AWS S3

7. Review Services => Document Generation

8. Create a step when the Admin can review and make changes to the document.

9. SetUp an Signature Service (please check project description) and study possible changes in the backend.

10. Review Authentication: Login, Registration, Password Retrieve etc.

11. API Review: Review Saved data and get data. Review if fields are matching. Review serializers. Create new endpoints regarding the issues above.

12. Fix tests. For instance, Powers in test files are not working anymore, because we created the seeds.

13. Review Error messages

14. Checkout missing translations


### FrontEnd #TODO-FRONT#ALL
1. Create Customer FrontEnd

2. Create logic between Works/new and Powers;

3. Adjust Permissions




