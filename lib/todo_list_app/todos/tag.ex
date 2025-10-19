defmodule TodoListApp.Todos.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  # schema "tags" do
  #   field :name, :string
  #   field :slug, :string
  #   field :user_id, :id

  #   timestamps(type: :utc_datetime)
  # end

  # @doc false
  # def changeset(tag, attrs, user_scope) do
  #   tag
  #   |> cast(attrs, [:name, :slug])
  #   |> validate_required([:name, :slug])
  #   |> unique_constraint(:slug)
  #   |> unique_constraint(:name)
  #   |> put_change(:user_id, user_scope.user.id)
  # end

  schema "tags" do
    field :name, :string
    field :slug, :string
    many_to_many :tasks, TodoListApp.Todos.Task, join_through: "task_tags"

    timestamps(type: :utc_datetime)
  end

  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end
