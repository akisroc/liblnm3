defprotocol Platform.Shared.Protocols.Command do
  @spec execute(struct()) :: {:ok, map()} | {:error, any()}
  def execute(command)
end
