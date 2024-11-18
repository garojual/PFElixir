defmodule SATP do
  @moduledoc """
  Módulo para resolver problemas SAT de forma paralela. Utiliza procesamiento concurrente
  para evaluar combinaciones de asignaciones y determinar si satisfacen un conjunto de cláusulas CNF.
  """

   @doc """
  Ejecuta el proceso de resolución SAT dado un archivo en formato CNF.

  ## Parámetros
    - `file_path`: Ruta al archivo que contiene las cláusulas CNF.

  Lee el archivo, divide las combinaciones posibles en bloques y las procesa en paralelo,
  mostrando las asignaciones que satisfacen las cláusulas y el tiempo de ejecución.
  """
  def run(file_path) do
    start_time = System.monotonic_time(:millisecond)
    {num_vars, clauses} = read_file(file_path)

    IO.puts("Número de variables: #{num_vars}")
    IO.puts("Número de cláusulas: #{length(clauses)}")

    # Definir el número de tareas (procesos) en paralelo
    num_tasks = 1000 # Punto de mejor rendimiento
    IO.puts(num_tasks)
    combinations_per_task = trunc(:math.pow(2, num_vars) / num_tasks)

    tasks =
      for i <- 0..(num_tasks - 1) do
        Task.async(fn ->
          # Generar las combinaciones para este bloque de tareas
          start = i * combinations_per_task
          finish = if i == num_tasks - 1, do: trunc(:math.pow(2, num_vars)) - 1, else: (i + 1) * combinations_per_task - 1

          for combination <- start..finish do
            binary_combination = Integer.to_string(combination, 2)
            padded_combination = String.pad_leading(binary_combination, num_vars, "0")

            # Verificar si la combinación satisface todas las cláusulas
            if satisfies?(padded_combination, clauses) do
              IO.puts("Satisface: #{padded_combination}")
            end
          end
        end)
      end

    # Esperar a que todas las tareas finalicen
    Enum.each(tasks, &Task.await(&1, :infinity))
    end_time = System.monotonic_time(:millisecond)
    duration = end_time - start_time
    IO.puts("Tiempo de ejecución: #{duration} ms")
  end

   @doc """
  Lee un archivo en formato CNF y extrae las cláusulas y el número de variables.

  ## Parámetros
    - `file_path`: Ruta al archivo que contiene las cláusulas CNF.

  ## Retorna
    - Una tupla `{num_vars, clauses}`:
      - `num_vars`: Número total de variables en el problema.
      - `clauses`: Lista de cláusulas representadas como listas de literales.
  """
  defp read_file(file_path) do
    {num_vars, clauses} =
      File.read!(file_path)
      |> String.split("\n")
      |> Enum.reduce({0, []}, fn line, {num_vars, clauses} ->
        cond do
          String.starts_with?(line, "p cnf") ->
            # Capturamos el número de variables de la línea p cnf
            parts = String.split(line)
            var_count = Enum.at(parts, 2) |> String.to_integer()
            {var_count, clauses}

          # Ignorar líneas vacías y comentarios
          line != "" && !String.starts_with?(line, "c") && !String.starts_with?(line, "p") && !String.starts_with?(line, "%") ->
            # Procesar la cláusula
            clause =
              line
              |> String.split(" ")
              |> Enum.map(&String.trim/1)          # Limpiar espacios en blanco
              |> Enum.filter(&(&1 != ""))          # Ignorar cadenas vacías
              |> Enum.map(&String.to_integer/1)    # Convertir a entero
              |> Enum.filter(&(&1 != 0))           # Ignorar el cero al final
            {num_vars, [clause | clauses]}

          true ->
            {num_vars, clauses}
        end
      end)

    {num_vars, Enum.filter(clauses, &(&1 != [])) |> Enum.reverse()} # Filtrar cláusulas vacías
  end


  @doc """
  Verifica si una asignación satisface un conjunto de cláusulas.

  ## Parámetros
    - `assignment`: Cadena binaria que representa la asignación de valores a las variables.
    - `clauses`: Lista de cláusulas representadas como listas de literales.

  ## Retorna
    - `true` si la asignación satisface todas las cláusulas, `false` en caso contrario.
  """
  defp satisfies?(assignment, clauses) do
    Enum.all?(clauses, fn clause ->
      Enum.any?(clause, fn lit ->
        index = abs(lit) - 1 # Calcula el índice correcto basado en 0
        if lit > 0 do
          String.at(assignment, index) == "1"
        else
          String.at(assignment, index) == "0"
        end
      end)
    end)
  end
end


