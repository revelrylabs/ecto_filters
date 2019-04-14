# EctoFilters

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_filters` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_filters, "~> 0.1.0"}
  ]
end
```

## Usage

```
defmodule Posts do
  use EctoFilters
  alias MyProject.{Post, Repo}

  def filter({:comment_body, value}, query) do
    query
    |> join(:left, [post], comment in assoc(post, :comments))
    |> where([_post, comment], ilike(comment.body, ^value))
  end

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

