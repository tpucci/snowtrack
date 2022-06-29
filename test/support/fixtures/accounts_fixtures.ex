defmodule Snowtrack.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Snowtrack.Accounts` context.
  """

  import Ecto.Changeset

  alias Snowtrack.Accounts.User
  alias Snowtrack.Repo

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def valid_user_login_token, do: "that's a good login token!"
  def valid_confirmed_at, do: ~U[2019-10-31 19:59:03Z]

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      login_token: valid_user_login_token(),
      confirmed_at: valid_confirmed_at()
    })
  end

  def user_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> valid_user_attributes()

    {:ok, user} =
      %User{}
      |> User.registration_changeset(attrs)
      |> cast(attrs, [:confirmed_at])
      |> Repo.insert()

    {:ok, user} =
      user
      |> Snowtrack.Accounts.update_login_token(valid_user_attributes(attrs))

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
