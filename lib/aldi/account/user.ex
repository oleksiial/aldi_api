defmodule Aldi.Account.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :cookie, :string
    field :email, :string, null: false
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> get_cookie()
    |> validate_required([:cookie])
  end

  defp get_cookie(%Ecto.Changeset{changes: %{email: email, password: password}} = user) do
    response = HTTPoison.post!(
      "https://www.bonsai-mystery.com/qm/quest/app/login/login_a.php",
      {
          :form, [
            user: email,
            pass: password,
            cid: "58",
            qlang: "de"
          ]
      }
    )
    headers = response.headers
    loc = List.keyfind(headers, "Location", 0)
    if elem(loc, 1) == "../main/main_m.php" do
      cookie = List.keyfind(headers, "Set-Cookie", 0)
      cookie = ~r/^(.*);/
        |> Regex.run(elem(cookie, 1))
        |> Enum.at(1)

      %Ecto.Changeset{user | changes: Map.put(user.changes, :cookie, cookie)}
    else
      user
    end
  end
end
