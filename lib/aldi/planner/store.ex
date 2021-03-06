defmodule Aldi.Planner.Store do
  use Ecto.Schema
  import Ecto.Changeset


  schema "stores" do
    field :address, :string
    field :test_id, :integer
    field :is_done, :boolean, default: false

    belongs_to :user, Aldi.Account.User

    timestamps()
  end

  def parse_store(body) do
    test_id =
      ~r/Test ID: ([0-9]+)/
      |> Regex.run(body)
      |> Enum.at(1)
      |> String.to_integer()

    address =
      ~r/<div class='text text-muted'>(.*) <\/div><div class='text'>zu testende/
      |> Regex.run(body)
      |> Enum.at(1)

    %{
      test_id: test_id,
      address: address
    }
  end

  @doc false
  def changeset(store, attrs) do
    store
    |> cast(attrs, [:address, :test_id, :is_done])
    |> validate_required([:address, :test_id])
  end
end
