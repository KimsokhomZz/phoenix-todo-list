defmodule TodoListAppWeb.TaskLive.FormComponent do
  use TodoListAppWeb, :live_component
  import TodoListAppWeb.CoreComponents

  alias TodoListApp.{Todos, Accounts}
  alias TodoListApp.Todos.Task

  @impl true
  def render(assigns) do
    ~H"""
    <.form
      for={@form}
      id="task-form"
      phx-target={@myself}
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={@form[:title]} label="Title" />
      <.input field={@form[:description]} type="textarea" label="Description" />
      <.input field={@form[:due_date]} type="date" label="Due date" />
      <.input
        field={@form[:status]}
        type="select"
        options={[:todo, :in_progress, :done]}
        label="Status"
      />
      <!-- Comma separated tags -->
      <.input
        name="task[tag_names_input]"
        value={@tag_names_input || ""}
        label="Tags (comma separated)"
      />
      <!-- Multi-select for assignees -->
      <label class="block text-sm font-medium">Assignees</label>
      <select name="task[assignee_ids][]" multiple class="input">
        <%= for u <- @all_users do %>
          <option value={u.id} selected={u.id in (@selected_assignee_ids || [])}>{u.email}</option>
        <% end %>
      </select>
      <div class="mt-4"><.button phx-disable-with="Saving...">Save Task</.button></div>
    </.form>
    """
  end

  @impl true
  def update(%{task: task} = assigns, socket) do
    all_users = Accounts.list_users()
    selected_assignee_ids = Enum.map(task.assignees || [], & &1.id)

    tag_names_input =
      task.tags
      |> Kernel.||([])
      |> Enum.map(& &1.name)
      |> Enum.join(", ")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:all_users, all_users)
     |> assign(:selected_assignee_ids, selected_assignee_ids)
     |> assign(:tag_names_input, tag_names_input)
     #  |> assign_form(Task.changeset(task, %{}))
     |> assign(:form, to_form(Task.changeset(task, %{})))}
  end

  @impl true
  def handle_event("validate", %{"task" => params}, socket) do
    changeset = Task.changeset(socket.assigns.task, params)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"task" => params}, socket) do
    # Parse comma-separated tags
    tag_names =
      params
      |> Map.get("tag_names_input", "")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    params =
      params
      |> Map.put("tag_names", tag_names)

    save_task(socket, socket.assigns.action, params)
  end

  defp save_task(socket, :edit, params) do
    case Todos.update_task(socket.assigns.current_scope, socket.assigns.task, params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task updated successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_task(socket, :new, params) do
    case Todos.create_task(socket.assigns.current_scope, params) do
      {:ok, _task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
