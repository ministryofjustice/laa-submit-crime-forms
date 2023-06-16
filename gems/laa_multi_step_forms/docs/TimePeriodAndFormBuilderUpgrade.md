# TimePeriod Object and Form Builder Upgrade

These notes relate to the TimePeriod component which has created based
on the GovUK FormBuilder Date component.

Due to this dependency upgrading the GovUK FormBuilder gem can result in
the TimePeriod component having errors. This document is here to help users
step through this process.

## Assumptions

1. The repository is using Dependabot so upgrades to the GovUK FormBuilder
gem are identified quickly,
2. Once updates to the gem are identified the TimePeriod component is updated
in a timely manner
3. We will eventually move the TimePeriod component into the main GovUK
FormBuilder gem and remove these issues as dependencies

## What is the TimePeriod Component and what is it based on

The component is made up of 4 main parts plus the associated testing

1. `IntegerTimePeriod` class

This is a wrapper for an Integer object whihc also exposes methods for
hours and minutes. It expects the integer it receieve to be the total
number of minutes for the given period.

2. `TimePeriod` type

This is used to convert values that are passed into the corresponding
`ActionModel` object.

It is expecting either an Integer or a Hash with the appriate keys and
converts that into either a `IntegerTimePeriod` object if it's valid or
forward the object (hHsh) if it's invalid.

3. `TimePeriodValidator`

Used to validate the output of the type, meaning it can accept eitehr
a `IntegerTimePeriod` or hash with appropriate keys. This allows better
error messaging when the hash is invalid.

The validator is capable for additing multiple errors to the object,
however by default the GovUK error output only displays the first error,
as such the ordering of errors being added is important.

4. The form build class `GOVUKDesignSystemFormBuilder::Elements::Period`

This class is a copy of the Date component, modified to support hours
and minutes. This class is likely to be the main issue during any upgrade
as it relies directly on various modules from the GovUK FormBuilder gem.

This element can render either a `IntegerTimePeriod` instance or hash
with appropriate keys.

## Upgrading

Upgrading the GovUK FormBuilder will potentially require changes to
the following files, as the underlying modules or interfaces have
chnaged during the upgrade:

1. `GOVUKDesignSystemFormBuilder::Elements::Period` class
2. `GOVUKDesignSystemFormBuilder::Elements::Period` tests

The proposed approach for upgrade is to diff the above files against
the matching `Date` component files from the gem in the current version
to understand what changes have been made.

The diff the versions of the `Date` component to see what if anything has
chnaged as a result of the upgrade.

From here it is down to the user to take the appropriate action and ensure
the component continues to function.
