# Pin npm packages by running ./bin/importmap

pin_all_from "app/javascript/controllers", under: "controllers"
pin "application", preload: true

pin "@fortawesome/fontawesome-free", to: "https://ga.jspm.io/npm:@fortawesome/fontawesome-free@6.1.1/js/fontawesome.js"
pin "@fortawesome/fontawesome-svg-core", to: "https://ga.jspm.io/npm:@fortawesome/fontawesome-svg-core@6.1.1/index.es.js"
pin "@fortawesome/free-brands-svg-icons", to: "https://ga.jspm.io/npm:@fortawesome/free-brands-svg-icons@6.1.1/index.es.js"
pin "@fortawesome/free-regular-svg-icons", to: "https://ga.jspm.io/npm:@fortawesome/free-regular-svg-icons@6.1.1/index.es.js"
pin "@fortawesome/free-solid-svg-icons", to: "https://ga.jspm.io/npm:@fortawesome/free-solid-svg-icons@6.1.1/index.es.js"
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@sentry/browser", to: "https://ga.jspm.io/npm:@sentry/browser@6.19.2/esm/index.js"
pin "@sentry/core", to: "https://ga.jspm.io/npm:@sentry/core@6.19.2/esm/index.js"
pin "@sentry/hub", to: "https://ga.jspm.io/npm:@sentry/hub@6.19.2/esm/index.js"
pin "@sentry/minimal", to: "https://ga.jspm.io/npm:@sentry/minimal@6.19.2/esm/index.js"
pin "@sentry/tracing", to: "https://ga.jspm.io/npm:@sentry/tracing@6.19.2/esm/index.js"
pin "@sentry/types", to: "https://ga.jspm.io/npm:@sentry/types@6.19.2/esm/index.js"
pin "@sentry/utils", to: "https://ga.jspm.io/npm:@sentry/utils@6.19.2/esm/index.js"
pin "js-cookie", to: "https://ga.jspm.io/npm:js-cookie@3.0.1/dist/js.cookie.mjs"
pin "tslib", to: "https://ga.jspm.io/npm:tslib@1.14.1/tslib.es6.js"
