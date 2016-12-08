defmodule AditApi.Repo.Migrations.CreateDocsDsets do
  use Ecto.Migration

  def change do
    create table(:docsets) do
      add :name, :string
      add :generator, :string
      add :owner, :string
      timestamps
    end
    create table(:documents) do
      add :ref, :string
      add :docset_id, references(:docsets, on_delete: :nothing)
    end
    create index(:documents, [:docset_id])
  end
end
