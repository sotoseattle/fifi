defmodule Sign do
  defstruct r: nil, s: nil

  def new(r, s) do
    %Sign{r: r, s: s}
  end
end
