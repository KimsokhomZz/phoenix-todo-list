defmodule TodoListApp.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias TodoListApp.Repo

  alias TodoListApp.Todos.Task
  alias TodoListApp.Accounts.Scope
  alias TodoListApp.Todos.Tag

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
  # def get_task!(_scope, id) do
  #   Repo.get!(Task, id)
  # end
  def get_task!(scope, id) do
    user_id = scope.user.id

    Repo.one!(
      from t in Task,
        left_join: a in assoc(t, :assignees),
        where: t.id == ^id and (t.creator_id == ^user_id or a.id == ^user_id),
        preload: [:assignees, :tags],
        distinct: true
    )
  end

  @doc """
  Creates a task.
  """

  # def create_task(_scope, attrs) do
  #   with {:ok, task = %Task{}} <-
  #          %Task{}
  #          |> Task.changeset(attrs)
  #          |> Repo.insert() do
  #     broadcast_task(nil, {:created, task})
  #     {:ok, task}
  #   end
  # end

  def create_task(%Scope{} = scope, attrs) do
    user_id = scope.user.id
    attrs = Map.put(attrs, "creator_id", user_id)

    tag_names = Map.get(attrs, "tag_names", [])
    tags = get_or_create_tags(tag_names)

    assignee_ids = Map.get(attrs, "assignee_ids", [])
    assignees = TodoListApp.Accounts.list_users_by_ids(assignee_ids)

    %Task{}
    |> Task.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Ecto.Changeset.put_assoc(:assignees, assignees)
    |> Repo.insert()
    |> case do
      {:ok, task} ->
        broadcast_task(scope, {:created, task})
        {:ok, task}

      error ->
        error
    end
  end

  defp get_or_create_tags([]), do: []

  defp get_or_create_tags(names) do
    Enum.map(names, fn name ->
      slug =
        name
        |> String.downcase()
        |> String.replace(~r/[^\w-]+/u, "-")
        |> String.trim("-")

      Repo.get_by(Tag, name: name) ||
        Repo.insert!(%Tag{name: name, slug: slug})
    end)
  end

  @doc """
  Updates a task.
  """
  def update_task(_scope, %Task{} = task, attrs) do
    tag_names = Map.get(attrs, "tag_names", [])
    tags = get_or_create_tags(tag_names)

    assignee_ids = Map.get(attrs, "assignee_ids", [])
    assignees = TodoListApp.Accounts.list_users_by_ids(assignee_ids)

    task = Repo.preload(task, [:tags, :assignees])

    task
    |> Task.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Ecto.Changeset.put_assoc(:assignees, assignees)
    |> Repo.update()
    |> case do
      {:ok, task} ->
        broadcast_task(nil, {:updated, task})
        {:ok, task}

      error ->
        error
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
