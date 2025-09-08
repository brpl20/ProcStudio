# Prompts

Review: as QA and code specialist check the last commit and inspect code quality and check if there is any improvements to be done to the code be more consise, follow dry rules and software development best practices;

gaa gcam gp { follow Conventional Commits rules }

Study Svelte 5 runes at ./ai-docs/svelte-medium.txt if you can't get information there please go to: svelte-full.txt. We need to inpect OfficeForm.svelte and officeFormStore.ts to get everything working as desired. One of the key components that is not working is at lines 886 and below of OfficeForm (Lawyer Selection). When we select an lawyer, the entry should be removed on the next dropdown of lawyers, but that does not happen. My guess is at this method => getAvailableLawyersReactive I guess we actually don't need it anymore since we implemented Svelte 5 Runes mode now... Please review, thing and give me the answers before coding

Inspect: src/lib/components/teams/OfficeForm.svelte . Inspect this request when creating an Office (using u5@gmail.com / pass: 123456), please note that the nested attributes are coming empty. And the association between the lawyers is also not coming to the request for fullfill the backend propperly. I think we can make this form better removing the logic of processing all this data inside the own form, maybe use another file and export the data to it or something like that... we have /schemas/customer-form.ts that can be used as reference. Or thinking in the Svelte 5 way, acting like a professional senior developer if you have something else in your scope please let me know....
Empty fields =>
"addresses": [],
"phones": [],
"emails": [],
"bank_accounts": [],

      No relationship fields =>

      The form should bring the partnership fields to we PUT in the backend creating the association between multiple lawyers and the society

Content-Disposition: form-data; name="office[name]"

Chancellor Schmidt
dContent-Disposition: form-data; name="office[cnpj]"

89.292.966/8563-09
dContent-Disposition: form-data; name="office[oab_id]"

Perspiciatis autem
dContent-Disposition: form-data; name="office[oab_status]"

In provident recusa
dContent-Disposition: form-data; name="office[oab_inscricao]"

Soluta ut aute sed i
dContent-Disposition: form-data; name="office[oab_link]"

https://www.xiqej.ws
dContent-Disposition: form-data; name="office[society]"

company
dContent-Disposition: form-data; name="office[foundation]"

2013-02-23
dContent-Disposition: form-data; name="office[site]"

https://www.wuhoka.tv
dContent-Disposition: form-data; name="office[accounting_type]"

simple
dContent-Disposition: form-data; name="office[quote_value]"

7
dContent-Disposition: form-data; name="office[number_of_quotes]"

595
dContent-Disposition: form-data; name="office[phones_attributes]"

[{"phone_number":"(19) 19546-5219"}]
dContent-Disposition: form-data; name="office[addresses_attributes]"

[{"street":"Rua Paraná","number":"3033","complement":"Ed. Formato 14 Andar","neighborhood":"Centro","city":"Cascavel","state":"PR","zip_code":"85810-010","address_type":"main"}]
dContent-Disposition: form-data; name="office[emails_attributes]"

[{"email":"dicujizu@mailinator.com"}]
dContent-Disposition: form-data; name="office[bank_accounts_attributes]"

[{"bank_name":"Nu Pagamentos S.A.","type_account":"Corrente","agency":"001","account":"3010901930","operation":"","pix":"19195465219","bank_number":"260"}]
dContent-Disposition: form-data; name="office[zip_code]"

85810-010
dContent-Disposition: form-data; name="office[user_offices_attributes]"

[{"user_id":128,"partnership_type":"socio","partnership_percentage":"70","pro_labore_amount":1518,"is_managing_partner":true,"_destroy":false},{"user_id":129,"partnership_type":"socio","partnership_percentage":"30","pro_labore_amount":1518,"is_managing_partner":true,"_destroy":false}]
Content-Disposition: form-data; name="office[profit_distribution]"

proportional
Content-Disposition: form-data; name="office[create_social_contract]"

true
Content-Disposition: form-data; name="office[partners_with_pro_labore]"

true
------WebKitFormBoundarySZU1XStXmKzTLEuj--

📥 Received Response from Target: 201 /api/v1/offices
📋 Response Headers:
content-type: application/json; charset=utf-8
content-length: 849
cache-control: max-age=0, private, must-revalidate
etag: W/"008c04d656d684311cd6dc69561b4891"
📦 Response Body (849 bytes):
{
"success": true,
"message": "Escritório criado com sucesso",
"data": {
"id": "22",
"type": "office",
"attributes": {
"name": "Chancellor Schmidt",
"cnpj": "89292966856309",
"site": "https://www.wuhoka.tv",
"quote_value": "7.0",
"number_of_quotes": 595,
"total_quotes_value": "4165.0",
"logo_url": "/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBEdz09IiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--48a048eef56591d396371d15b4c8ba442df204ba/LOGO.png",
"social_contracts_with_metadata": [],
"society": "company",
"foundation": "2013-02-23",
"addresses": [],
"phones": [],
"emails": [],
"bank_accounts": [],
"works": [],
"accounting_type": "simple",
"oab_id": "Perspiciatis autem ",
"oab_inscricao": "Soluta ut aute sed i",
"oab_link": "https://www.xiqej.ws",
"oab_status": "In provident recusa",
"formatted_total_quotes_value": "R$ 4165,00",
"city": null,
"state": null,
"deleted": false
}
}
}
