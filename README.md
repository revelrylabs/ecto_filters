# Ecto.Filters

Provides a consistent way to compose ecto query expressions.

## Installation

```elixir
def deps do
  [
    {:ecto_filters, "~> 0.3.0"}
  ]
end
```

## Usage

```elixir
defmodule Posts do
  use Ecto.Filters
  alias MyProject.{Post, Repo}

  filter(:comment_body, fn value, query ->
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

When defining a new filter, Ecto.Filters writes a new public function to your context.

So the two examples below are equivalent to each other

```elixir
  filter(:title, &where(&1, title: ^&2))

  def filter_by(query, :title, value) do
    where(query, title: ^value)
  end
```

Knowing that allows the reuse of filters defined by the filter macro in custom functions. For example...

```elixir
  filter(:published, &where(&1, published: ^&2))

  def get_published_post!(id) do
    Post
    |> filter_by(:published, true)
    |> Repo.get!(id)
  end
```

### Options for `apply_filters/2`

- `:key` - The key to use for passing filters. The default is `filters`.
- `:ignore_bad_filters` - Whether or not an exception should be raised when using a
  filter that has not been defined.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ecto_filters](https://hexdocs.pm/ecto_filters).
