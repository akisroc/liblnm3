defprotocol Platform.Shared.Application.Query do
  @spec execute(struct()) :: {:ok, map()} | {:error, any()}
  def execute(command)
end
