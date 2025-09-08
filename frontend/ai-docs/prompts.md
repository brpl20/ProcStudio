# Prompts

Review: as QA and code specialist check the last commit and inspect code quality and check if there is any improvements to be done to the code be more consise, follow dry rules and software development best practices;

gaa gcam gp { follow Conventional Commits rules }

Study Svelte 5 runes at ./ai-docs/svelte-medium.txt if you can't get information there please go to: svelte-full.txt. We need to inpect OfficeForm.svelte and officeFormStore.ts to get everything working as desired. One of the key components that is not working is at lines 886 and below of OfficeForm (Lawyer Selection). When we select an lawyer, the entry should be removed on the next dropdown of lawyers, but that does not happen. My guess is at this method => getAvailableLawyersReactive I guess we actually don't need it anymore since we implemented Svelte 5 Runes mode now... Please review, thing and give me the answers before coding
