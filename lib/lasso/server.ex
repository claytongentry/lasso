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
      {:ok, %{pid: pid, port: port, expectations: [], requests: []}}
    else
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  def handle_call({:expect, expectation}, _from, state) do
    expectations = [expectation | state.expectations]
    {:reply, :ok, %{state | expectations: expectations}}
  end

  @impl true
  def handle_call(:port, _from, state) do
    {:reply, state.port, state}
  end

  @impl true
  def handle_call(:verify_expectations, _from, state) do
    failures =
      Enum.reduce(state.expectations, [], fn expectation, failures ->
        verified? = Expectation.verify(expectation, state.requests)
        if verified?, do: failures, else: [expectation | failures]
      end)

    response = if Enum.empty?(failures), do: :ok, else: {:error, failures}
    {:reply, response, state}
  end

  @impl true
  def handle_call({:request, request}, _from, state) do
    match = Enum.find_value(state.expectations, &Expectation.match(&1, [request]))
    requests = [request | state.requests]

    {:reply, match, %{state | requests: requests}}
  end
end
