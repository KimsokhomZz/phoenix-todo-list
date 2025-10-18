defmodule TodoListApp.Repo.Migrations.CreateTaskAssignments do
  use Ecto.Migration

  def change do
    create table(:task_assignments) do
      add :task_id, references(:tasks, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:task_assignments, [:user_id])

    create index(:task_assignments, [:task_id])
    create index(:task_assignments, [:user_id])

    create unique_index(:task_assignments, [:task_id, :user_id])

  end
end
