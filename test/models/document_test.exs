defmodule AditApi.DocumentTest do
  use AditApi.ModelCase, async: true
  alias AditApi.Document

  @valid_attrs %{ref: "http://example.com/resource"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Document.changeset(%Document{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Document.changeset(%Document{}, @invalid_attrs)
    refute changeset.valid?
  end
end
