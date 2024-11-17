defmodule NodoCliente do
  @nombre_servicio_local :nodo_cliente
  @servicio_local {@nombre_servicio_local, :nodocliente@servidor}

  @nodo_remoto :nodoservidor@servidor
  @servicio_remoto {:nodo_servidor, @nodo_remoto}

  @num_servidores 1  # Define aquí el número de servidores disponibles

  def main(file_path) do
    IO.puts("PROCESO PRINCIPAL - Nodo Cliente")

    {num_vars, clauses} = SAT.read_file(file_path)
    IO.puts("Número de variables: #{num_vars}")
    IO.puts("Número de cláusulas: #{length(clauses)}")

    # Registrar el servicio y verificar conexión con el servidor
    @nombre_servicio_local |> registrar_servicio()
    @nodo_remoto |> verificar_conexion() |> activar_productor(num_vars)
  end

  defp registrar_servicio(nombre_servicio_local),
    do: Process.register(self(), nombre_servicio_local)

  defp verificar_conexion(nodo_remoto) do
    Node.connect(nodo_remoto)
  end

  defp activar_productor(:true, num_vars) do
    generar_combinaciones(num_vars)
    recibir_respuestas()
  end

  defp activar_productor(:false, _) do
    IO.puts("No se pudo conectar con el nodo servidor")
  end

defp generar_combinaciones(num_vars) do
  total = trunc(:math.pow(2, num_vars))  # Total de combinaciones
  chunk_size = div(total, @num_servidores)  # División de trabajo por servidor

  # Dividir las combinaciones en rangos para cada servidor
  Enum.each(0..(@num_servidores - 1), fn i ->
    start = i * chunk_size
    finish = if i == @num_servidores - 1, do: total - 1, else: (i + 1) * chunk_size - 1
    enviar_rango({start, finish, num_vars})
  end)

  # Enviar mensaje de fin al servidor
  enviar_mensaje(:fin)
end


  defp enviar_rango({start, finish, num_vars}) do
    # Generar las combinaciones dentro del rango
    Enum.each(start..finish, fn combination ->
      binary_combination = Integer.to_string(combination, 2)
      padded_combination = String.pad_leading(binary_combination, num_vars, "0")
      enviar_mensaje(padded_combination)
    end)
  end

  defp enviar_mensaje(mensaje) do
    send(@servicio_remoto, {@servicio_local, mensaje})
  end

  defp recibir_respuestas(pending_fin \\ @num_servidores) do
    receive do
      :fin ->
        if pending_fin > 1 do
          recibir_respuestas(pending_fin - 1)
        else
          IO.puts("Todas las combinaciones han sido procesadas.")
          :ok
        end
      mensaje ->
        IO.puts("Satisface: #{mensaje}")
        recibir_respuestas(pending_fin)
    end
  end

end

NodoCliente.main("../CNF/uf20-01.cnf")
