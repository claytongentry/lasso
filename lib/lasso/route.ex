defmodule Lasso.Route do
  @moduledoc """
  A utility module for serializing routes from requests and expectations.
  """

  @doc """
  Serialize a route tuple from a request.
  """
  def from_request(%Lasso.Request{method: method, path: path}),
    do: {method, path}

  @doc """
  Serialize a route tuple from an expectation.
  """
  def from_expectation(%Lasso.Expectation{method: method, path: path}),
    do: {method, path}
end
