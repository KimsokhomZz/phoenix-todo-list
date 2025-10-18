defmodule TodoListApp.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  # def change do
  #   create table(:tasks) do
  #     add :title, :string
  #     add :description, :string
  #     add :due_date, :date
  #     add :status, :string
  #     add :user_id, references(:users, type: :id, on_delete: :delete_all)

  #     timestamps(type: :utc_datetime)
  #   end

  #   create index(:tasks, [:user_id])
  # end

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :description, :text
      add :due_date, :date
      add :status, :string, null: false, default: "todo"

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:status])
  end
end
