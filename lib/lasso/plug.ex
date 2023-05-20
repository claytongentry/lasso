defmodule Lasso.Plug do
  def init(instance) do
    instance
  end

  def call(conn, instance) do
    case GenServer.call(instance, {:request, Lasso.Request.from_conn(conn)}) do
      nil -> raise Lasso.UnmatchedRequestException
      match -> match.responder.(conn)
    end
  end
end
