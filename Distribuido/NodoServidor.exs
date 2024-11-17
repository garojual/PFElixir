defmodule NodoServidor do
  @nombre_servicio_local :nodo_servidor

  def main() do
    IO.puts("PROCESO SECUNDARIO - Nodo Servidor")

    # Registrar el servicio
    @nombre_servicio_local |> registrar_servicio()

    # Cargar las cláusulas una sola vez
    {_, clauses} = SAT.read_file("../CNF/uf20-01000.cnf")

    # Activar el servicio con las cláusulas cargadas
    activar_servicio(clauses)
  end

  defp registrar_servicio(nombre_servicio_local),
    do: Process.register(self(), nombre_servicio_local)

  defp activar_servicio(clauses) do
    receive do
      {productor, mensaje} ->
        procesar_mensaje(mensaje, productor, clauses)
        activar_servicio(clauses)
    end
  end

  defp procesar_mensaje(:fin, productor, _clauses) do
    send(productor, :fin)
  end

  defp procesar_mensaje(combination, productor, clauses) do
    if SAT.satisfies?(combination, clauses) do
      send(productor, combination)  # Solo envía si satisface las cláusulas
    end
  end
end

NodoServidor.main()
