# Liferay Localdev Release Process

## Prerequistes

- Install `gh` cli from github

## How to Release

- Merge all PRs to `next`
- Make sure all issues and PRs are labeled in github with upcoming milestone to be released
- From Github UI open a PR from `next` to `main`
- Make sure all tests pass
- *NOTE*: Don't merge main from github UI, it doesn't fast-forward correctly, instead do it locally
- Exec `git checkout next && git pull --ff-only upstream next`
- Exec `git checkout main && git pull --ff-only upstream main`
- Make sure you are on `main` branch and execute `git merge --ff-only next`
- Tag `main` branch with milestone tag: `git tag v20221107`
- Push `main` branch: `git push --tags upstream main`
- Release from tag `gh release create v20221107 --generate-notes`
- Run `git show main` and `git show next` and confirm they are exact same SHA
- Also if you look at the PR you opened in Github, you will notice its auto-closed (since we fastforwarded main from next locally and pushed)

Happy releasing!