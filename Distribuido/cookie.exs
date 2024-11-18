defmodule Cookie do

  @moduledoc """
  Módulo para la generación de cookies seguras.
  Genera una clave aleatoria de longitud fija en bytes, la codifica en Base64 y la imprime en pantalla.
  """

  @longitud_llave 128

  def main() do
    :crypto.strong_rand_bytes(@longitud_llave)
    |> Base.encode64()
    |> mostrar_mensaje()
  end

  def mostrar_mensaje(mensaje) do
    mensaje
    |> IO.puts()
  end

end

Cookie.main()
