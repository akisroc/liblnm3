defmodule PlatformWeb.SplashpageHTML do
  use PlatformWeb, :html

  # import PlatformWeb.SplashpageComponents

  defdelegate splashpage(assigns), to: PlatformWeb.SplashpageComponents
end
