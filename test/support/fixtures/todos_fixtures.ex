defmodule TodoListApp.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TodoListApp.Todos` context.
  """

  @doc """
  Generate a task.
  """
  def task_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        due_date: ~D[2025-10-16],
        status: "some status",
        title: "some title"
      })

    {:ok, task} = TodoListApp.Todos.create_task(scope, attrs)
    task
  end
end
