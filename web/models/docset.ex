defmodule AditApi.Docset do
  use AditApi.Web, :model
  alias AditApi.Document

  schema "docsets" do
    field :name
    field :generator
    # field :public, :boolean
    field :owner
    has_many :documents, Document
    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :generator, :owner])
    |> validate_required([:name, :generator, :owner])
  end
end
