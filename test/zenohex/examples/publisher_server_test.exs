defmodule Zenohex.Examples.PublisherTest do
  use ExUnit.Case

  alias Zenohex.Examples.Publisher
  alias Zenohex.Examples.Subscriber
  alias Zenohex.Sample

  setup do
    {:ok, session} = Zenohex.open()
    key_expr = "key/expression/pub"
    start_supervised!({Publisher, %{session: session, key_expr: key_expr}})

    %{session: session}
  end

  describe "put/1" do
    test "with subscriber", %{session: session} do
      me = self()

      start_supervised!(
        {Subscriber.Server,
         %{
           session: session,
           key_expr: "key/expression/**",
           callback: fn sample -> send(me, sample) end
         }}
      )

      for i <- 0..100 do
        assert Publisher.put(i) == :ok
        assert_receive %Sample{key_expr: "key/expression/pub", kind: :put, value: ^i}
      end
    end
  end

  describe "delete/0" do
    test "with subscriber", %{session: session} do
      me = self()

      start_supervised!(
        {Subscriber.Server,
         %{
           session: session,
           key_expr: "key/expression/**",
           callback: fn sample -> send(me, sample) end
         }}
      )

      assert Publisher.delete() == :ok
      assert_receive %Sample{key_expr: "key/expression/pub", kind: :delete}
    end
  end

  test "congestion_control/1" do
    assert Publisher.congestion_control(:block) == :ok
    assert Publisher.put("put") == :ok
  end

  test "priority/1" do
    assert Publisher.priority(:real_time) == :ok
    assert Publisher.put("put") == :ok
  end
end
