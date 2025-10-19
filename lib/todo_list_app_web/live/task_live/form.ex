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
        <.input field={@form[:status]} type="text" label="Status" />
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
    task = Todos.get_task!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Task")
    |> assign(:task, task)
    |> assign(:form, to_form(Todos.change_task(socket.assigns.current_scope, task)))
  end

  defp apply_action(socket, :new, _params) do
    # task = %Task{user_id: socket.assigns.current_scope.user.id}
    task = %Task{}

    socket
    |> assign(:page_title, "New Task")
    |> assign(:task, task)
    |> assign(:form, to_form(Todos.change_task(socket.assigns.current_scope, task)))
  end

  @impl true
  def handle_event("validate", %{"task" => task_params}, socket) do
    changeset = Todos.change_task(socket.assigns.current_scope, socket.assigns.task, task_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"task" => task_params}, socket) do
    save_task(socket, socket.assigns.live_action, task_params)
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
