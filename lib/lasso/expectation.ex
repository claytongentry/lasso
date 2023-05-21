defmodule Lasso.Expectation do
  defstruct ~w(
    method
    path
    responder
    expected_request_count 
    request_count
  )a

  def increment_request_count(expectation) do
    %__MODULE__{expectation | request_count: expectation.request_count + 1}
  end

  def fulfilled?(%__MODULE__{expected_request_count: :one_or_more, request_count: n}) when n >= 1,
    do: true

  def fulfilled?(%__MODULE__{expected_request_count: n, request_count: n}), do: true
  def fulfilled?(_expectation), do: false

  def fetch(expectation, key) do
    Map.fetch!(expectation, key)
  end

  def get_and_update(expectation, key, fun) do
    {value, expectation} = Map.pop(expectation, key)
    {value, Map.put(expectation, key, fun.(value))}
  end
end
