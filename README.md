#  LAA-Claim-non-standard-magistrate-court-fee
#  A service to apply for a claim for a  non standard magistrate fee

* Ruby version
ruby 3.2.1

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

After you've defined your DB configuration in the above files, run the following:

* `bin/rails db:prepare` (for the development database)
* `RAILS_ENV=test bin/rails db:prepare` (for the test database)

**3. GOV.UK Frontend (styles, javascript and other assets)**

* `yarn`

**4. Run the app locally**

Once all the above is done, you should be able to run the application as follows:

a) `bin/dev` - will run foreman, spawning a rails server and `dartsass:watch` to process SCSS files and watch for any changes.
b) `rails server` - will only run the rails server, usually fine if you are not making changes to the CSS.

You can also compile assets manually with `rails dartsass:build` at any time, and just run the rails server, without foreman.

If you ever feel something is not right with the CSS or JS, run `rails assets:clobber` to purge the local cache.

Mainly, the service can be fully used without any external dependencies up until the submission point, where the datastore needs to be locally running
to receive the submitted application.
Also, some functionality in the dashboard will make use of this datastore.

For active development, and to debug or diagnose issues, running the datastore locally along the Apply application is
the recommended way. Follow the instructions in the above repository to setup and run the datastore locally.

Tested via postman

to create a record
Rest create(POST)
http://localhost:3000/claims?full_name='mike hunt'&reference="1234"&tel_number ="07802329853"&email="m-hunt3@sky.com"&address_line1="29 Henry Laver"&town="colchester"&post_code="co33dq"

To read a specific id REST READ(GET)
http://localhost:3000/claims/2

To update a record
REST UPDATE(PATCH)
http://localhost:3000/claims/1?full_name="milo"

To delete a specific id
REST DELETE(DELETE)
http://localhost:3000/claims/1

This is a test for Ivan