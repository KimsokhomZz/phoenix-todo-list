defmodule TodoListAppWeb.TaskLive.Show do
  use TodoListAppWeb, :live_view

  alias TodoListApp.Todos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Task {@task.id}
        <:subtitle>This is a task record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/tasks"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/tasks/#{@task}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit task
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@task.title}</:item>
        <:item title="Description">{@task.description}</:item>
        <:item title="Due date">{@task.due_date}</:item>
        <:item title="Status">{@task.status}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Todos.subscribe_tasks(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Task")
     |> assign(:task, Todos.get_task!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %TodoListApp.Todos.Task{id: id} = task},
        %{assigns: %{task: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :task, task)}
  end

  def handle_info(
        {:deleted, %TodoListApp.Todos.Task{id: id}},
        %{assigns: %{task: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current task was deleted.")
     |> push_navigate(to: ~p"/tasks")}
  end

  def handle_info({type, %TodoListApp.Todos.Task{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
