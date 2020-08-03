## Open Policy Agent: opa-rbac

This is an example defines an Role-based Access Control (RBAC) model for a Blog API using [Open Policy Agent](https://www.openpolicyagent.org/) and Rego as a Language. This is to demonstrate all possible features of Rego and its test cases while writing RBAC APIs for Blog Application.

# [Running OPA](https://www.openpolicyagent.org/docs/latest/#running-opa)

Follow the instruction on OPA official website by clicking [here](https://www.openpolicyagent.org/docs/latest/#running-opa)

# `opa run` (server)

```shell
$ ./opa run --server
```

It will run OPA server on port 8181

- `export my postman apis`: https://www.getpostman.com/collections/d299fd2bfd0b35387004
- If not than you can run all apis using `curl` command as follows

# Follow steps to run all OPA REST API using curl command

- `Create/Update Policy`: Update your policy rego rules using opa rest api. upload my [rbac.rego](https://github.com/ashutoshSce/opa-rbac/blob/master/rbac.rego) file here

```shell
$ curl --location --request PUT 'http://localhost:8181/v1/policies/rbac' \
--header 'Content-Type: text/plain' \
--data-binary '@rbac.rego'
```

- `Create/Update Data`: Update your policy data using opa rest api. upload my [data.json](https://github.com/ashutoshSce/opa-rbac/blob/master/data.json) file here

```shell
$ curl --location --request PUT 'http://localhost:8181/v1/data/cnapp/rbac' \
--header 'Content-Type: application/json' \
--data-binary '@data.json'
```

- `Get Data`: Get all your data in given package name (here we are using `cnapp/rbac` as package name in [rbac.rego](https://github.com/ashutoshSce/opa-rbac/blob/master/rbac.rego) policy file).

```shell
$ curl --location --request GET 'http://localhost:8181/v1/data/cnapp/rbac'
```

- `Execute Boolean Policy: allow`: check whether given input user has given input grants
  based on my policy [data.json](https://github.com/ashutoshSce/opa-rbac/blob/master/data.json), It should return true as result. Add input as different user, roles and permission based on [data.json](https://github.com/ashutoshSce/opa-rbac/blob/master/data.json) and check your expected result.

```shell
$ curl --location --request POST 'http://localhost:8181/v1/data/cnapp/rbac/allow' \
--header 'Content-Type: application/json' \
--data-raw '{
    "input": {
        "user": "raghu"
    }
}'
```

Response

```json
{
  "result": true
}
```

```shell
$ curl --location --request POST 'http://localhost:8181/v1/data/cnapp/rbac/allow' \
--header 'Content-Type: application/json' \
--data-raw '{
    "input": {
        "user": "ashutosh",
        "action": "comment",
        "type": "post"
    }
}'
```

Response

```json
{
  "result": true
}
```

- `Add data dynamically`: Add data based on requirement on demand. It uses [JSON PATCH](http://jsonpatch.com/).
  Example: Adding here blacklist same grant in above example for user `ashutosh`.

```shell
$ curl --location --request PATCH 'http://localhost:8181/v1/data/cnapp/rbac' \
--header 'Content-Type: application/json' \
--data-raw '[
    {
        "op": "add",
        "path": "/blacklist",
        "value": {
            "ashutosh": [
                {
                    "action": "comment",
                    "type": "post"
                }
            ]
        }
    }
]'
```

- `Execute Boolean Policy: not allow if blacklisted grants`: check whether given input user has given input grants
  based on my policy [data.json](https://github.com/ashutoshSce/opa-rbac/blob/master/data.json), It should return false as we have blacklisted this grants in above example for user `ashutosh`.

```shell
$ curl --location --request POST 'http://localhost:8181/v1/data/cnapp/rbac/allow' \
--header 'Content-Type: application/json' \
--data-raw '{
    "input": {
        "user": "ashutosh",
        "action": "comment",
        "type": "post"
    }
}'
```

Response

```json
{
  "result": false
}
```

- `Execute Array List of Policy`: you can also get results as array, or objects, of mix datatype in rego. Here we wants list of users who has `admin` role.

```shell
$ curl --location --request POST 'http://localhost:8181/v1/data/cnapp/rbac/who_are' \
--header 'Content-Type: application/json' \
--data-raw '{
    "input": {
        "role": "admin"
    }
}'
```

Response

```json
{
  "result": ["raghu"]
}
```

- Similarly we have other policy examples like `who_all_are`, `roles_can`, `users_can`. Run as rest api using different input and data.

# Run all policy test cases using OPA test command

```shell
$ ./opa test -v rbac.rego rbac_test.rego
```

# License

This project is licensed under [MIT](https://github.com/ashutoshSce/opa-rbac/blob/master/LICENSE).
