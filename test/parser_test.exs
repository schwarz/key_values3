defmodule ParserTest do
  use ExUnit.Case
  doctest KeyValues3.Parser

  test "int value" do
    assert {:ok, [1], "", _, _, _} = KeyValues3.Parser.value("1")
  end

  test "negative int value" do
    assert {:ok, [-1], "", _, _, _} = KeyValues3.Parser.value("-1")
  end

  test "float value" do
    assert {:ok, [1.1], "", _, _, _} = KeyValues3.Parser.value("1.1")
  end

  test "negative float value" do
    assert {:ok, [-1.1], "", _, _, _} = KeyValues3.Parser.value("-1.1")
  end

  test "bool value" do
    assert {:ok, [true], "", _, _, _} = KeyValues3.Parser.value("true")
    assert {:ok, [false], "", _, _, _} = KeyValues3.Parser.value("false")
  end

  test "empty string literal value" do
    assert {:ok, [""], "", _, _, _} = KeyValues3.Parser.value("\"\"")
  end

  test "string literal value" do
    assert {:ok, ["hello"], "", _, _, _} = KeyValues3.Parser.value("\"hello\"")
  end

  test "multiline string value" do
    assert {:ok, ["hello\nworld"], "", _, _, _} =
             KeyValues3.Parser.value("\"\"\"\nhello\nworld\n\"\"\"")
  end

  test "value with flag" do
    assert {:ok, [{"panorama", true}], "", _, _, _} =
             KeyValues3.Parser.value("panorama:true")
  end

  test "empty object" do
    assert {:ok, [%{}], "", _, _, _} = KeyValues3.Parser.value("{}")
  end

  test "simple object" do
    assert {:ok, [%{"n" => 5, "m" => 6}], "", _, _, _} =
             KeyValues3.Parser.value("{n = 5\n m = 6}")
  end

  test "empty list value" do
    assert {:ok, [[]], "", _, _, _} = KeyValues3.Parser.value("[]")
  end

  test "simple list value" do
    assert {:ok, [[1, 2, 3]], "", _, _, _} = KeyValues3.Parser.value("[1, 2, \n3]")
  end

  test "list with trailing comma value" do
    assert {:ok, [[1, 2]], "", _, _, _} = KeyValues3.Parser.value("[1, 2,]")
  end

  test "list in object" do
    assert {:ok, [%{"list" => [1, 2, 3]}], "", _, _, _} =
             KeyValues3.Parser.value("{\nlist = \n[1,2,\n3\n]\n}")
  end

  test "single line comment" do
    assert {:ok, ["single"], "", _, _, _} =
             KeyValues3.Parser.line_comment("// single  \n")
  end

  test "multi line comment" do
    assert {:ok, ["some\ncomment"], "", _, _, _} =
             KeyValues3.Parser.block_comment("/*  some\ncomment  */")
  end

  test "valve developer community example" do
    f = File.read!("test/support/vdc_example.kv3")

    assert {:ok,
            [
              %{
                "boolValue" => false,
                "intValue" => 128,
                "doubleValue" => 64.000000,
                "stringValue" => "hello world",
                "stringThatIsAResourceReference" =>
                  {"resource", "particles/items3_fx/star_emblem.vpcf"},
                "multiLineStringValue" =>
                  "First line of a multi-line string literal.\n" <>
                    "Second line of a multi-line string literal.",
                "arrayValue" => [1, 2],
                "objectValue" => %{"n" => 5, "s" => "foo"}
              }
            ], "", _, _,
            _} =
             KeyValues3.Parser.parse(f)
  end

  test "single quoted strings CAN have newlines" do
    f = File.read!("test/support/cases/incendiary_projectile.kv3")

    assert {:ok,
            [
              %{
                "_class" => "ability_incendiary_projectile",
                "m_nAbilityBehaviors" =>
                  "CITADEL_ABILITY_BEHAVIOR_PROJECTILE | CITADEL_ABILITY_BEHAVIOR_DISPLAYS_DAMAGE_IMPACT | CITADEL_ABILITY_BEHAVIOR_SHOW_CASTrange\n\tRANGE_AS_SAT_SPHERE_WHILE_CASTING"
              }
            ], _, _, _,
            _} =
             KeyValues3.Parser.value(f)
  end

  test "special+form keys" do
    f = File.read!("test/support/cases/alternative_rmb_lmb.kv3")

    assert {:ok, [%{}], "", _, _, _} = KeyValues3.Parser.value(f)
  end
end
