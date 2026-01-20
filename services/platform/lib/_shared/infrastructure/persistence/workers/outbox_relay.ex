defmodule Platform.Shared.Infrastructure.Outbox.Relay do
  use GenServer
  require Logger
  import Ecto.Query

  alias Platform.Shared.Infrastructure.Persistence.{Repo, OutboxDispatcher}
  alias Platform.Shared.Infrastructure.Persistence.Schemas.OutboxMessage

  @batch_size 10
  @max_retries 3
  @poll_interval 200 # milliseconds

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(state) do
    # Schedule the first poll
    schedule_poll()
    {:ok, state}
  end

  @impl true
  def handle_info(:poll, state) do
    process_batch()
    schedule_poll()
    {:noreply, state}
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp process_batch do
    Repo.transaction(fn ->
      messages = fetch_locked_batch()

      Enum.each(messages, &process_message/1)

      length(messages)
    end)
  end

  defp fetch_locked_batch do
    q = from msg in OutboxMessage,
          where: is_nil(msg.closed_at),
          order_by: [asc: msg.id],
          limit: @batch_size,
          lock: "FOR UPDATE SKIP LOCKED"

    Repo.all(q)
  end

  defp process_message(msg) do
    result = try do
      OutboxDispatcher.dispatch(msg)
    catch
      kind, reason -> {:error, Exception.format(kind, reason, __STACKTRACE__)}
    end

    case result do
      {:ok, consumers} -> handle_success(msg, consumers)
      {:error, reason} -> handle_failure(msg, reason)
    end
  end

  defp handle_failure(msg, reason) do
    failed_msg = msg |> failed_attempt(inspect(reason))

    if failed_msg.failed_attempts >= @max_retries do
      Logger.error("[#{__MODULE__}] Poisoned message \##{failed_msg.id} abandoned after #{@max_retries} failed attempts")
      failed_msg |> close() |> Repo.update!()
    else
      Logger.warning("[#{__MODULE__}] Message \##{failed_msg.id} failed on its attempt \##{failed_msg.failed_attempts} – will retry in #{@poll_interval}ms")
      failed_msg |> Repo.update!()
    end
  end

  defp handle_success(msg, consumers) do
    msg
    |> update_consumers(consumers)
    |> mark_as_success()
    |> close()
    |> Repo.update!()

    Logger.info("[#{__MODULE__}] Outbox successfully processed message \##{msg.id}")
  end

end
