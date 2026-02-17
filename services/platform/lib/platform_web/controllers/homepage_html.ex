defmodule PlatformWeb.HomepageHTML do
  use PlatformWeb, :html

  import PlatformWeb.HomepageComponents

  defdelegate homepage(assigns), to: PlatformWeb.HomepageComponents
end
