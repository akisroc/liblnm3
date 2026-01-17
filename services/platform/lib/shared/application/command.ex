defprotocol Platform.Shared.Application.Command do
  @spec execute(struct()) :: {:ok, map()} | {:error, any()}
  def execute(command)
end
