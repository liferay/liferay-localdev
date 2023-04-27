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
- Make sure you are on `main` branch and execute `(test "$(git symbolic-ref --short HEAD)" = "main" && git merge --ff-only next) || echo "Failed: current branch is not main"`
- Export RELEASE_TAG var: `export RELEASE_TAG=v20230427`
- Tag `main` branch with milestone tag: `git tag $RELEASE_TAG`
- Push `main` branch: `git push --tags upstream main`
- Release from tag `gh release create $RELEASE_TAG --generate-notes`
- Run `git show main` and `git show next` and confirm they are exact same SHA
- Also if you look at the PR you opened in Github, you will notice its auto-closed (since we fastforwarded main from next locally and pushed)

Happy releasing!