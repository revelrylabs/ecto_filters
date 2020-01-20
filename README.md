# Ecto.Filters

Provides a consistent way to transform request params into ecto query expressions.

## Installation

```elixir
def deps do
  [
    {:ecto_filters, "~> 0.1.1"}
  ]
end
```

## Usage

```elixir
defmodule Posts do
  use Ecto.Filters, key: :search
  alias MyProject.{Post, Repo}

  add_filter(:comment_body, fn value, query -> 
    query
    |> join(:left, [p], c in assoc(p, :comments), as: :comments)
    |> where([comments: comments], ilike(comments.body, ^value))
  end)

  @doc """
  Returns the list of posts

  ## Examples

      iex> list_posts(%{"search" => %{"comment_body" => "ecto_filters"}})
      [%Post{}, ...]
      
      iex> list_posts(%{search: %{comment_body: "ecto_filters"}})
      [%Post{}, ...]

      iex> list_posts(search: [comment_body: "ecto_filters"])
      [%Post{}, ...]

  """
  def list_posts(params) do
    Post
    |> apply_filters(params)
    |> Repo.all()
  end
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ecto_filters](https://hexdocs.pm/ecto_filters).

