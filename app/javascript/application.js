/* Copyright 2023-2024, Pablo Fernandez
 *
 * This file is part of Repeater World.
 *
 * Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
 * Public License as published by the Free Software Foundation, either version 3 of the License.
 *
 * Repeater World is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied 
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more 
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
 * <https://www.gnu.org/licenses/>.
 */

// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// Set up Sentry as early as possible, so any errors are caught.
import * as Sentry from "@sentry/browser"
import {BrowserTracing} from "@sentry/tracing"
// Make FontAwesome 6 work... but why?
// https://stackoverflow.com/questions/71430573/can-font-awesome-be-used-with-importmaps-in-rails-7
// https://discuss.rubyonrails.org/t/can-font-awesome-be-used-with-importmaps-in-rails-7/80238
import {far} from "@fortawesome/free-regular-svg-icons"
import {fas} from "@fortawesome/free-solid-svg-icons"
import {fab} from "@fortawesome/free-brands-svg-icons"
import {library} from "@fortawesome/fontawesome-svg-core"
import "@fortawesome/fontawesome-free"
// Other imports
import "@hotwired/turbo-rails"

// And now, our code.
import "controllers"

if (SENTRY_DSN !== null) {
  let environment = RAILS_ENV
  if (RENDER === "true") {
    environment = IS_PULL_REQUEST === "true" ? "review" : RAILS_ENV
  }

  Sentry.init({
    dsn: SENTRY_DSN,
    integrations: [new BrowserTracing()],
    tracesSampleRate: 0.1, // Reduce this as the application has more traffic.
    environment: environment
  })

  if (IS_PULL_REQUEST === "true") {
    Sentry.configureScope(function (scope) {
      if (RENDER_SERVICE_NAME) {
        let pr = RENDER_SERVICE_NAME.split("-")
        pr = pr[pr.length - 1]
        scope.setTag("pr", pr)
      }
    })
  }
} else {
  if (RAILS_ENV === "production") {
    console.log("Missing SENTRY_DSN")
  }
}
// End of sentry setup.

library.add(far, fas, fab)
// End of FontAwesome setup
