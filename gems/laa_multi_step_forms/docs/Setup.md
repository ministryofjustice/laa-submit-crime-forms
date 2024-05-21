# LAA Multi Step Form setup instriuctions

These instructions are designed to allow you to start a new project
using using the multi step form engine as a base

## 1. Configurations Steps

### 1. Install the gem(s)

As gemspec files are not able to point to a github repo and both of the gems below
need to be added:

```
gem 'laa_multi_step_forms', path: 'gems/laa_multi_step_forms'
```

### 2. Add the node modules

The following Node modules are required - simply add them to the Package.json

```
"@ministryofjustice/frontend": "1.6.4",
"govuk-frontend": "5.0.0",
"accessible-autocomplete": "^2.0.4",
```

### 2. Setup CSS files

To allow autoloading of the default MOJ and GDS stylesheets these are loaded with
the GEM itself, add the following to `application.css`:

```
@import "laa_multi_step_forms/base";
```

NOTE: this assumes the use of dart-css to compile the stylesheets. In order to
correctly access the compiled stylesheets you need to add the following to
the `manifest.js`:

```
//= link_tree ../builds
```

## 2. Trouble shooting

> Please update as issues are encountered
