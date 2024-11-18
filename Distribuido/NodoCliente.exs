defmodule NodoCliente do

   @moduledoc """
  Módulo que simula un nodo cliente en un sistema distribuido.

  Este nodo cliente lee un archivo CNF, genera combinaciones de valores para las variables,
  las envía a un servidor remoto para su procesamiento, y recibe las respuestas de si
  alguna de las combinaciones satisface las cláusulas del problema SAT.
  """
  @nombre_servicio_local :nodo_cliente
  @servicio_local {@nombre_servicio_local, :nodocliente@localhost}

  @nodo_remoto :nodoservidor@localhost
  @servicio_remoto {:nodo_servidor, @nodo_remoto}

  @num_servidores 1  # Define aquí el número de servidores disponibles


  @doc """

  ## Flujo:
    1. Leer el archivo CNF.
    2. Registrar el servicio local.
    3. Verificar la conexión con el nodo servidor.
    4. Iniciar el productor si la conexión es exitosa.
  """
  def main(file_path) do
    IO.puts("PROCESO PRINCIPAL - Nodo Cliente")

    {num_vars, clauses} = SAT.read_file(file_path)
    IO.puts("Número de variables: #{num_vars}")
    IO.puts("Número de cláusulas: #{length(clauses)}")

    # Registrar el servicio y verificar conexión con el servidor
    @nombre_servicio_local |> registrar_servicio()
    @nodo_remoto |> verificar_conexion() |> activar_productor(num_vars)
  end

  @doc """
  Registra el servicio local con el nombre especificado.

  Este método asegura que el proceso actual sea accesible bajo el nombre de servicio
  especificado dentro de la red distribuida.

  ## Parámetros:
    - `nombre_servicio_local`: El nombre del servicio que se quiere registrar.
  """
  defp registrar_servicio(nombre_servicio_local),
    do: Process.register(self(), nombre_servicio_local)

 @doc """
  Intenta establecer una conexión con el nodo remoto. Si la conexión es exitosa,
  activa el productor de combinaciones.

  ## Parámetros:
    - `nodo_remoto`: El nombre del nodo al que se quiere conectar.

  ## Devuelve:
    - `:true` si la conexión es exitosa.
    - `:false` si no se puede conectar al nodo remoto.
  """
  defp verificar_conexion(nodo_remoto) do
    Node.connect(nodo_remoto)
  end

  @doc """

  Este método genera las combinaciones de valores para las variables, las divide
  en rangos para ser procesadas por los servidores y las envía para su evaluación.

  ## Parámetros:
    - `:true` indica que la conexión con el servidor fue exitosa.
    - `num_vars`: El número de variables que se deben tomar en cuenta para generar las combinaciones.
  """
  defp activar_productor(:true, num_vars) do
    generar_combinaciones(num_vars)
    recibir_respuestas()
  end

  defp activar_productor(:false, _) do
    IO.puts("No se pudo conectar con el nodo servidor")
  end

  @doc """
  Genera las combinaciones posibles para las variables y las distribuye entre los servidores.

  El total de combinaciones se divide equitativamente entre los servidores, y cada servidor
  procesará su rango asignado.

  ## Parámetros:
    - `num_vars`: El número de variables para las cuales se generarán las combinaciones.
  """
  defp generar_combinaciones(num_vars) do
    total = trunc(:math.pow(2, num_vars))
    chunk_size = div(total, @num_servidores)

    # Dividir las combinaciones en rangos para cada servidor
    Enum.each(0..(@num_servidores - 1), fn i ->
      start = i * chunk_size
      finish = if i == @num_servidores - 1, do: total - 1, else: (i + 1) * chunk_size - 1
      enviar_rango({start, finish, num_vars})
    end)

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

NodoCliente.main("../CNF/uf20-01000.cnf")
