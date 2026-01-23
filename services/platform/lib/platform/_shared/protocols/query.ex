defprotocol Platform.Shared.Protocols.Query do
  @spec execute(struct()) :: {:ok, map()} | {:error, any()}
  def execute(command)
end
