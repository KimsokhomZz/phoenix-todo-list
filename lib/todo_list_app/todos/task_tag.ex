defmodule TodoListApp.Todos.TaskTag do
  use Ecto.Schema
  # import Ecto.Changeset

  schema "task_tags" do
    # field :task_id, :id
    # field :tag_id, :id
    belongs_to :task, TodoListApp.Todos.Task
    belongs_to :tag, TodoListApp.Todos.Tag
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  # @doc false
  # def changeset(task_tag, attrs, user_scope) do
  #   task_tag
  #   |> cast(attrs, [])
  #   |> validate_required([])
  #   |> put_change(:user_id, user_scope.user.id)
  # end
end
