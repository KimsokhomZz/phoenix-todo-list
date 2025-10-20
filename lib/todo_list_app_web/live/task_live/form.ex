defmodule TodoListAppWeb.TaskLive.Form do
  use TodoListAppWeb, :live_view

  alias TodoListApp.Todos
  alias TodoListApp.Todos.Task

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto py-8 px-6">
        <!-- Header Section -->
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-white mb-2">{@page_title}</h1>
          <p class="text-gray-400">Create and manage your tasks efficiently</p>
        </div>

    <!-- Main Form Card -->
        <div class="bg-gray-800 rounded-2xl shadow-2xl border border-gray-700 overflow-hidden">
          <.form
            for={@form}
            id="task-form"
            phx-change="validate"
            phx-submit="save"
            class="p-8 space-y-6"
          >
            <!-- Title Field -->
            <div class="space-y-2">
              <.input
                field={@form[:title]}
                type="text"
                label="Task Title"
                placeholder="Enter a descriptive title for your task"
                class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white placeholder-gray-400 focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 transition-all duration-200"
              />
            </div>

    <!-- Description Field -->
            <div class="space-y-2">
              <label class="block text-sm font-medium text-gray-300 mb-2">Description</label>
              <textarea
                name="task[description]"
                id="task_description"
                placeholder="Provide additional details about this task..."
                class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white placeholder-gray-400 focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 transition-all duration-200 min-h-[120px] resize-y"
              >{Ecto.Changeset.get_field(@form.source, :description)}</textarea>
            </div>

    <!-- Due Date Field -->
            <div class="space-y-2">
              <.input
                field={@form[:due_date]}
                type="date"
                label="Due Date"
                class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 transition-all duration-200"
              />
            </div>

    <!-- Tags Field -->
            <div class="space-y-2">
              <label class="block text-sm font-medium text-gray-300 mb-2">
                <.icon name="hero-tag" class="w-4 h-4 inline mr-2 text-blue-400" /> Tags
              </label>
              <input
                type="text"
                name="tag_names_input"
                placeholder="urgent, work, personal, shopping..."
                value={@tag_names_input || ""}
                class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white placeholder-gray-400 focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 transition-all duration-200"
              />
              <p class="text-xs text-gray-500 flex items-center mt-1">
                <.icon name="hero-information-circle" class="w-3 h-3 mr-1" />
                Separate multiple tags with commas
              </p>
            </div>

    <!-- Status Field -->
            <div class="space-y-2">
              <label class="block text-sm font-medium text-gray-300 mb-2">
                <.icon name="hero-flag" class="w-4 h-4 inline mr-2 text-green-400" /> Status
              </label>
              <div class="relative">
                <select
                  name="task[status]"
                  id="task_status"
                  phx-change="validate"
                  class={[
                    "w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white",
                    "focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 focus:outline-none",
                    "transition-all duration-200 appearance-none cursor-pointer",
                    "bg-gray-700 hover:bg-gray-650 hover:border-gray-500"
                  ]}
                >
                  <option value="todo" selected={@form.data.status == :todo}>📝 To Do</option>
                  <option value="in_progress" selected={@form.data.status == :in_progress}>
                    🚀 In Progress
                  </option>
                  <option value="done" selected={@form.data.status == :done}>✅ Completed</option>
                </select>

    <!-- Custom dropdown arrow -->
                <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                  <.icon name="hero-chevron-down" class="w-5 h-5 text-gray-400" />
                </div>
              </div>

    <!-- Status indicator badges for visual feedback -->
              <div class="flex gap-2 mt-2">
                <div class={[
                  "flex items-center gap-1 px-2 py-1 rounded-md text-xs font-medium transition-all duration-200",
                  @form.data.status == :todo &&
                    "bg-blue-500/20 text-blue-400 border border-blue-500/30",
                  @form.data.status != :todo && "bg-gray-700 text-gray-500 border border-gray-600"
                ]}>
                  📝 To Do
                </div>

                <div class={[
                  "flex items-center gap-1 px-2 py-1 rounded-md text-xs font-medium transition-all duration-200",
                  @form.data.status == :in_progress &&
                    "bg-yellow-500/20 text-yellow-400 border border-yellow-500/30",
                  @form.data.status != :in_progress &&
                    "bg-gray-700 text-gray-500 border border-gray-600"
                ]}>
                  🚀 In Progress
                </div>

                <div class={[
                  "flex items-center gap-1 px-2 py-1 rounded-md text-xs font-medium transition-all duration-200",
                  @form.data.status == :done &&
                    "bg-green-500/20 text-green-400 border border-green-500/30",
                  @form.data.status != :done && "bg-gray-700 text-gray-500 border border-gray-600"
                ]}>
                  ✅ Completed
                </div>
              </div>
            </div>

    <!-- Assignees Field -->
            <div class="space-y-2">
              <label class="block text-sm font-medium text-gray-300 mb-2">
                <.icon name="hero-users" class="w-4 h-4 inline mr-2 text-purple-400" />
                Assign to Team Members
              </label>
              <div class="relative">
                <select
                  name="task[assignee_ids][]"
                  multiple
                  size="4"
                  class="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-xl text-white focus:border-blue-500 focus:ring-2 focus:ring-blue-500/20 transition-all duration-200"
                >
                  <%= for user <- @all_users do %>
                    <option
                      value={user.id}
                      selected={user.id in (@selected_assignee_ids || [])}
                      class={[
                        "py-2 px-3 hover:bg-gray-600 cursor-pointer",
                        user.id in (@selected_assignee_ids || []) && "font-bold text-blue-400"
                      ]}
                    >
                      <.icon name="hero-user-circle" class="w-4 h-4 inline mr-2" />
                      {user.email}
                      <%= if user.id in (@selected_assignee_ids || []) do %>
                        <span class="ml-2 inline-block bg-blue-500/20 text-blue-400 px-2 py-0.5 rounded-full text-xs align-middle">
                          Assigned
                        </span>
                      <% end %>
                    </option>
                  <% end %>
                </select>
              </div>
              <p class="text-xs text-gray-500 flex items-center mt-1">
                <.icon name="hero-information-circle" class="w-3 h-3 mr-1" />
                Hold Ctrl/Cmd to select multiple team members
              </p>
            </div>

    <!-- Action Buttons -->
            <div class="flex gap-4 pt-6 border-t border-gray-700">
              <.button
                phx-disable-with="Saving..."
                class="flex-1 font-semibold py-3 px-6 rounded-xl transition-all duration-200 transform hover:scale-[1.02] focus:ring-4 shadow-lg bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-700 hover:to-purple-700 text-white focus:ring-blue-500/20"
              >
                <.icon name="hero-check" class="w-5 h-5 mr-2" />
                {if @live_action == :edit, do: "Update Task", else: "Create Task"}
              </.button>

              <.button
                navigate={return_path(@current_scope, @return_to, @task)}
                class="px-6 py-3 border-2 border-gray-600 text-gray-300 font-semibold rounded-xl hover:bg-gray-700 hover:border-gray-500 transition-all duration-200 focus:ring-4 focus:ring-gray-500/20"
              >
                <.icon name="hero-x-mark" class="w-5 h-5 mr-2" /> Cancel
              </.button>
            </div>
          </.form>
        </div>
      </div>
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
