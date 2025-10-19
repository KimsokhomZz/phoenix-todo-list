defmodule TodoListApp.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :string
      add :slug, :string
      # add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    # create index(:tags, [:user_id])

    create unique_index(:tags, [:slug])
    create unique_index(:tags, [:name])
  end
end
