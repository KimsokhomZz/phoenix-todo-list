defmodule TodoListAppWeb.TaskLive.Form do
  use TodoListAppWeb, :live_view

  alias TodoListApp.Todos
  alias TodoListApp.Todos.Task

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage task records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="task-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:due_date]} type="date" label="Due date" />
        <.input
          name="tag_names_input"
          label="Tags (comma separated)"
          placeholder="urgent, home, work, ..."
          value={@tag_names_input || ""}
        />
        <.input field={@form[:status]} type="text" label="Status" />
        <select
          name="assignee_ids[]"
          multiple
          class="input mt-2 w-full rounded border border-gray-300"
        >
          <%= for user <- @all_users do %>
            <option value={user.id} selected={user.id in (@selected_assignee_ids || [])}>
              {user.email}
            </option>
          <% end %>
        </select>
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Task</.button>
          <.button navigate={return_path(@current_scope, @return_to, @task)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    # Preload tags when fetching the task
    task =
      Todos.get_task!(socket.assigns.current_scope, id)
      |> TodoListApp.Repo.preload([:tags, :assignees])

    all_users = TodoListApp.Accounts.list_users()
    selected_assignee_ids = Enum.map(task.assignees, & &1.id)

    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:task, task)
    |> assign(:form, to_form(Todos.change_task(socket.assigns.current_scope, task)))
    |> assign(:tag_names_input, task.tags |> Enum.map(& &1.name) |> Enum.join(", "))
    |> assign(:all_users, all_users)
    |> assign(:selected_assignee_ids, selected_assignee_ids)
  end

  defp apply_action(socket, :new, _params) do
    all_users = TodoListApp.Accounts.list_users()

    socket
    |> assign(:page_title, "New Task")
    |> assign(:task, %Task{})
    |> assign(:form, to_form(Todos.change_task(socket.assigns.current_scope, %Task{})))
    |> assign(:tag_names_input, "")
    |> assign(:all_users, all_users)
    |> assign(:selected_assignee_ids, [])
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset = Todos.change_task(socket.assigns.current_scope, socket.assigns.task, task_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"task" => task_params} = params, socket) do
    tag_names =
      Map.get(params, "tag_names_input", "")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    assignee_ids =
      Map.get(task_params, "assignee_ids", [])
      |> Enum.map(&String.to_integer/1)

    save_task(
      socket,
      socket.assigns.live_action,
      Map.merge(task_params, %{"tag_names" => tag_names, "assignee_ids" => assignee_ids})
    )
  end

  defp save_task(socket, :edit, task_params) do
    case Todos.update_task(socket.assigns.current_scope, socket.assigns.task, task_params) do
      {:ok, task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, task)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_task(socket, :new, task_params) do
    case Todos.create_task(socket.assigns.current_scope, task_params) do
      {:ok, task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, task)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _task), do: ~p"/tasks"
  defp return_path(_scope, "show", task), do: ~p"/tasks/#{task}"
end
