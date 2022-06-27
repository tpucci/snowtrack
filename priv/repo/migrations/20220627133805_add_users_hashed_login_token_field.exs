defmodule Snowtrack.Repo.Migrations.AddUsersLoginTokenField do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :hashed_login_token, :binary
    end
  end
end
