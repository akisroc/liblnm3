defmodule Platform.Shared.Outbox.Infra.Persistence.Postgres.Workers.OutboxRelay do
  use GenServer
  require Logger
  import Ecto.Query

  alias Platform.Shared.Outbox.Infra.Persistence.Postgres.Repo
  alias Platform.Shared.Outbox.Infra.OutboxPublisher
  alias Platform.Shared.Outbox.Infra.Persistence.Postgres.Schemas.OutboxMessage

  @max_batch_size 10
  @max_retries 5
  @poll_interval 5_000 # milliseconds
  @notify_channel "new_outbox_message"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(state) do
    start_postgres_notifications_listener()

    # Schedule safety poll
    schedule_poll()

    {:ok, state}
  end

  @impl true
  def handle_info({:notification, _pid, _ref, @notify_channel, _payload}, state) do
    process_all_batches()
    {:noreply, state}
  end

  @impl true
  def handle_info(:poll, state) do
    process_all_batches()
    schedule_poll()
    {:noreply, state}
  end

  defp start_postgres_notifications_listener do
    with {:ok, pid}  <- Postgrex.Notifications.start_link(Repo.config()),
         {:ok, _ref} <- Postgrex.Notifications.listen(pid, @notify_channel) do
      Logger.info("[#{__MODULE__}] Listening to Postgres notifications channel: “#{@notify_channel}”")
    end
  end

  defp schedule_poll do
    Process.send_after(self(), :poll, @poll_interval)
  end

  defp process_all_batches do
    case process_one_batch() do
      count when count >= @max_batch_size -> process_all_batches()
      _                                   -> :ok
    end
  end

  @spec process_one_batch :: non_neg_integer()
  defp process_one_batch do
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
          limit: @max_batch_size,
          lock: "FOR UPDATE SKIP LOCKED"

    Repo.all(q)
  end

  @spec process_message(OutboxMessage.t()) :: {:ok, [String.t()]} | {:error, String.t()}
  defp process_message(msg) do
    result = try do
      OutboxPublisher.publish(msg)
    catch
      kind, reason -> {:error, Exception.format(kind, reason, __STACKTRACE__)}
    end

    case result do
      {:ok, consumers} -> handle_success(msg, consumers)
      {:error, reason} -> handle_failure(msg, reason)
    end
  end

  @spec handle_failure(OutboxMessage.t(), String.t()) :: any()
  defp handle_failure(msg, reason) do
    failed_msg = msg |> OutboxMessage.failed_attempt(inspect(reason))

    if failed_msg.failed_attempts >= @max_retries do
      Logger.error("[#{__MODULE__}] Poisoned message \##{failed_msg.id} abandoned after #{@max_retries} failed attempts")
      failed_msg |> OutboxMessage.close() |> Repo.update!()
    else
      Logger.warning("[#{__MODULE__}] Message \##{failed_msg.id} failed on its attempt \##{failed_msg.failed_attempts} – will retry in #{@poll_interval}ms")
      failed_msg |> Repo.update!()
    end
  end

  @spec handle_success(OutboxMessage.t(), [String.t()]) :: any()
  defp handle_success(msg, consumers) do
    msg
    |> OutboxMessage.update_consumers(consumers)
    |> OutboxMessage.mark_as_success()
    |> OutboxMessage.close()
    |> Repo.update!()

    Logger.info("[#{__MODULE__}] Outbox successfully processed message \##{msg.id}")
  end

end
