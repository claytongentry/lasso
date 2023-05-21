defmodule Lasso.Expectation do
  defstruct ~w(method path responder times)a

  def verify(%__MODULE__{} = expectation, requests, counts) when is_list(requests) do
    with true <- verify_times(expectation, counts) do
      Enum.any?(requests, &verify_request(&1, expectation))
    end
  end

  defp verify_request(request, expectation) do
    expectation.method == request.method && expectation.path == request.path
  end

  defp verify_times(%__MODULE__{times: nil}, _counts), do: true

  defp verify_times(%__MODULE__{method: method, path: path, times: times}, counts) do
    times == Map.fetch!(counts, {method, path})
  end
end
