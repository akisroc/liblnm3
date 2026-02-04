defmodule Platform.Roleplay.Ports.SPI.LoreRepository do
  @callback reject_existing_lore_names(names :: [String.t()])
    :: [String.t()] | term()
end
