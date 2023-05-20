defmodule Lasso.UnmatchedRequestException do
  defexception message: "No expectation matched the incoming request."
end
