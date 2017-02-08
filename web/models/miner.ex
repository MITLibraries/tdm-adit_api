defmodule AditApi.Miner do
  use AditApi.Web, :model

  schema "miners" do
    field :api_key
    field :rate_limit, :integer
    field :rl_balance, :integer
    field :rl_window, :integer
    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:api_key, :rate_limit, :rl_balance, :rl_window])
    |> validate_required([:api_key, :rate_limit, :rl_balance, :rl_window])
  end
end
