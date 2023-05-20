defmodule Lasso.Expectation do
  defstruct ~w(method path responder)a

  def match(expectation, requests) do
    if verify(expectation, requests), do: expectation
  end

  def verify(%__MODULE__{} = expectation, requests) when is_list(requests) do
    Enum.any?(requests, &verify_request(&1, expectation))
  end

  defp verify_request(request, expectation) do
    expectation.method == request.method && expectation.path == request.path
  end
end
