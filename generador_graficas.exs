Code.require_file("C:/universidad/Uprograms/Java/8vo/ProyectoFinalElixir/PFElixir/Secuencial/sat_secuencial.exs", __DIR__)
Code.require_file("C:/universidad/Uprograms/Java/8vo/ProyectoFinalElixir/PFElixir/Paralelo/sat_paralelo.exs", __DIR__)

defmodule GraficasSAT do
  # Valores de prueba (ruta del archivo CNF)
  @valores_prueba ["./CNF/uf20-01.cnf", "./CNF/uf20-01000.cnf"]
  @repeticiones 2

  def main do
    hacer_simulaciones(@valores_prueba, @repeticiones)
    |> convertir_resultados_simulaciones_mensaje()
    |> agregar_titulos()
    |> Benchmark.generar_grafica_html()
    |> escribir_archivo("index.html")
  end

  defp hacer_simulaciones(valores_prueba, repeticiones) do
    tabla_resultados =
      Enum.map(valores_prueba, fn file_path ->
        ejecutar_simulacion(file_path, repeticiones)
      end)

    tabla_resultados
  end

  defp ejecutar_simulacion(file_path, repeticiones) do
    algoritmos = [
      {SAT, :run, [file_path]},
      {SATP, :run, [file_path]},
    ]

    tiempo_promedio =
      Enum.map(algoritmos, fn algoritmo ->
        obtener_tiempo_promedio_ejecucion(algoritmo, repeticiones)
      end)

    {file_path, tiempo_promedio}
  end

  defp obtener_tiempo_promedio_ejecucion(algoritmo, repeticiones) do
    suma =
      Enum.map(1..repeticiones, fn _ ->
        Benchmark.determinar_tiempo_ejecucion(algoritmo)
      end)
      |> Enum.sum()

    promedio = suma / repeticiones
    promedio
  end

  defp convertir_resultados_simulaciones_mensaje(resultado_simulaciones) do
    resultado_simulaciones
    |> Enum.map(fn simulacion -> generar_mensaje(simulacion) end)
    |> Enum.join("\n")
  end

  defp generar_mensaje(simulacion) do
    {file_path, [promedio_secuencial, promedio_paralelo]} = simulacion

    "\t['#{file_path}', #{promedio_secuencial}, #{promedio_paralelo}],"
  end

  defp escribir_archivo(contenido, nombre), do: File.write(nombre, contenido)

  defp agregar_titulos(mensaje_simulaciones) do
    agregar_titulos = fn contenido ->
      "['Archivo CNF', 'Secuencial', 'Paralelo'],\n" <> contenido
    end

    mensaje_simulaciones
    |> agregar_titulos.()
  end
end

GraficasSAT.main()
