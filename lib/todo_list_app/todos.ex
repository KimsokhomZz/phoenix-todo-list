defmodule TodoListApp.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoListApp.Repo

  alias TodoListApp.Todos.Task
  alias TodoListApp.Accounts.Scope

  # Optional: keep PubSub if you still use scope notifications
  # def subscribe_tasks(%Scope{} = scope) do
  #   Phoenix.PubSub.subscribe(TodoListApp.PubSub, "tasks")
  # end
  def subscribe_tasks do
    Phoenix.PubSub.subscribe(TodoListApp.PubSub, "tasks")
  end

  defp broadcast_task(_scope, message) do
    Phoenix.PubSub.broadcast(TodoListApp.PubSub, "tasks", message)
  end

  @doc """
  Returns the list of tasks.
  """
  def list_tasks(%Scope{} = scope) do
    user_id = scope.user.id

    Repo.all(
      from t in Task,
        left_join: a in assoc(t, :assignees),
        where: a.id == ^user_id or t.creator_id == ^user_id,
        preload: [:assignees, :tags]
    )
  end

  #  For filtering by tags (with scope param passing)
  def list_tasks(%{tags: tags, scope: %Scope{} = scope}) when is_list(tags) do
    user_id = scope.user.id

    from(t in Task,
      left_join: tt in "task_tags",
      on: tt.task_id == t.id,
      left_join: tag in "tags",
      on: tag.id == tt.tag_id,
      left_join: a in assoc(t, :assignees),
      where: a.id == ^user_id or t.creator_id == ^user_id,
      where: tag.name in ^tags,
      preload: [:tags, :assignees],
      distinct: true
    )
    |> Repo.all()
  end

  @doc """
  Gets a single task.
  Raises `Ecto.NoResultsError` if not found.
  """
  def get_task!(_scope, id) do
    Repo.get!(Task, id)
  end

  @doc """
  Creates a task.
  """
  def create_task(_scope, attrs) do
    with {:ok, task = %Task{}} <-
           %Task{}
           |> Task.changeset(attrs)
           |> Repo.insert() do
      broadcast_task(nil, {:created, task})
      {:ok, task}
    end
  end

  @doc """
  Updates a task.
  """
  def update_task(_scope, %Task{} = task, attrs) do
    with {:ok, task = %Task{}} <-
           task
           |> Task.changeset(attrs)
           |> Repo.update() do
      broadcast_task(nil, {:updated, task})
      {:ok, task}
    end
  end

  @doc """
  Deletes a task.
  """
  def delete_task(_scope, %Task{} = task) do
    with {:ok, task = %Task{}} <- Repo.delete(task) do
      broadcast_task(nil, {:deleted, task})
      {:ok, task}
    end
  end

  @doc """
  Returns a changeset for editing/validation.
  """
  def change_task(_scope, %Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end
end
