# Pin npm packages by running ./bin/importmap

pin_all_from "app/javascript/controllers", under: "controllers"
pin "application", preload: true

pin "@fortawesome/fontawesome-free", to: "@fortawesome--fontawesome-free.js" # @6.6.0
pin "@fortawesome/fontawesome-svg-core", to: "@fortawesome--fontawesome-svg-core.js" # @6.6.0
pin "@fortawesome/free-brands-svg-icons", to: "@fortawesome--free-brands-svg-icons.js" # @6.6.0
pin "@fortawesome/free-regular-svg-icons", to: "@fortawesome--free-regular-svg-icons.js" # @6.6.0
pin "@fortawesome/free-solid-svg-icons", to: "@fortawesome--free-solid-svg-icons.js" # @6.6.0
pin "@googlemaps/markerclusterer", to: "@googlemaps--markerclusterer.js" # @2.5.3
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@sentry-internal/tracing", to: "https://ga.jspm.io/npm:@sentry-internal/tracing@7.57.0/esm/index.js"
pin "@sentry/browser", to: "https://ga.jspm.io/npm:@sentry/browser@7.57.0/esm/index.js"
pin "@sentry/core", to: "https://ga.jspm.io/npm:@sentry/core@7.57.0/esm/index.js"
pin "@sentry/replay", to: "https://ga.jspm.io/npm:@sentry/replay@7.57.0/esm/index.js"
pin "@sentry/tracing", to: "https://ga.jspm.io/npm:@sentry/tracing@7.57.0/esm/index.js"
pin "@sentry/utils", to: "https://ga.jspm.io/npm:@sentry/utils@7.57.0/esm/index.js"
pin "@sentry/utils/esm/buildPolyfills", to: "https://ga.jspm.io/npm:@sentry/utils@7.57.0/esm/buildPolyfills/index.js"
pin "el-transition", to: "https://ga.jspm.io/npm:el-transition@0.0.7/index.js"
pin "fast-deep-equal" # @3.1.3
pin "js-cookie", to: "https://ga.jspm.io/npm:js-cookie@3.0.5/dist/js.cookie.mjs"
pin "kdbush" # @4.0.2
pin "supercluster" # @8.0.1
pin "tslib", to: "https://ga.jspm.io/npm:tslib@2.6.0/tslib.es6.mjs"
