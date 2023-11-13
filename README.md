# ProcStudio API

[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)

## FrontEnd 
[FrontEnd Here](https://github.com/brpl20/procstudio_front)

## DB
Postgres

## Hosting & Files 
- Aws EC2
- Aws S3

## Specs 
- Ruby 3.0.0
- Rails 7.0.4.2

## Install 


## Project Info 
This project was born under the premisse of helping lawyers generate documents in a easy way. Simple documents and mass documents. The original idea was only create some legal documents. Specially documents between the lawyer and it's final client. But, with the document generation we have a lot ot components to deal with (like the Customer details, and the Work details) and we need a database and a system around it. We've choosen Ruby on Rails to deal with it.

In the first phase of the developing we are working only with Lawyers and Customers documents. This will be the MVP. In the future we want create more layers of the documents.  Like documents regarding Lawyer and final documents. Mayber related to the Justice System or B2B/B2C contracts for example. The third layer will be mass documents.  

- First layer documents: Lawyer x Customers
- Second layer documents: Lawyer x Final Work (Justice or other procedures: contracts and so on).
- Third layer documents: Mass generation of documents.

As time went by, we realized that creating documents alone would be insufficient for our audience. He would still need to print the documents, call the client to sign somewhere physical. Or even the client would receive these documents by email and then have to print and then scan or deliver them to the responsible lawyer. All of this creates a lot of friction and business is lost. Therefore, it is essential that we have a signature process on the documents as well.

We are considering [DocuSeal](https://www.docuseal.co/) as an alternative for creating signatures. Paid and well-known tools like DocuSign are not viable for us and our end customers. Leveraging this hook, our niche will be lawyers with small to medium firms, who will be at an intermediate stage of their journey, looking for a viable tool to create processes and automate small daily activities.

We were also a little naive thinking that our system would generate perfect documents and at the beginning we delivered the document as a PDF. This proved to be problematic, because in our initial tests users wanted to make small (or large) changes to the final version of the document. So we also need, before generating the signature process, there is a way to review the documents online within the platform. API options with Microsoft and Google are also viable. However, these services should not be a requirement for using the system. There is no need for implementation in this MVP.

So in an ideal world the scenario we will have will be the following: A lawyer, our system user will be in a face-to-face or remote meeting with his client. They discuss matters of the specific case, agree details of the case and the fees, how the billing will be, in short, all the details of the case. Details are in the Work model. He takes advantage of this moment and enters the customer's data, a person or a company, into the system. Which will automatically send the documents to the customer according to the chosen delivery method (an email or a link). The customer will now be able to review the information and sign the document. Which will be returned to the lawyer within the system.

## What we need to do? 
We need this beta version running so we can get more tests and deliver a final and functional version. So there's some things we need to sort, I created a brief exaplanation: 

#

## Gems


## Instalação

 - Faça um clone do Projeto
 - Configure o arquivo do banco de dados
   ```config/database.yml```
 - Execute em sequência no terminal os comandos:
  ```
      bundle
      rake db:create db:migrate
      rails s
  ```
## Contribuindo
- Para abrir PRs e criar branches assim como outras informações dê uma olhada em [Contributing](CONTRIBUTING.md) 
- Cards com tasks a serem feitas [Trello](https://trello.com/b/mq2BG9nY/procstudiov2)

## Documentação da API
- Para consultar os campos [API DOC](API_DOC.md) 
