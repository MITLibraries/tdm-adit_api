defmodule AditApi.Document do
  use AditApi.Web, :model

  schema "documents" do
    field :ref
    belongs_to :docset, Docset
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:ref])
    |> validate_required([:ref])
  end
end
