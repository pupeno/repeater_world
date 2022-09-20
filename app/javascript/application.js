// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// Set up Sentry as early as possible, so any errors are caught.
import * as Sentry from "@sentry/browser";
import {BrowserTracing} from "@sentry/tracing";

if (SENTRY_DSN !== null) {
  let environment = RAILS_ENV;
  if (RENDER === "true") {
    environment = IS_PULL_REQUEST === "true" ? "review" : RAILS_ENV;
  }

  Sentry.init({
    dsn: SENTRY_DSN,
    integrations: [new BrowserTracing()],
    tracesSampleRate: 0.1, // Reduce this as the application has more traffic.
    environment: environment
  });

  if (IS_PULL_REQUEST === "true") {
    Sentry.configureScope(function (scope) {
      if (RENDER_SERVICE_NAME) {
        let pr = RENDER_SERVICE_NAME.split("-");
        pr = pr[pr.length - 1];
        scope.setTag("pr", pr);
      }
    });
  }
} else {
  if (RAILS_ENV === "production") {
    console.log("Missing SENTRY_DSN")
  }
}
// End of sentry setup.

// Make FontAwesome 6 work... but why?
// https://stackoverflow.com/questions/71430573/can-font-awesome-be-used-with-importmaps-in-rails-7
// https://discuss.rubyonrails.org/t/can-font-awesome-be-used-with-importmaps-in-rails-7/80238
import {far} from "@fortawesome/free-regular-svg-icons";
import {fas} from "@fortawesome/free-solid-svg-icons";
import {fab} from "@fortawesome/free-brands-svg-icons";
import {library} from "@fortawesome/fontawesome-svg-core";
import "@fortawesome/fontawesome-free";

library.add(far, fas, fab)
// End of FontAwesome setup

// Other imports
import "@hotwired/turbo-rails"

// And now, our code.
import "controllers"
