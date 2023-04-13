#  LAA-Claim-non-standard-magistrate-fee
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

After you've defined your DB configuration in the above files, run the following:

* `bin/rails db:prepare` (for the development database)
* `RAILS_ENV=test bin/rails db:prepare` (for the test database)

**3. GOV.UK Frontend (styles, javascript and other assets)**

* `yarn`

**4. Run the app locally**

Once all the above is done, you should be able to run the application as follows:

a) to run 
   cd app
   rails s

If you ever feel something is not right with the CSS or JS, run `rails assets:clobber` to purge the local cache.

Tested via postman

This has now got basic swagger and rspec integration.

To test:
1. rails db:migrate (to update the database schema)
2. rails db:seed (to seed the database with dummy data)
3. rspec in the root directory to run tests (should be 21 tests)
4. rails s (to run the server)
5. open a browser goto to http://localhost:3000/api-docs/index.html(this will display swagger documentation where you should be able to test the api, the api is not finalised as it only takes a record id as input for certain operations - also getting following error Failed to fetch.
Possible Reasons:

CORS
Network Failure
URL scheme must be "http" or "https" for CORS request.)

This works via curl and postman so some config issues ? - will resolve

To read a specific id REST READ(GET)
http://localhost:3000/claims/2

To update a record
REST UPDATE(PATCH)
http://localhost:3000/claims/1?full_name="milo"

To delete a specific id
REST DELETE(DELETE)
http://localhost:3000/claims/1
