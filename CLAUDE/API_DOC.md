# Documentação da API

## Work

- profile_customer_ids(Array): Um array de ids de vários tipos de customers
- procedure(String):  administrative, judicial, extrajudicial
- number(Integer): Número do Processo
- subject(String):  administrative_subject, civil, criminal,  social_security, laborite, tributary, tributary_pis, others
- civel_area(String): family, consumer, moral_damages, só deve possuir valor se *subject* for `civil`
- social_security_areas(String): retirement_by_time, retirement_by_age, retirement_by_rural, disablement, benefit_review, administrative_services, só deve possuir valor se *subject* for `social_security`
- laborite_areas(String): labor_claim, só deve possuir valor se *subject* for `laborite`
- tributary_areas(String): asphalt, license, others_tributary , só deve possuir valor se *subject* for `tributary`
- compensations_five_years, compensations_service, lawsuit (Boolean): só deve possuir valor se *subject* for `tributary_pis`
- gain_projection(String): só deve possuir valor se *subject* for `tributary_pis`
- other_description(Text): só deve possuir valor se *subject* for `others`
- honorary_attributes(Array): um array que possui os valores de honorários de trabalho
- power_ids(Array): Um array de ids de vários poderes
- office_ids(Array): Um array de ids de vários escritórios
- profile_admin_ids(Array): Um array de vários tipos de profile_admins
- initial_atendee(Integer): Atendimento Inicial, id do profile_admin
- folder(String): Pasta
- recommendations_attributes(Array): um array que possui os valores de indicação
- documents_attributes(Array): um array que possui os valores de vários tipos de documentos
- pending_documents_attributes(Array): um array que possui os valores de vários tipos de documentos pendentes
- note(String): Notas em geral sobre o caso
- extra_pending_document(String): Outros documentos pendentes ou pendências
- tributary_files(Array): array de documentos que deve ser enviados quando *subject* for `tributary`
- physical_lawyer: Advogado Pessoa Fisica, id do profile_admin
- responsible_lawyer: Advogado responsável, id do profile_admin
- partner_lawyer: Advogado externo, id do profile_admin
- intern: Estágiários, id do profile_admin
- bachelor: Bachareis, id do profile_admin
## Honorary

- fixed_honorary_value(String): valor de honorários fixos
- parcelling_value(String): valor do parcelamento (1,2 ,3 .... etc)
- honorary_type(String):  work, success, both, bonus
- percent_honorary_value (String): Valor de honorários percentuais
- parcelling(Boolean): parcelamento
- work_id(Integer): id de trabalho

## Recommendations

- percentage(Float): Porcentagem
- commission(Float): Comissão
- profile_customer_id(Integer): id de customer
- work_id(Integer): id de trabalho

## Documents

- document_type(String): procuration, waiver, deficiency_statement
- file(File):  Arquivo de documentos, gerado automaticamente quando um documento do tipo procuração é escolhido
- work_id(Integer): id de trabalho

## Pending_documents

- description(Text)
- work_id(Integer): id de trabalho
