# concourse-deploy-pmysql

Deploy Pivotal MySQL with [omg](https://github.com/enaml-ops) in a Concourse pipeline.

## Prerequisites

1. [Git](https://git-scm.com)
1. [Vault](https://www.vaultproject.io)
1. [Concourse](http://concourse.ci)

## Steps to use this pipeline

1. Clone this repository.

    ```
    git clone https://github.com/enaml-ops/concourse-deploy-pmysql.git
    ```

1. Copy the sample properties `deployment-props-sample.json`.

    ```
    cd concourse-deploy-pmysql
    cp deployment-props-sample.json deployment-props.json
    ```

1. Edit `deployment-props.json`, adding the appropriate values.

    This file is used to populate a `vault` hash.  It holds the BOSH credentials for both `omg` (username/password) and the Concourse `bosh-deployment` (UAA client) resource.

    ```
    $EDITOR deployment-props.json
    ```

    `omg` will also read other key/value pairs added here, matching them to command-line arguments.  For example, to add the `omg` plugin parameter `--syslog-address`, you could add `"syslog-address": "10.150.12.10"` here rather than modifying the manifest generation script in `ci/tasks`.

    All available parameters/keys can be listed by querying the plugin.  If not specified in `deployment-props.json`, default values will be used where possible.

    ```
    omg-linux deploy-product p-mysql-plugin-linux --help
    ```

1. Load your deployment properties into `vault`.  `VAULT_HASH` you define here and `vault_hash_misc` in `pipeline-vars.yml` below must match.  You may consider using the `vault` hash here to hold common settings, referenced by multiple `omg`-based deployments.  In such a case, you might name the hash something like `secret/nonprod-common-props`.

    ```
    ./setup-vault.sh
    ```

1. Delete or move `deployment-props.json` to a secure location.
1. Copy the pipeline variables template.

    ```
    cp pipeline-vars-template.yml pipeline-vars.yml
    ```

1. Edit `pipeline-vars.yml`, adding appropriate values.

    ```
    $EDITOR pipeline-vars.yml
    ```

    Note: When you are deploying Pivotal MySQL, you must add your `API Token` found at the bottom of your [Pivotal Profile](https://network.pivotal.io/users/dashboard/edit-profile) page.

1. Create or update the pipeline.

    ```
    fly -t TARGET set-pipeline -p deploy-mysql -c ci/opensource-pipeline.yml -l pipeline-vars.yml
    ```

    _or_

    ```
    fly -t TARGET set-pipeline -p deploy-pmysql -c ci/pmysql-pipeline.yml -l pipeline-vars.yml
    ```

1. Delete or move `pipeline-vars.yml` to a secure location.
1. Unpause the pipeline

    ```
    fly -t TARGET unpause-pipeline -p deploy-pmysql
    ```

1. Trigger the deployment job and observe the output.

    ```
    fly -t TARGET trigger-job -j deploy-pmysql/get-product-version -w
    fly -t TARGET trigger-job -j deploy-pmysql/deploy -w
    ```

### Warnings

1. Do not name deployment with the same name with resources that you have, avoid following words: `p-mysql`, `concourse-deploy-p-mysql`, `omg-cli` and etc.
1. Pay attantion to your `az` name.
1. **Important** in your `pipeline-vars.yml` file you need to have following vallue seetted up: `vault_hash_ip: secret/pmysql-nonprod-props`.
1. you can deploy only one instance of DB using this pipeline
