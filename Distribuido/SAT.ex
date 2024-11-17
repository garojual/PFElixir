defmodule SAT do
  def read_file(file_path) do
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
              |> Enum.filter(&(&1 != 0))            # Ignorar el cero al final
            {num_vars, [clause | clauses]}

          true ->
            {num_vars, clauses}
        end
      end)

    {num_vars, Enum.filter(clauses, &(&1 != [])) |> Enum.reverse()} # Filtrar cláusulas vacías
  end

  def satisfies?(assignment, clauses) do
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
