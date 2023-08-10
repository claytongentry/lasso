defmodule Lasso.Server do
  use GenServer, restart: :transient

  alias Lasso.{Expectation, Route}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    with {:ok, pid} <- Bandit.start_link(port: 0, plug: {Lasso.Plug, self()}, startup_log: false),
         {:ok, {_host, port}} <- ThousandIsland.listener_info(pid) do
      {:ok, %{pid: pid, port: port, expectations: %{}, requests: %{}, unexpected_requests: []}}
    else
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  def handle_call({:expect, expectation}, _from, state) do
    route = Route.from_expectation(expectation)
    expectations = Map.put(state.expectations, route, expectation)

    {:reply, :ok, %{state | expectations: expectations}}
  end

  @impl true
  def handle_call(:port, _from, state) do
    {:reply, state.port, state}
  end

  @impl true
  def handle_call(:verify_expectations, _from, state) do
    expectation_errors =
      Enum.reduce(state.expectations, [], fn {_route, expectation}, unfulfilled ->
        if Expectation.fulfilled?(expectation), do: unfulfilled, else: [expectation | unfulfilled]
      end)

    errors = Enum.concat(expectation_errors, state.unexpected_requests)
    reply = if Enum.empty?(errors), do: :ok, else: {:error, errors}

    {:reply, reply, state}
  end

  @impl true
  def handle_call({:request, request}, _from, state) do
    route = Route.from_request(request)
    {reply, state} = get_and_fulfill_expectation(state, route)

    {:reply, reply, state}
  end

  @impl true
  def handle_cast({:failure, request, :unexpected_request}, state) do
    {:noreply, track_unexpected_request(state, request)}
  end

  defp track_unexpected_request(state, request) do
    %{state | unexpected_requests: [request | state.unexpected_requests]}
  end

  defp get_and_fulfill_expectation(state, route) do
    expectation = Map.get(state.expectations, route)

    cond do
      is_nil(expectation) ->
        {{:error, :unexpected_request}, state}

      true ->
        expectation = Expectation.increment_request_count(expectation)
        expectations = Map.put(state.expectations, route, expectation)
        {{:ok, expectation}, %{state | expectations: expectations}}
    end
  end
end
