defmodule Ecto.Filters.Exception do
  @moduledoc """
  Exceptions module
  """

  defexception [:args, :type, :message]

  def exception(type: type, args: args) do
    %__MODULE__{
      type: type,
      args: args,
      message: message(type, args)
    }
  end

  defp message(:atom_key, args) do
    "`key` must be an atom. Got #{inspect(args)}"
  end

  defp message(:not_found, args) do
    "Could not find a filter defined to match arguments. Arguments supplied #{inspect(args)}"
  end
end
