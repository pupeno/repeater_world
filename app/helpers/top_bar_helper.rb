module TopBarHelper
  def top_bar_desktop_link(*args, **kwargs, &block)
    kwargs[:class] = "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium"
    kwargs[:class_inactive] = "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700"
    kwargs[:class_active] = "border-orange-500 text-gray-900"
    kwargs[:role] = "menuitem"
    active_link_to(*args, **kwargs, &block)
  end

  TOP_BAR_DESKTOP_USER_BASE_CLASS = "block px-4 py-2 text-sm text-gray-700"
  TOP_BAR_DESKTOP_USER_INACTIVE_CLASS = ""
  TOP_BAR_DESKTOP_USER_ACTIVE_CLASS = "bg-gray-100"

  def top_bar_desktop_user_link(*args, **kwargs, &block)
    kwargs[:class] = TOP_BAR_DESKTOP_USER_BASE_CLASS
    kwargs[:class_inactive] = TOP_BAR_DESKTOP_USER_INACTIVE_CLASS
    kwargs[:class_active] = TOP_BAR_DESKTOP_USER_ACTIVE_CLASS
    kwargs[:role] = "menuitem"
    active_link_to(*args, **kwargs, &block)
  end

  def top_bar_desktop_user_button_class
    "w-full text-left #{TOP_BAR_DESKTOP_USER_BASE_CLASS}"
  end

  TOP_BAR_MOBILE_BASE_CLASS = "block pl-3 pr-4 py-2 border-l-4 text-base font-medium"
  TOP_BAR_MOBILE_ACTIVE_CLASS = "bg-orange-50 border-orange-500 text-orange-700"
  TOP_BAR_MOBILE_INACTIVE_CLASS = "border-transparent text-gray-600 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-800"

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
