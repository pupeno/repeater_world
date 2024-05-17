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

import {Controller} from "@hotwired/stimulus"
import Cookies from "js-cookie"

// The name of the cookie has the date, so any updates to the cookie policy also changes this date, causing all previous
// cookie consent to go away.
const COOKIE_NAME = "accept-cookies-2023-07-10"

export default class extends Controller {
  connect() {
    if (!Cookies.get(COOKIE_NAME)) {
      this.element.classList.remove("hidden")
    }
  }

  acceptCookies() {
    Cookies.set(COOKIE_NAME, true, {expires: 3650, sameSite: 'strict'})
    this.element.classList.add("hidden")
  }
}
