# Development end-to-end setup


## Setup
To run all the applications in a fashion that enables a provider to submit a claim or application and then see that in the case worker app for assessment you can follow this guide.

For provider app submission you will need to ensure you have the following env vars in your `.env.development.local`. These will enable authenticated communication with the local running version of the app store. Ensure it is the `...local` version and that no secrets are inadvertently committed to the repository.

```sh
# App store credentials (for authenticating to a local app store currently)
# TODO: Oauth may be removed from local/development app store in the future
APP_STORE_CLIENT_ID=not-a-real-key
APP_STORE_CLIENT_SECRET=not-a-real-key
APP_STORE_TENANT_ID=not-a-real-key
```
Ask a dev where these can be retrieved, and do not use production versions

To receive emails to you own email address, or avoid errors on submission, you should supply the following ENV VAR
```sh
GOVUK_NOTIFY_API_KEY=not-a-real-key
```
You can generate your own "test" key (that does not send emails) or a limited key (that only sends to a controlled list of emails). You will need access to https://www.notifications.service.gov.uk/ or our existing secrets to supply this value. Ask a dev.

To login to your locally running sidekiq web user interface you will need to add these ENV vars. The values are just for your local Sidekiq webUI basic authentication. This webUI can be useful to see Job success, failure and errors.

```sh
SIDEKIQ_WEB_UI_USERNAME=sidekiq
SIDEKIQ_WEB_UI_PASSWORD=sidekiq
```

## Running e2e development stack

### Run the provider App:
  - Follow above readme to setup the development requirements

  - Amend Procfile.dev to run rails server on a unique port of your choice
    ```
      web: bin/rails server -p 3001
    ```
    *The default of 3001 is intended to work with the caseworker app's default of 3002*
  - Run the app using `bin/dev`

### Run the app store:
  - Setup the application store app as per its readme. Note that the `APP_CLIENT_ID` and `TENANT_ID` must match the values used in the provider and caseworker app's `APP_STORE_CLIENT_ID` and `APP_STORE_TENANT_ID` respectively

  - Run the app using
    ```sh
    pipenv run uvicorn laa_crime_application_store_app.main:app --reload
    ```

### Run the caseworker app:
  - Setup the app as per its readme. Note that the `APP_STORE_CLIENT_ID` and `APP_STORE_TENANT_ID` must match the values used in the provider. The `APP_STORE_CLIENT_SECRET` should be specific to the caseworker app.

  - Amend Procfile.dev to run rails server on a unique port of your choice. This port will need to be different to the provider app's, above.
    ```
    # Profile.dev
    web: bin/rails server -p 3002
    ```
    *The default of 3002 is intended to work with the provider app's default of 3001*

  - Run the app using `bin/dev`

### You should now be able to:

- Submit a claim or prior authority application in the provider app
- See a successful cron job being processed in the Sidekiq WebUI (at http://localhost/sidekiq).
- See the successful authentication and processing in the app store server output.
- See the submitted claim or application in the caseworker app list of claims or list of applications.


## Trouble shooting

- Missing translation errors in provider app

  These can be ignored by setting the following:
  ```ruby
  # config/environments/development.rb
  config.i18n.raise_on_missing_translations = false
  ```
  Note: [ticket CRM457-1183](https://dsdmoj.atlassian.net/browse/CRM457-1183) is intended to fix this

- NSM Claims (CRM7) cannot progress past the Save and submit page

  Add the GOVUK_NOTIFY_API_KEY key with a valid value to env vars
  ```ruby
  # .env.development.local
  GOVUK_NOTIFY_API_KEY=not-a-real-key
  ```

