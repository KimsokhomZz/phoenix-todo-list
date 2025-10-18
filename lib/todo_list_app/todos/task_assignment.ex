defmodule TodoListApp.Todos.TaskAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "task_assignments" do

    field :task_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task_assignment, attrs, user_scope) do
    task_assignment
    |> cast(attrs, [])
    |> validate_required([])
    |> put_change(:user_id, user_scope.user.id)
  end
end
