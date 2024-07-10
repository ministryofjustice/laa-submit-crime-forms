#  LAA-Claim-non-standard-magistrate-court-fee
#  A service to apply for a claim for a  non standard magistrate fee

* Ruby version
ruby 3.3.4

* Rails version
rails 7.0.42.0

## Getting Started

Clone the repository, and follow these steps in order.
The instructions assume you have [Homebrew](https://brew.sh) installed in your machine, as well as use some ruby version manager, usually [rbenv](https://github.com/rbenv/rbenv). If not, please install all this first.

**1. Pre-requirements**

* `brew bundle`
* `gem install bundler`
* `bundle install`

**2. Configuration**

* Copy `.env.development` to `.env.development.local` and modify with suitable values for your local machine
* Copy `.env.test` to `.env.test.local` and modify with suitable values for your local machine

```
# amend database url to use your local superuser role, typically your personal user
DATABASE_URL=postgresql://postgres@localhost/laa-submit-crime-forms-dev
=>
DATABASE_URL=postgresql://john.smith@localhost/laa-submit-crime-forms-dev
```

After you've defined your DB configuration in the above files, run the following:

* `bin/rails db:prepare` (for the development database)
* `RAILS_ENV=test bin/rails db:prepare` (for the test database)

**3. GOV.UK Frontend (styles, javascript and other assets)**

* `yarn`

**4. ClamAV Virus Scanning**

We utilise [ClamAV](https://www.clamav.net/) and [Clamby](https://github.com/kobaltz/clamby) within this
application to scan files before saving them to ensure that they are clear of malware where possible. The
brewfile above will install ClamAV on your system but will not configure it. Run the following script to
both brew install clamav (if needed) and configure for use with this app.

```shell
bin/install_clamav_on_mac
```

**5. Run the app locally**

Once all the above is done, you should be able to run the application as follows:

a) `bin/dev` - will run foreman, spawning a rails server and `yarn build --watch` to process JS/SCSS files and watch for any changes.
b) `rails server` - will only run the rails server, usually fine if you are not making changes to the CSS.

You can also compile assets manually with `rails yarn build`/`rails yarn build:css` at any time, and just run the rails server, without foreman.

If you ever feel something is not right with the CSS or JS, run `rails assets:clobber` to purge the local cache.

Mainly, the service can be fully used without any external dependencies up until the submission point, where the datastore needs to be locally running
to receive the submitted application.
Also, some functionality in the dashboard will make use of this datastore.

For active development, and to debug or diagnose issues, running the datastore locally along the Apply application is
the recommended way. Follow the instructions in the above repository to setup and run the datastore locally.

**6. Sidekiq Auth**

We currently protect the sidekiq UI on production servers (Dev, UAT, Prod, Dev-CRM4) with basic auth.

In order to extract the password from the k8s secrets run the following commands:

> NOTE: this requires your kubectl to be setup and [authenticated](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/kubectl-config.html#authenticating-with-the-cloud-platform-39-s-kubernetes-cluster) as well as having [`jq`](https://jqlang.github.io/jq/download/) installed.

```bash
NAMESPACE=laa-submit-crime-forms-dev

kubectl config use-context live.cloud-platform.service.justice.gov.uk
# username
kubectl get secret sidekiq-auth -o jsonpath='{.data}' --namespace=$NAMESPACE | jq -r '.username' | base64 --decode && echo " "
# password
kubectl get secret sidekiq-auth -o jsonpath='{.data}' --namespace=$NAMESPACE | jq -r '.password' | base64 --decode && echo " "
```

**7. Documentation**

Documentation related to the below components is available in the `gems/laa_multi_step_forms/docs/` folder on the following items:

* [DSLDecisionTree](gems/laa_multi_step_forms/docs/DSLDecisionTree.md)
* [Setup](gems/laa_multi_step_forms/docs/Setup.md)
* [Steps](gems/laa_multi_step_forms/docs/Steps.md)
* [TaskList](gems/laa_multi_step_forms/docs/TaskList.md)
* [Validations](gems/laa_multi_step_forms/docs/Validations.md)
* [Javascript_Test](gems/laa_multi_step_forms/docs/Javascript_Test.md)
* [SharedForms](gems/laa_multi_step_forms/docs/SharedForms.md)
* [Suggestion](gems/laa_multi_step_forms/docs/Suggestion.md)
* [TimePeriodAndFormBuilderUpgrade](gems/laa_multi_step_forms/docs/TimePeriodAndFormBuilderUpgrade.md)


**8. Tests**

To run the test suite, run `bundle exec rspec`.
This will run everything except for the accessibility tests, which are slow, and by default only run on CI.
To run those, run `INCLUDE_ACCESSIBILITY_SPECS=true bundle exec rspec`.
Our test suite will report as failing if line and branch coverage is not at 100%.
We expect every feature's happy path to have a system test, and every screen to have an accessibility test.

**9. Development end-to-end setup**

see [Development e2e setup](docs/development-e2e-setup.md)
