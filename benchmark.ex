defmodule Benchmark do

  def calcular_speedup(tiempo1, tiempo2), do: tiempo2 / tiempo1

  def determinar_tiempo_ejecucion({modulo, funcion, argumentos}) do
    tiempo_inicial = System.monotonic_time()
    apply(modulo, funcion, argumentos)
    tiempo_final = System.monotonic_time()

    duracion =
      System.convert_time_unit(
        tiempo_final - tiempo_inicial,
        :native, :microsecond
      )

      duracion
  end

  def generar_mensaje(tiempo1, tiempo2) do
    speedup = calcular_speedup(tiempo1, tiempo2)
    |> Float.round(2)

    "Tiempo: #{tiempo1} y #{tiempo2} microsegundos, " <>
    "el primer algoritmo es #{speedup} veces más rápido que el segundo.\n"
  end


  def generar_grafica_html(datos) do


    html_base =
    """
      <html>
      <head>
        <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
        <script type="text/javascript">
          google.charts.load('current', {'packages':['bar']});
          google.charts.setOnLoadCallback(drawChart);

          function drawChart() {
            var data = google.visualization.arrayToDataTable([

            <TITULOS y DATOS>
      ]);

            var options = {
              chart: {
                title: 'Comparación de algoritmos',
                subtitle: 'Pruebas vs Tiempo de ejecución',
              }
            };

            var chart = new google.charts.Bar(document.getElementById('columnchart_material'));

            chart.draw(data, google.charts.Bar.convertOptions(options));
          }
        </script>
      </head>
      <body>
        <!--  Fuente de Google Charts
              https://developers.google.com/chart/interactive/docs/gallery/columnchart#creating-material-column-charts
          -->
        <div id="columnchart_material" style="width: 800px; height: 500px;"></div>
      </body>
    </html>
    """

    ## FALTA LA PARTE DE LOS TÍTULO Y LOS DATOS (<TITULOS y DATOS>)
     # Ejemplo de la página original de Google Charts
     # https://developers.google.com/chart/interactive/docs/gallery/columnchart#creating-material-column-charts

     # ['Year', 'Sales', 'Expenses', 'Profit'],
     # ['2014', 1000, 400, 200],
     # ['2015', 1170, 460, 250],
     # ['2016', 660, 1120, 300],
     # ['2017', 1030, 540, 350]

    html_final = String.replace(html_base, "<TITULOS y DATOS>", datos)

    html_final
  end
end
