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
    match = GenServer.call(instance, {:request, Lasso.Request.from_conn(conn)})

    if is_nil(match) do
      raise(Lasso.UnmatchedRequestException)
    else
      match.responder.(conn)
    end
  end
end
