defmodule TodoListApp.Todos.TaskAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "task_assignments" do
    belongs_to :task, TodoListApp.Todos.Task
    belongs_to :user, TodoListApp.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task_assignment, attrs) do
    task_assignment
    |> cast(attrs, [:task_id, :user_id])
    |> validate_required([:task_id, :user_id])
  end
end
