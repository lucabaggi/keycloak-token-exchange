# Keycloak Token Exchange

POC for Keycloak [token exchange](https://www.keycloak.org/docs/7.0/securing_apps/index.html#external-token-to-internal-token-exchange) functionality, based on Docker. The target is to use an access token given from an external identity provider (based on OpenID Connect v1.0 standards) to retrieve an internal access token from keycloak, thus without the needs of user credentials.
For this example, I used keycloak to simulate also the external identity provider.

## Project folder structure
The project root folder is organized as follows:
* a `docker-compose.yml` file which is used to instantiate 2 keycloak instances (called `keycloak` and `external_idp`) and a postgres db where both keycloak instances can connect, using two different schemas
* a `Makefile` useful to start and stop docker containers, and also to export keycloak realms if needed
* an `export_folder` where keycloak instances export their realms
* an `import_folder` from where keycloak instances import their realms at startup
* a `postgres_scripts` folder containing SQL scripts to initialize postgres with keycloak schemas 
* a `postman` folder containing postman collection and environment useful to test the flow


## Requirements
The requirements to run the project are:
* [Docker](https://docs.docker.com/get-docker/)
* [docker compose](https://docs.docker.com/compose/install/)
* [ngrok](https://ngrok.com/) or similar
* [Postman](https://www.postman.com/) or similar

Ngrok is a tool to expose an application running on localhost over the internet with a temporary address (in free version). This is needed as `keycloak` needs to communicate with `external_idp` on the same base url used to retrieve the external access token, otherwise an error of token issuer mismatch is thrown. This means they cannot use docker networking to communicate.

## Run the application

In order to start the application, run the command:
```
make up
```
This command will start all the docker containers defined inside `docker-compose.yml`. Administration consoles for keycloak instances are available on port 8090 (`keycloak`) and 8091 (`external_idp`), and they can be both accessed using credentials admin:admin

Once logged in admin console, you can see that `keycloak` has already a Realm named `MyApp` and also an Identity provided configured, which is linked to `external_idp`. 
Also, a realm `Bank` is present in `external_idp` instance, with a user.

To stop the application, press Ctrl+C and then run the command:
```
make down
```
to delete the stopped containers.

## Test the flow
To test the token exchange flow you can follow these steps:
1. expose `external_idp` over the internet using command ```ngrok http 8091```
2. take the temporary url given from ngrok and update all the urls in `keycloak` identity provider configuration
3. update using the same temporary url also the Postman environment variable `external_idp_endpoint`
4. retrieve external access token using `GET access token` request inside folder `external_idp` of Postman collection: this will store automatically the token inside `external_idp_access_token` env variable
5. retrieve internal access token using `GET access token` request inside folder `keycloak` of Postman collection: here token exchange is performed and an access token from `keycloak` will be returned in response

Also, you can see that the user has been created inside `MyApp` realm of `keycloak`

