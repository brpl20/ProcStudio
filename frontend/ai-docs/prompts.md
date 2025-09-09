# Prompts

Review: as QA and code specialist check the last commit and inspect code quality and check if there is any improvements to be done to the code be more consise, follow dry rules and software development best practices;

gaa gcam gp { follow Conventional Commits rules }

Study Svelte 5 runes at ./ai-docs/svelte-medium.txt if you can't get information there please go to: svelte-full.txt. We need to inpect OfficeForm.svelte and officeFormStore.ts to get everything working as desired. One of the key components that is not working is at lines 886 and below of OfficeForm (Lawyer Selection). When we select an lawyer, the entry should be removed on the next dropdown of lawyers, but that does not happen. My guess is at this method => getAvailableLawyersReactive I guess we actually don't need it anymore since we implemented Svelte 5 Runes mode now... Please review, thing and give me the answers before coding

User and UserProfile,


at OfficeList: src/lib/components/teams/OfficeList.svelte we have a list of offices, there is a Logo colum, but nothing is show in the Logo, it's just a placeholder can you fix this method?

First create a helper method to transform the logo from backend into a very small thumb of the logo that will fit in the table.

Secondly, make shure you are getting the logo somewhere from the API. Please befor creating any new api method inspect current api services, specially for Offices.

Check the API response for attributes logo_url ---> you will get something like this from get /offices:

/rails/active_storage/etc

maybe you will need another helper to get the final logo, let me know if you need changes in backend and I will do it. DOn't change it by yourself, your concern is only frontend

keep the current placeholder when there is no logo in the office (no response regarding go logo_url in serializer or even logo_url: null
