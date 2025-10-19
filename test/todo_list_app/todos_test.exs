defmodule TodoListApp.TodosTest do
  use TodoListApp.DataCase

  alias TodoListApp.Todos

  describe "tasks" do
    alias TodoListApp.Todos.Task

    import TodoListApp.AccountsFixtures, only: [user_scope_fixture: 0]
    import TodoListApp.TodosFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil, due_date: nil}

    test "list_tasks/1 returns all scoped tasks" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      task = task_fixture(scope)
      other_task = task_fixture(other_scope)
      assert Todos.list_tasks(scope) == [task]
      assert Todos.list_tasks(other_scope) == [other_task]
    end

    test "get_task!/2 returns the task with given id" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      other_scope = user_scope_fixture()
      assert Todos.get_task!(scope, task.id) == task
      assert_raise Ecto.NoResultsError, fn -> Todos.get_task!(other_scope, task.id) end
    end

    test "create_task/2 with valid data creates a task" do
      valid_attrs = %{
        status: "some status",
        description: "some description",
        title: "some title",
        due_date: ~D[2025-10-16]
      }

      scope = user_scope_fixture()

      assert {:ok, %Task{} = task} = Todos.create_task(scope, valid_attrs)
      assert task.status == "some status"
      assert task.description == "some description"
      assert task.title == "some title"
      assert task.due_date == ~D[2025-10-16]
      assert task.user_id == scope.user.id
    end

    test "create_task/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Todos.create_task(scope, @invalid_attrs)
    end

    test "update_task/3 with valid data updates the task" do
      scope = user_scope_fixture()
      task = task_fixture(scope)

      update_attrs = %{
        status: "some updated status",
        description: "some updated description",
        title: "some updated title",
        due_date: ~D[2025-10-17]
      }

      assert {:ok, %Task{} = task} = Todos.update_task(scope, task, update_attrs)
      assert task.status == "some updated status"
      assert task.description == "some updated description"
      assert task.title == "some updated title"
      assert task.due_date == ~D[2025-10-17]
    end

    test "update_task/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      task = task_fixture(scope)

      assert_raise MatchError, fn ->
        Todos.update_task(other_scope, task, %{})
      end
    end

    test "update_task/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Todos.update_task(scope, task, @invalid_attrs)
      assert task == Todos.get_task!(scope, task.id)
    end

    test "delete_task/2 deletes the task" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      assert {:ok, %Task{}} = Todos.delete_task(scope, task)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_task!(scope, task.id) end
    end

    test "delete_task/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      task = task_fixture(scope)
      assert_raise MatchError, fn -> Todos.delete_task(other_scope, task) end
    end

    test "change_task/2 returns a task changeset" do
      scope = user_scope_fixture()
      task = task_fixture(scope)
      assert %Ecto.Changeset{} = Todos.change_task(scope, task)
    end
  end
end
