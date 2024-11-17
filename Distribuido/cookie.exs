defmodule Cookie do
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
