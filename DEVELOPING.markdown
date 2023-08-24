# Hints for how to develop changes in this repo

In order to develop changes in this repo it simplifies things to configure the
`liferay` cli to point directly at your local clone.

Assuming the absolute path to the directory for your local `liferay-localdev`
clone is stored in the environment variable `LOCALDEV_REPO` execute the
following:

```bash
liferay config set localdev.resources.dir $LOCALDEV_REPO
liferay config set localdev.resources.sync false
```

Now, you can make changes to your local clone of `liferay-localdev` and those
changes will immediately be reflected when invoking cli commands.

## Testing partials, samples and templates

When making changes to the set of partials, samples or templates it is often
useful and sometimes necessary to iterate over several invocations to ensure
proper function. The following is a recipe to achieve that.

1. Start by creating a registering a new client extension directory to work in
(this avoids breaking other client extension projects you may have).

    ```bash
    mkdir temp-client-extensions
    liferay config set extension.client-extension.dir "$(pwd)/temp-client-extensions"
    ```

1. Imagine you wish to create a new partial for the `service-springboot`
template. Plan out the operations you need to perform.

    * create the minimum resources needed for a partial

    * execute the template

    * execute the partial

    * repeat, until satisfied

    1. Start with the following folder and file structure which are the minimum
    resources required for a partial:

        ```bash
        resources/
        ├── client-extension-resources.json # add/modify details of partial
        └── partial
            └── {name} # name of the partial
                ├── append
                │   └── client-extension.yaml # if additions are needed
                └── overwrite
                    └── src
        ```

    1. Generate a one-line command which executes the `service-springboot`
    template using the wizard. At the end, rather than selecting `Create`,
    select `Just show the command`. Copy and save the command that is shown.

        e.g. `liferay ext create --noprompt -- --resource-path="template/service-springboot" --project-path="client-extensions/service-springboot" --args=package="com.company.service" --args=packagePath="com/company/service"`

    1. Execute this command one time to ensure the project is created.

    1. Generate a one-line command which executes the partial using the wizard.
    At the end, rather than selecting `Create`, select `Just show the command`. Copy and save the command that is shown.

        e.g. `liferay ext create --noprompt -- --resource-path="partial/object-action-springboot" --project-path="client-extensions/service-springboot" --args=id="my-object-action" --args=Object="MyObject" --args=package="com.company.service" --args=packagePath="com/company/service" --args=resourcePath="/myobject/action"`

    1. Execute the command one time to see the result. The linux `tree` command is ideal for reviewing the outputs of the wizard.

        e.g.

        ```bash
        cew]$ tree
        .
        └── service-springboot
            ├── build.gradle
            ├── client-extension.yaml
            ├── Dockerfile
            └── src
                └── main
                    ├── java
                    │   └── com
                    │       └── company
                    │           └── service
                    │               ├── App.java
                    │               ├── config
                    │               │   ├── AudienceValidator.java
                    │               │   ├── ClientIdValidator.java
                    │               │   └── HttpSecurityConfig.java
                    │               ├── HealthResource.java
                    │               └── MyObjectObjectAction.java
                    └── resources
                        └── application.yml

        9 directories, 10 files
        ```

    1. In order to repeat the operation delete the project `rm -rf *`.

    1. Use the following script which encompases all these operations so that you can quickly iterate:

        ```bash
        (
            rm -rf * && \
            liferay ext create --noprompt -- \
                --resource-path="template/service-springboot" \
                --project-path="client-extensions/service-springboot" \
                --args=package="com.company.service" \
                --args=packagePath="com/company/service" && \
            liferay ext create --noprompt -- \
                --resource-path="partial/object-action-springboot" \
                --project-path="client-extensions/service-springboot" \
                --args=id="my-object-action" \
                --args=Object="MyObject" \
                --args=package="com.company.service" \
                --args=packagePath="com/company/service" \
                --args=resourcePath="/myobject/action" && \
            tree
        )
        ```

1. Now that you manually tested your partial and you would to see it merged into this repo, we will need to add some tests and send a PR.

    * Edit the file `tests/functional/tiltup-new-projects.sh` and add an invocation of the CLI to create your new template + partial.

    * If you have `gh` CLI tool, its as easy as `gh pr create --base next`

    * If it passes tests and is reviewed, it will be merged into `next` and released during next release window (usually weekly).