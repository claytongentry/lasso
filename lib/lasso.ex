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
          Process.exit(pid, :shutdown)
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
        raise error_module, render_failure_messages(failures)
    end
  end

  def expect(lasso, method, path, responder) do
    expectation = %__MODULE__.Expectation{
      method: method,
      path: path,
      responder: responder,
      request_count: 0,
      expected_request_count: :one_or_more
    }

    GenServer.call(lasso.pid, {:expect, expectation})
  end

  defp render_failure_messages(failures) do
    failures
    |> Enum.map(&render_failure_message/1)
    |> Enum.join("\n")
  end

  defp render_failure_message(%Lasso.Request{method: method, path: path}) do
    "Unexpected #{method} request to #{path}"
  end

  defp render_failure_message(%Lasso.Expectation{
         method: method,
         path: path,
         expected_request_count: n,
         request_count: m
       }) do
    "Expected #{n} call(s) to #{method} #{path}, received #{m}."
  end
end
