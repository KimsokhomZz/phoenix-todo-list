defmodule TodoListAppWeb.PageController do
  use TodoListAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
