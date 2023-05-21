defmodule LassoTest do
  use ExUnit.Case
  doctest Lasso

  # test "raises on unexpected request" do
  #   lasso = Lasso.open()

  #   assert_raise Lasso.UnmatchedRequestException, fn ->
  #     Req.get("http://localhost:#{lasso.port}/cat")
  #   end
  # end

  describe "verify_expectations/1" do
    test "returns :ok when no expectations have been defined" do
      lasso = Lasso.open()
      assert Lasso.verify_expectations(lasso) == :ok
    end

    test "returns :ok when all expectations are fulfilled" do
      lasso = Lasso.open()

      Lasso.expect(lasso, "GET", "/cat", &Plug.Conn.send_resp(&1, 200, "hi cat"))
      Lasso.expect(lasso, "GET", "/dog", &Plug.Conn.send_resp(&1, 200, "hi dog"))

      Req.get("http://localhost:#{lasso.port}/cat")
      Req.get("http://localhost:#{lasso.port}/dog")

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

      Req.get("http://localhost:#{lasso.port}/cat")
      assert {:error, _} = Lasso.verify_expectations(lasso)
    end
  end
end
