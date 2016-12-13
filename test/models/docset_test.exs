defmodule AditApi.DocsetTest do
  use AditApi.ModelCase, async: true
  alias AditApi.Docset

  @valid_attrs %{name: "Masters EECS 1960-70", generator: "{}", owner: "rlr"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Docset.changeset(%Docset{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Docset.changeset(%Docset{}, @invalid_attrs)
    refute changeset.valid?
  end
end
