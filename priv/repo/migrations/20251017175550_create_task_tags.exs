defmodule TodoListApp.Repo.Migrations.CreateTaskTags do
  use Ecto.Migration

  def change do
    create table(:task_tags) do
      add :task_id, references(:tasks, on_delete: :nothing)
      add :tag_id, references(:tags, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:task_tags, [:user_id])

    create index(:task_tags, [:task_id])
    create index(:task_tags, [:tag_id])

    create unique_index(:task_tags, [:task_id, :tag_id])
  end
end
