defmodule Platform.Shared.Outbox.Infra.Persistence.Postgres.Workers.OutboxCleaner do
  @moduledoc """
  GenServer that periodically cleans up obsolete messages from outbox.
  """

  import Ecto.Query
  use GenServer
  require Logger

  alias Platform.Shared.Outbox.Infrastructure.Persistence.Repo
  alias Platform.Shared.Outbox.Infra.Persistence.Schemas.OutboxMessage

  @retention_days 7
  @batch_size 2000

  @cleanup_interval :timer.hours(12)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Schedule the first cleanup
    schedule_cleanup()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:cleanup, state) do
    cleanup()
    schedule_cleanup()
    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @cleanup_interval)
  end

  defp cleanup do
    threshold = DateTime.utc_now() |> DateTime.add(-@retention_days, :day)

    q = from msg in OutboxMessage,
          where: msg.closed_at < ^threshold,
          limit: @batch_size

    case Repo.delete_all(q) do
      {@batch_size, _} ->
        Logger.info("[#{__MODULE__}] Cleaned #{@batch_size} obsolete messages from outbox")
        cleanup()

      {0, _} ->
        Logger.info("[#{__MODULE__}] No obsolete message to clean up from outbox")
        :ok

      {count, _} ->
        Logger.info("[#{__MODULE__}] Cleaned #{count} obsolete messages from outbox")
        :ok
    end
  end
end
