defmodule LassoTest do
  use ExUnit.Case
  doctest Lasso

  describe "verify_expectations/1" do
    test "returns :ok when no expectations have been defined" do
      lasso = Lasso.open()
      assert Lasso.verify_expectations(lasso) == :ok
    end

    test "returns :ok when all expectations are fulfilled" do
      lasso = Lasso.open()

      Lasso.expect(lasso, "GET", "/cat", &Plug.Conn.send_resp(&1, 200, "hi cat"))
      Lasso.expect(lasso, "GET", "/dog", &Plug.Conn.send_resp(&1, 200, "hi dog"))

      get("http://localhost:#{lasso.port}/cat")
      get("http://localhost:#{lasso.port}/dog")

      assert Lasso.verify_expectations(lasso) == :ok
    end

    test "returns an error when not all expectations are fulfilled" do
      lasso = Lasso.open()

      # Override the default on_exit callback so that we can inspect the
      # return value of verify_expectations/1
      ExUnit.Callbacks.on_exit({Lasso, lasso.pid}, fn ->
        Lasso.verify_expectations(lasso)
      end)

      Lasso.expect(lasso, "GET", "/cat", &Plug.Conn.send_resp(&1, 200, "hi cat"))
      Lasso.expect(lasso, "GET", "/dog", &Plug.Conn.send_resp(&1, 200, "hi dog"))

      get("http://localhost:#{lasso.port}/cat")
      assert {:error, _} = Lasso.verify_expectations(lasso)
    end

    test "returns an error when receiving an unexpected request" do
      lasso = Lasso.open()
      get("http://localhost:#{lasso.port}/cat")

      # Override the default on_exit callback so that we can inspect the
      # return value of verify_expectations/1
      ExUnit.Callbacks.on_exit({Lasso, lasso.pid}, fn -> nil end)

      assert {:error, _} = Lasso.verify_expectations(lasso)
    end
  end

  defp get(url) do
    Req.get(url, max_retries: 0)
  end
end
