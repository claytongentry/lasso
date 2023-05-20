defmodule Lasso do
  @moduledoc """
  Documentation for `Lasso`.
  """

  defstruct ~w(pid port)a

  @doc """
  Instantiate a Lasso server to field HTTP requests.
  """
  def open(opts \\ []) do
    case DynamicSupervisor.start_child(Lasso.Supervisor, Lasso.Server.child_spec(opts)) do
      {:ok, pid} ->
        lasso = %Lasso{pid: pid, port: GenServer.call(pid, :port)}

        ExUnit.Callbacks.on_exit({__MODULE__, pid}, fn ->
          verify_expectations!(lasso, ExUnit.AssertionError)
        end)

        lasso

      {:error, reason} ->
        raise "Failed to start Lasso server: #{inspect(reason)}"
    end
  end

  def verify_expectations(lasso) do
    GenServer.call(lasso.pid, :verify_expectations)
  end

  def verify_expectations!(lasso, error_module) do
    case verify_expectations(lasso) do
      :ok ->
        :ok

      {:error, failures} ->
        raise error_module, "Unmet expectations: #{inspect(failures)}"
    end
  end

  def expect(lasso, "GET", path, responder) do
    expectation = %__MODULE__.Expectation{
      method: "GET",
      path: path,
      responder: responder
    }

    GenServer.call(lasso.pid, {:expect, expectation})
  end
end
