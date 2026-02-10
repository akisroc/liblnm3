defmodule PlatformWeb.OnboardingHTML do
  use PlatformWeb, :html

  import PlatformWeb.OnboardingComponents

  defdelegate user_form(assigns), to: PlatformWeb.OnboardingComponents
end
