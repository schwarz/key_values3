defmodule KeyValues3Test do
  use ExUnit.Case
  doctest KeyValues3

  test "decode/1 the VDC example" do
    f = File.read!("test/support/vdc_example.kv3")

    assert {:ok, %{}} = KeyValues3.decode(f)
  end

  test "decode!/1 the VDC example" do
    f = File.read!("test/support/vdc_example.kv3")

    assert %{} = KeyValues3.decode!(f)
  end

  test "decode_value/1 a list" do
    assert {:ok, [1, 2, 3]} = KeyValues3.decode_value("[1,2,3,]")
  end

  test "decode_value!/1 a list" do
    assert [1, 2, 3] = KeyValues3.decode_value!("[1,2,3,]")
  end
end
