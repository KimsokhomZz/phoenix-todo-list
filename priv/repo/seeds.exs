# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TodoListApp.Repo.insert!(%TodoListApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TodoListApp.{Repo, Accounts}
alias TodoListApp.Accounts.User

{:ok, _} =
  Accounts.register_user(%{
    email: "admin@example.com",
    password: "123456789",
    password_confirmation: "123456789"
  })

Repo.insert_all("tags", [
  %{name: "work", slug: "work", inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{name: "home", slug: "home", inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()},
  %{
    name: "urgent",
    slug: "urgent",
    inserted_at: DateTime.utc_now(),
    updated_at: DateTime.utc_now()
  }
])
