defmodule TodoListApp.Todos.Task do
  use Ecto.Schema
  import Ecto.Changeset

  # schema "tasks" do
  #   field :title, :string
  #   field :description, :string
  #   field :due_date, :date
  #   field :status, :string
  #   field :user_id, :id

  #   timestamps(type: :utc_datetime)
  # end

  # @doc false
  # def changeset(task, attrs, user_scope) do
  #   task
  #   |> cast(attrs, [:title, :description, :due_date, :status])
  #   |> validate_required([:title, :description, :due_date, :status])
  #   |> put_change(:user_id, user_scope.user.id)
  # end

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :due_date, :date

    field :status, Ecto.Enum, values: [:todo, :in_progress, :done], default: :todo

    many_to_many :tags, TodoApp.Todos.Tag, join_through: "task_tags", on_replace: :delete

    many_to_many :assignees, TodoApp.Accounts.User,
      join_through: "task_assignments",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :due_date, :status])
    |> validate_required([:title, :status])
  end
end
