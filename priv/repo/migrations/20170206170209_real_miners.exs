defmodule AditApi.Repo.Migrations.RealMiners do
  use Ecto.Migration

  def change do
    create table(:miners) do
      add :api_key, :string
      add :rate_limit, :integer
      add :rl_balance, :integer
      add :rl_window, :integer
      timestamps
    end
    create index(:miners, [:api_key])
  end
end
