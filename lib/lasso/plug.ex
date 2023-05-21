defmodule Lasso.Plug do
  @moduledoc """
  A plug to serve requests against Lasso instances.
  """
  @behaviour Plug

  @doc false
  def init(instance) do
    instance
  end

  @doc false
  def call(conn, instance) do
    request = Lasso.Request.from_conn(conn)

    case GenServer.call(instance, {:request, request}) do
      {:ok, expectation} ->
        try do
          expectation.responder.(conn)
        catch
          class, reason ->
            stacktrace = __STACKTRACE__
            :erlang.raise(class, reason, stacktrace)
        end

      {:error, :unexpected_request} ->
        GenServer.cast(instance, {:failure, request, :unexpected_request})
        raise Lasso.UnmatchedRequestException
    end
  end
end
