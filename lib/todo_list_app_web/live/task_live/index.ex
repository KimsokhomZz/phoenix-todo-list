defmodule TodoListAppWeb.TaskLive.Index do
  use TodoListAppWeb, :live_view
  import TodoListAppWeb.CoreComponents

  alias TodoListApp.Todos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mb-4">
        <.form for={%{}} phx-submit="search">
          <.input name="tags" label="Filter by tags (comma separated)" />
          <div class="mt-2">
            <.button>Filter</.button>
          </div>
        </.form>
      </div>

      <.header>
        Listing Tasks
        <:actions>
          <.button variant="primary" navigate={~p"/tasks/new"}>
            <.icon name="hero-plus" /> New Task
          </.button>
        </:actions>
      </.header>

      <.table
        id="tasks"
        rows={@streams.tasks}
        row_click={fn {_id, task} -> JS.navigate(~p"/tasks/#{task}") end}
      >
        <:col :let={{_id, task}} label="Title">{task.title}</:col>
        <:col :let={{_id, task}} label="Description">{task.description}</:col>
        <:col :let={{_id, task}} label="Due date">{task.due_date}</:col>
        <:col :let={{_id, task}} label="Status">{task.status}</:col>
        <:action :let={{_id, task}}>
          <div class="sr-only">
            <.link navigate={~p"/tasks/#{task}"}>Show</.link>
          </div>
          <.link navigate={~p"/tasks/#{task}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, task}}>
          <.link
            phx-click={JS.push("delete", value: %{id: task.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Todos.subscribe_tasks(socket.assigns.current_scope)
      Todos.subscribe_tasks()
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Tasks")
     |> stream(:tasks, list_tasks(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Todos.get_task!(socket.assigns.current_scope, id)
    {:ok, _} = Todos.delete_task(socket.assigns.current_scope, task)

    {:noreply, stream_delete(socket, :tasks, task)}
  end

  @impl true
  def handle_event("search", %{"tags" => tags_str}, socket) do
    tags =
      tags_str
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    # Pass current_scope for filtering, update as needed for your context
    tasks = TodoListApp.Todos.list_tasks(%{tags: tags, scope: socket.assigns.current_scope})
    {:noreply, assign(socket, :tasks, tasks)}
  end

  @impl true
  def handle_info({type, %TodoListApp.Todos.Task{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :tasks, list_tasks(socket.assigns.current_scope), reset: true)}
  end

  defp list_tasks(current_scope) do
    Todos.list_tasks(current_scope)
  end


end
