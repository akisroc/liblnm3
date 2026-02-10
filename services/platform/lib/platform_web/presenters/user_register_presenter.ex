defimpl PlatformWeb.Protocols.Presentable, for: Platform.IAM.Ports.API.RegisterUserResponse do
  def to_view_model(response, :onboarding) do
    %{
      user: response.user,
      errors: response.errors
    }
  end
end
