defmodule TodoListApp.Repo.Migrations.AddCreatorToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :creator_id, references(:users, on_delete: :delete_all)
    end

    create index(:tasks, [:creator_id])
  end
end
