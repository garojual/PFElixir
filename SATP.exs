defmodule SATP do
  def run(file_path) do
    :observer.start()
    {num_vars, clauses} = read_file(file_path)

    IO.puts("Número de variables: #{num_vars}")
    IO.puts("Número de cláusulas: #{length(clauses)}")

    # Definir el número de tareas (procesos) en paralelo
    num_tasks = System.schedulers_online() # Usa el número de núcleos disponibles como referencia
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
  end

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

# Ejecutar el programa
SATP.run("CNF/uf20-01.cnf")
