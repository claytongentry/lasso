defmodule Lasso.Server do
  use GenServer, restart: :transient

  alias Lasso.Expectation

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    with {:ok, pid} <- Bandit.start_link(port: 0, plug: {Lasso.Plug, self()}, startup_log: false),
         {:ok, %{port: port}} <- ThousandIsland.listener_info(pid) do
      {:ok, %{pid: pid, port: port, expectations: %{}, requests: []}}
    else
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  def handle_call({:expect, expectation}, _from, state) do
    expectations =
      Map.put(state.expectations, {expectation.method, expectation.path}, expectation)

    {:reply, :ok, %{state | expectations: expectations}}
  end

  @impl true
  def handle_call(:port, _from, state) do
    {:reply, state.port, state}
  end

  @impl true
  def handle_call(:verify_expectations, _from, state) do
    counts =
      Enum.reduce(state.requests, %{}, fn request, tallies ->
        Map.update(tallies, {request.method, request.path}, 1, &(&1 + 1))
      end)

    errors =
      Enum.reduce(state.expectations, [], fn {_req, expectation}, unfulfilled ->
        verified? = Expectation.verify(expectation, state.requests, counts)
        if verified?, do: unfulfilled, else: [expectation | unfulfilled]
      end)

    response = if Enum.empty?(errors), do: :ok, else: {:error, errors}
    {:reply, response, state}
  end

  @impl true
  def handle_call({:request, request}, _from, state) do
    match = Map.get(state.expectations, {request.method, request.path})
    {:reply, match, %{state | requests: [request | state.requests]}}
  end
end
