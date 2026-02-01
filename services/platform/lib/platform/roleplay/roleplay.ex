defmodule Platform.Roleplay do
  alias Platform.Roleplay.API.GenerateLoreName
  alias Platform.Shared.Protocols

  @doc """
  Generate a random lore name from one of the given models and
  in given bounds.

  If an empty list is given for models, the engine will pick one in
  all available models.

  Unicity of the name is checked in database.

  Race remains possible. The prophecy says that once in every century,
  one of our 23 billion users will have his generated name taken before
  he can submit the form. This cursed soul will have to generate again.
  """
  @spec generate_lore_name(GenerateLoreName.Query.t()) :: GenerateLoreName.Response.t()
  def generate_lore_name(%GenerateLoreName.Query{} = query) do
    Protocols.Query.execute(query)
  end
end
