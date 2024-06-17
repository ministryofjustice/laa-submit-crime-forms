# How to reset test data

Imagine the following scenario: You have a set of submitted claims in your UAT environment, and you want to do testing on those
submitted claims in the caseworker app, approving some, RFIing others.

BUT the next day you want to be able to reset those same claims to their initial state so you can do more testing (perhaps with
different users) the next day.

We can facilitate this.

After the first round of testing is complete, the process is:

1) Clear out the data from the caseworker app
2) Clear out the data from the app store
3) In the provider app, reset the claims to their 'submitted' state, and resubmit them to the app store (which will then push them on to the caseworker app)

## 1. Clear out the caseworker app

Open up the rails console in the caseworker app

```bash
kubectl exec deploy/laa-assess-crime-forms-app -it \
        -n laa-assess-crime-forms-uat \
        -- bundle exec rails c
```

And once inside, clear out the database

```ruby
Submission.destroy_all
```

## 2. Clear out the app store

First get a rails console open

```bash
kubectl exec deploy/laa-crime-application-store-app -it \
        -n laa-crime-application-store-uat \
        -- bundle exec rails c
```

And do the same thing as caseworker:

```ruby
Submision.destroy_all
```

## 3. Reset and resubmit

Run the new rake task to reset and resubmit claims in the provider app

```bash
kubectl exec deploy/laa-submit-crime-forms-app -it \
        -c laa-submit-crime-forms \
        -n laa-submit-crime-forms-uat \
        -- bundle exec rails reset_data:claims
```
