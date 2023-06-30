# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Repeater World is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

module TopBarHelper
  def top_bar_desktop_link(*args, **kwargs, &block)
    kwargs[:class] = <<-CLASSES
      inline-flex items-center px-1 pt-1 border-b-2 font-medium 
      focus:ring-inset focus:outline-none focus:ring-2 focus:ring-orange-500
    CLASSES
    kwargs[:class_inactive] = <<-CLASSES
        border-transparent text-gray-500 hover:text-gray-800 focus:text-gray-800 hover:border-gray-800 focus:border-gray-800
        dark:text-gray-400 dark:hover:text-gray-200 dark:focus:text-gray-200 dark:hover:border-gray-200 dark:focus:border-gray-200
    CLASSES
    kwargs[:class_active] = "border-orange-500 text-gray-900 dark:text-gray-100"
    kwargs[:role] = "menuitem"
    active_link_to(*args, **kwargs, &block)
  end

  TOP_BAR_DESKTOP_EXTRA_BASE_CLASS = "block px-6 py-4 border-l-4 font-medium dark:text-gray-100"
  TOP_BAR_DESKTOP_EXTRA_INACTIVE_CLASS = <<-CLASSES
    border-transparent text-gray-600 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-800 
    dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:border-gray-500 dark:hover:text-gray-400"
  CLASSES
  TOP_BAR_DESKTOP_EXTRA_ACTIVE_CLASS = <<-CLASSES
    bg-orange-50 border-orange-500 text-orange-700
    dark:bg-orange-950 dark:text-orange-300
  CLASSES

  def top_bar_desktop_extra_link(*args, **kwargs, &block)
    kwargs[:class] = TOP_BAR_DESKTOP_EXTRA_BASE_CLASS
    kwargs[:class_inactive] = TOP_BAR_DESKTOP_EXTRA_INACTIVE_CLASS
    kwargs[:class_active] = TOP_BAR_DESKTOP_EXTRA_ACTIVE_CLASS
    kwargs[:role] = "menuitem"
    active_link_to(*args, **kwargs, &block)
  end

  def top_bar_desktop_extra_button_class
    "w-full text-left #{TOP_BAR_DESKTOP_EXTRA_BASE_CLASS} #{TOP_BAR_DESKTOP_EXTRA_INACTIVE_CLASS}"
  end

  TOP_BAR_MOBILE_BASE_CLASS = "block pl-3 pr-4 py-4 border-l-4 font-medium"
  TOP_BAR_MOBILE_INACTIVE_CLASS = <<-CLASSES
    border-transparent text-gray-600 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-800 
    dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:border-gray-500 dark:hover:text-gray-400"
  CLASSES
  TOP_BAR_MOBILE_ACTIVE_CLASS = <<-CLASSES
    bg-orange-50 border-orange-500 text-orange-700
    dark:bg-orange-950 dark:text-orange-300
  CLASSES

  def top_bar_mobile_link(*args, **kwargs, &block)
    kwargs[:class] = TOP_BAR_MOBILE_BASE_CLASS
    kwargs[:class_inactive] = TOP_BAR_MOBILE_INACTIVE_CLASS
    kwargs[:class_active] = TOP_BAR_MOBILE_ACTIVE_CLASS
    kwargs[:role] = "menuitem"
    active_link_to(*args, **kwargs, &block)
  end

  def top_bar_mobile_button_class
    "w-full text-left #{TOP_BAR_MOBILE_BASE_CLASS} #{TOP_BAR_MOBILE_INACTIVE_CLASS}"
  end
end
