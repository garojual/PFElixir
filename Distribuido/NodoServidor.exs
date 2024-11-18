defmodule NodoServidor do
  @nombre_servicio_local :nodo_servidor
  @moduledoc """
  Módulo que representa el nodo servidor en un sistema distribuido para procesar combinaciones
  generadas por los nodos clientes y verificar si satisfacen las cláusulas de una fórmula en
  formato CNF.

  ## Funcionalidades:
  - Registrar el servicio del nodo servidor.
  - Cargar las cláusulas del archivo CNF una sola vez.
  - Recibir combinaciones de los nodos clientes y verificar si cumplen con las cláusulas.
  - Enviar las combinaciones que satisfacen las cláusulas de vuelta al nodo cliente.
  """

  def main() do
    IO.puts("PROCESO SECUNDARIO - Nodo Servidor")

    # Registrar el servicio
    @nombre_servicio_local |> registrar_servicio()

    # Cargar las cláusulas una sola vez
    {_, clauses} = SAT.read_file("../CNF/uf20-01.cnf")

    # Activar el servicio con las cláusulas cargadas
    activar_servicio(clauses)
  end

  defp registrar_servicio(nombre_servicio_local),
    do: Process.register(self(), nombre_servicio_local)

  defp activar_servicio(clauses) do
    receive do
      {productor, mensaje} when mensaje != :fin ->  # Asegúrate de que el servidor solo termine cuando reciba :fin
        procesar_mensaje(mensaje, productor, clauses)
        activar_servicio(clauses)  # Mantener esperando más mensajes

      {productor, :fin} ->  # Terminar cuando reciba :fin
        IO.puts("Finalizando procesamiento de combinaciones.")
        send(productor, :fin)  # Avisar al cliente que terminó
    end
  end

  defp procesar_mensaje(combination, productor, clauses) do
    if SAT.satisfies?(combination, clauses) do
      IO.puts("Satisfactoria: #{combination}")
      send(productor, combination)  # Solo envía si satisface las cláusulas
    end
  end
end

NodoServidor.main()
