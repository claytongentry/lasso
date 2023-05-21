defmodule Lasso.Request do
  defstruct ~w(method path)a

  @doc """
  Instantiate a request given a %Plug.Conn{}
  """
  def from_conn(%Plug.Conn{request_path: path, method: method}),
    do: %__MODULE__{method: method, path: path}
end
