defmodule Zenohex.Queryable do
  @moduledoc """
  Documentation for `#{__MODULE__}`.
  """

  alias Zenohex.Nif
  alias Zenohex.Query

  @type t :: reference()

  defmodule Options do
    @moduledoc """
    Documentation for `#{__MODULE__}`.

    Used by `Zenohex.Session.declare_queryable/3`.
    """

    @type t :: %__MODULE__{complete: complete()}
    @type complete :: boolean()
    defstruct complete: false
  end

  @doc """
  Receive query.
  Normally users don't need to change the default timeout_us.

  ## Examples

      iex> {:ok, session} = Zenohex.open()
      iex> {:ok, queryable} = Zenohex.Session.declare_queryable(session, "key/expression")
      iex> Zenohex.Queryable.recv_timeout(queryable)
      {:error, :timeout}
  """
  @spec recv_timeout(t(), pos_integer()) ::
          {:ok, Query.t()}
          | {:error, :timeout}
          | {:error, reason :: any()}
  def recv_timeout(queryable, timeout_us \\ 1000)
      when is_reference(queryable) and is_integer(timeout_us) and timeout_us > 0 do
    Nif.queryable_recv_timeout(queryable, timeout_us)
  end
end
