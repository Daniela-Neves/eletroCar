import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:calvin_boards/repository/agriculture_repository.dart';
import 'package:calvin_boards/repository/equipment_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path_provider/path_provider.dart';

class ReportDetailsPage extends StatefulWidget {
  const ReportDetailsPage({Key? key}) : super(key: key);

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
  final List<Point> soyExports2021 = [
    Point('Jan', 49.606),
    Point('Fev', 2646.546),
    Point('Mar', 12694.341),
    Point('Abr', 16619.467),
    Point('Mai', 15465.736),
    Point('Jun', 11568.091),
    Point('Jul', 8675.830),
    Point('Ago', 6480.259),
    Point('Set', 4858.458),
    Point('Out', 3294.671),
    Point('Nov', 2605.951),
    Point('Dez', 2739.225),
  ];

  final List<Point> soyExports2022 = [
    Point('Jan', 2451.828),
    Point('Fev', 6274.365),
    Point('Mar', 12232.570),
    Point('Abr', 11481.981),
    Point('Mai', 10657.844),
    Point('Jun', 10088.221),
    Point('Jul', 7561.542),
    Point('Ago', 6117.405),
    Point('Set', 4292.326),
  ];

  @override
  Widget build(BuildContext context) {
    int reportNumber = ModalRoute.of(context)!.settings.arguments as int;
    return _scaffoldBuilder(context, reportNumber);
  }

  Widget _scaffoldBuilder(BuildContext context, int reportNumber) {
    Widget reportWidget;

    switch (reportNumber) {
      case 1:
        reportWidget = _buildAgroReport1();
        break;
      case 2:
        reportWidget = _buildAgroReport2();
        break;
      case 3:
        reportWidget = _buildAgroReport3();
        break;
      case 4:
        reportWidget = _buildEquipReport4();
        break;
      case 5:
        reportWidget = _buildEquipReport5();
        break;
      default:
        reportWidget = const Text("Nenhum relat??rio especificado.");
    }
    ScreenshotController screenshotController = ScreenshotController();

    return Screenshot(
        controller: screenshotController,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            title: const Text("Relat??rio"),
            actions: [
              IconButton(
                  onPressed: () {
                    takePicture(screenshotController);
                  },
                  icon: const Icon(Icons.share))
            ],
          ),
          body: reportWidget,
        ));
  }

  Future<void> takePicture(ScreenshotController controller) async {
    await controller.capture().then((Uint8List? image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath =
            await File('${directory.path}/relatorio.png').create();
        await imagePath.writeAsBytes(image);

        await Share.shareFiles([imagePath.path],
            text: 'Veja esse relat??rio do Calvin Boards');
      }
    });
  }

  Widget _buildAgroReport1() {
    return Column(
      children: [
        Expanded(
          child: SfCartesianChart(
              margin: const EdgeInsets.only(
                  top: 60, left: 40, right: 40, bottom: 100),
              primaryYAxis: NumericAxis(
                  title: AxisTitle(text: "Milh??es de toneladas"),
                  numberFormat: NumberFormat.compact()),
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(text: 'Soja exportada por m??s'),
              legend: Legend(
                  isVisible: true,
                  title: LegendTitle(
                      alignment: ChartAlignment.center,
                      text: "Fonte: Comex Stat - MDIC")),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<Point, String>>[
                LineSeries<Point, String>(
                    color: Colors.blue,
                    markerSettings: const MarkerSettings(isVisible: true),
                    name: "2021",
                    dataSource: soyExports2021,
                    xValueMapper: (Point value, _) => value.month,
                    yValueMapper: (Point value, _) => value.amount.round(),
                    dataLabelSettings:
                        const DataLabelSettings(isVisible: true)),
                LineSeries<Point, String>(
                    color: Colors.green,
                    markerSettings: const MarkerSettings(isVisible: true),
                    name: "2022",
                    dataSource: soyExports2022,
                    xValueMapper: (Point value, _) => value.month,
                    yValueMapper: (Point value, _) => value.amount.round()),
                AreaSeries(
                    name: "Per??odo de alta",
                    color: const Color.fromARGB(19, 244, 67, 54),
                    dataSource: soyExports2021.sublist(2, 6),
                    xValueMapper: (Point value, _) => value.month,
                    yValueMapper: (Point value, _) => value.amount)
              ]),
        ),
        const Text(
            "Dados do Minist??rio da Ind??stria, Com??rcio Exterior e Servi??os "
            "mostram uma queda significativa das exporta????es de soja no per??odo"
            " de colheita")
      ],
    );
  }

  Widget _buildAgroReport2() {
    final repo = AgricultureRepository();
    return Column(children: [
      FutureBuilder(
          future: repo.getData("Cana", "Paran??"),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _progressIndicatorSquare();
            }
            return Expanded(
              child: SfCartesianChart(
                  margin: const EdgeInsets.only(
                      top: 60, left: 40, right: 40, bottom: 100),
                  primaryYAxis: NumericAxis(
                      title: AxisTitle(text: "Toneladas"),
                      numberFormat: NumberFormat.compact()),
                  primaryXAxis: CategoryAxis(),
                  axes: [
                    NumericAxis(
                        title: AxisTitle(text: "??rea plantada (hectare)"),
                        name: "cropArea",
                        numberFormat: NumberFormat.compact(),
                        opposedPosition: true),
                  ],
                  title: ChartTitle(
                      text: 'Cana produzida e ??rea plantada por m??s'),
                  legend: Legend(
                      isVisible: true,
                      title: LegendTitle(
                          alignment: ChartAlignment.center,
                          text: "Fonte: IBGE")),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<AgricultureRow, String>>[
                    LineSeries<AgricultureRow, String>(
                        color: Colors.blue,
                        markerSettings: const MarkerSettings(isVisible: false),
                        name: "Produ????o",
                        dataSource: snapshot.data as List<AgricultureRow>,
                        xValueMapper: (AgricultureRow value, int idx) {
                          {
                            if (idx > 130) return "2024-03";
                            return value.yearMonth;
                          }
                        },
                        yValueMapper: (AgricultureRow value, _) =>
                            value.cropYield,
                        trendlines: <Trendline>[
                          Trendline(
                              name: "Tend??ncia",
                              type: TrendlineType.polynomial,
                              color: Colors.red,
                              forwardForecast: 18,
                              enableTooltip: true)
                        ]),
                    LineSeries<AgricultureRow, String>(
                        color: Colors.green,
                        markerSettings: const MarkerSettings(isVisible: false),
                        name: "??rea plantada",
                        yAxisName: "cropArea",
                        dataSource: snapshot.data as List<AgricultureRow>,
                        xValueMapper: (AgricultureRow value, _) =>
                            value.yearMonth,
                        yValueMapper: (AgricultureRow value, _) =>
                            value.cropArea),
                  ]),
            );
          }),
      const Padding(
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Text(
            "A produ????o da cana-de-a????car no Paran?? vem caindo nos ??ltimos 5 "
            "anos. Uma regress??o polinomial, com 93% de confian??a, mostra que "
            "em um ano e meio, a produ????o ser?? a metade em rela????o a 2017."),
      )
    ]);
  }

  Widget _buildAgroReport3() {
    final repo = AgricultureRepository();
    return ListView(children: [
      FutureBuilder(
          future: repo.getDataWithWeather("S??o Paulo"),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _progressIndicatorSquare();
            }
            return SizedBox(
              width:
                  (window.physicalSize.shortestSide / window.devicePixelRatio),
              height: 1 *
                  (window.physicalSize.longestSide / window.devicePixelRatio),
              child: SfCartesianChart(
                  margin: const EdgeInsets.only(
                      top: 10, left: 10, right: 10, bottom: 25),
                  primaryYAxis: NumericAxis(
                      title: AxisTitle(text: "Toneladas"),
                      numberFormat: NumberFormat.compact()),
                  primaryXAxis: CategoryAxis(),
                  axes: [
                    NumericAxis(
                        title: AxisTitle(text: "Precipita????o (mm)"),
                        name: "precipitation",
                        numberFormat: NumberFormat.compact(),
                        opposedPosition: true),
                  ],
                  title: ChartTitle(
                      text: 'Cana produzida e precipita????o total mensal - SP'),
                  legend: Legend(
                      isVisible: true,
                      title: LegendTitle(
                          alignment: ChartAlignment.center,
                          text: "Fonte: IBGE/INPE")),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<AgricultureWeatherRow, String>>[
                    LineSeries<AgricultureWeatherRow, String>(
                        color: Colors.blue,
                        markerSettings: const MarkerSettings(isVisible: false),
                        name: "Produ????o",
                        dataSource:
                            snapshot.data as List<AgricultureWeatherRow>,
                        xValueMapper: (AgricultureWeatherRow value, int idx) =>
                            value.yearMonth,
                        yValueMapper: (AgricultureWeatherRow value, _) =>
                            value.cropYield),
                    LineSeries<AgricultureWeatherRow, String>(
                        color: Colors.green,
                        markerSettings: const MarkerSettings(isVisible: false),
                        name: "Precipita????o",
                        yAxisName: "precipitation",
                        dataSource:
                            snapshot.data as List<AgricultureWeatherRow>,
                        xValueMapper: (AgricultureWeatherRow value, _) =>
                            value.yearMonth,
                        yValueMapper: (AgricultureWeatherRow value, _) =>
                            value.precipitation),
                  ]),
            );
          }),
      const Padding(
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Text(
            "O n??vel de precipita????o mensal no estado de S??o Paulo vem caindo "
            "de forma significativa nos ??ltimos anos, fato que est?? "
            "correlacionado com a queda na produ????o. A breve recupera????o da "
            "produ????o entre janeiro e junho desse ano n??o se sustentou."),
      ),
      FutureBuilder(
          future: repo.getDataWithWeather('Goi??s'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _progressIndicatorSquare();
            }
            return SizedBox(
              width:
                  (window.physicalSize.shortestSide / window.devicePixelRatio),
              height:
                  (window.physicalSize.longestSide / window.devicePixelRatio),
              child: SfCartesianChart(
                  margin: const EdgeInsets.only(
                      top: 5, left: 10, right: 10, bottom: 20),
                  primaryYAxis: NumericAxis(
                      title: AxisTitle(text: "Toneladas"),
                      numberFormat: NumberFormat.compact()),
                  primaryXAxis: CategoryAxis(),
                  axes: [
                    NumericAxis(
                        title: AxisTitle(text: "Precipita????o (mm)"),
                        name: "precipitation",
                        numberFormat: NumberFormat.compact(),
                        opposedPosition: true),
                  ],
                  title: ChartTitle(
                      text: 'Cana produzida e precipita????o total mensal - GO'),
                  legend: Legend(
                      isVisible: true,
                      title: LegendTitle(
                          alignment: ChartAlignment.center,
                          text: "Fonte: IBGE/INPE")),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<AgricultureWeatherRow, String>>[
                    LineSeries<AgricultureWeatherRow, String>(
                        color: Colors.orange,
                        markerSettings: const MarkerSettings(isVisible: false),
                        name: "Produ????o",
                        dataSource:
                            snapshot.data as List<AgricultureWeatherRow>,
                        xValueMapper: (AgricultureWeatherRow value, int idx) =>
                            value.yearMonth,
                        yValueMapper: (AgricultureWeatherRow value, _) =>
                            value.cropYield),
                    LineSeries<AgricultureWeatherRow, String>(
                        color: Colors.purple,
                        markerSettings: const MarkerSettings(isVisible: false),
                        name: "Precipita????o",
                        yAxisName: "precipitation",
                        dataSource:
                            snapshot.data as List<AgricultureWeatherRow>,
                        xValueMapper: (AgricultureWeatherRow value, _) =>
                            value.yearMonth,
                        yValueMapper: (AgricultureWeatherRow value, _) =>
                            value.precipitation),
                  ]),
            );
          }),
      const Padding(
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child:
            Text("O fen??meno da seca tamb??m afetou Goi??s, por??m, a produ????o l?? "
                "cresceu nesse per??odo, o que pode mostrar o potencial da cana "
                "com a irriga????o adequada em tempos de seca, j?? que a ??rea "
                "plantada n??o aumentou."),
      ),
    ]);
  }

  Widget _buildEquipReport4() {
    final repo = EquipmentRepository();
    return ListView(children: [
      FutureBuilder(
          future: repo.getData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _progressIndicatorSquare();
            }
            return SizedBox(
                width: (window.physicalSize.shortestSide /
                    window.devicePixelRatio),
                height: 0.7 *
                    (window.physicalSize.longestSide / window.devicePixelRatio),
                child: SfCartesianChart(
                    margin: const EdgeInsets.only(
                        top: 15, left: 10, right: 10, bottom: 10),
                    primaryYAxis: NumericAxis(
                        title: AxisTitle(text: "Caminh??es"),
                        numberFormat: NumberFormat.compact()),
                    primaryXAxis: CategoryAxis(),
                    axes: [
                      NumericAxis(
                          name: "cars",
                          title: AxisTitle(text: "Carros"),
                          opposedPosition: true,
                          numberFormat: NumberFormat.compact())
                    ],
                    title: ChartTitle(text: 'Produ????o de carros e caminh??es'),
                    legend: Legend(
                        isVisible: true,
                        title: LegendTitle(
                            alignment: ChartAlignment.center,
                            text: "Fonte: ANFAVEA")),
                    tooltipBehavior: TooltipBehavior(enable: false),
                    series: <ChartSeries<EquipmentRow, String>>[
                      LineSeries<EquipmentRow, String>(
                          color: Colors.blue,
                          markerSettings:
                              const MarkerSettings(isVisible: false),
                          name: "Caminh??es",
                          dataSource: snapshot.data as List<EquipmentRow>,
                          xValueMapper: (EquipmentRow value, _) =>
                              value.yearMonthStrLong(),
                          yValueMapper: (EquipmentRow value, _) =>
                              value.truckProduction),
                      LineSeries<EquipmentRow, String>(
                          color: Colors.green,
                          markerSettings:
                              const MarkerSettings(isVisible: false),
                          name: "Carros",
                          yAxisName: "cars",
                          dataSource: snapshot.data as List<EquipmentRow>,
                          xValueMapper: (EquipmentRow value, _) =>
                              value.yearMonthStrLong(),
                          yValueMapper: (EquipmentRow value, _) =>
                              value.carProduction),
                      AreaSeries(
                          name: "Pandemia (aprox.)",
                          color: const Color.fromARGB(109, 252, 127, 118),
                          dataSource: _selectPandemicRows(
                              (snapshot.data as List<EquipmentRow>)),
                          xValueMapper: (EquipmentRow value, _) =>
                              value.yearMonthStrLong(),
                          yValueMapper: (EquipmentRow value, _) =>
                              value.truckProduction)
                    ]));

            ;
          }),
      const Padding(
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Text(
            " A produ????o de caminh??es est?? se recuperando bem dos impactos da "
            "pandemia, atingindo at?? n??veis superiores a antes do fen??meno. "
            "Essa recupera????o est?? melhor que o setor de carros, que ainda n??o "
            "reestabeleceu os n??veis de produ????o."),
      )
    ]);
  }

  List<EquipmentRow> _selectPandemicRows(List<EquipmentRow> inputRows) {
    return inputRows.where((element) {
      return element.year() >= 2020 && element.year() < 2022;
    }).toList();
  }
}

Widget _buildEquipReport5() {
  final repo = EquipmentRepository();
  return ListView(children: [
    FutureBuilder(
        future: repo.getData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _progressIndicatorSquare();
          }
          return SizedBox(
              width:
                  (window.physicalSize.shortestSide / window.devicePixelRatio),
              height: 0.7 *
                  (window.physicalSize.longestSide / window.devicePixelRatio),
              child: SfCartesianChart(
                  margin: const EdgeInsets.only(
                      top: 10, left: 10, right: 10, bottom: 10),
                  primaryYAxis: NumericAxis(
                      title: AxisTitle(text: "Produzidos/licenciados"),
                      numberFormat: NumberFormat.compact()),
                  primaryXAxis: CategoryAxis(),
                  title:
                      ChartTitle(text: 'Produ????o e licenciamento de caminh??es'),
                  legend: Legend(
                      isVisible: true,
                      title: LegendTitle(
                          alignment: ChartAlignment.center,
                          text: "Fonte: ANFAVEA")),
                  tooltipBehavior: TooltipBehavior(enable: false),
                  series: <ChartSeries<EquipmentRow, String>>[
                    LineSeries<EquipmentRow, String>(
                        color: const Color.fromARGB(115, 63, 81, 181),
                        markerSettings: const MarkerSettings(isVisible: false),
                        name: "Produzidos",
                        dataSource: snapshot.data as List<EquipmentRow>,
                        xValueMapper: (EquipmentRow value, _) =>
                            value.yearMonthStr(),
                        yValueMapper: (EquipmentRow value, _) =>
                            value.truckProduction),
                    LineSeries<EquipmentRow, String>(
                        color: const Color.fromARGB(115, 76, 175, 79),
                        name: "Licenciados",
                        markerSettings: const MarkerSettings(isVisible: false),
                        dataSource: snapshot.data as List<EquipmentRow>,
                        xValueMapper: (EquipmentRow value, _) =>
                            value.yearMonthStr(),
                        yValueMapper: (EquipmentRow value, _) =>
                            value.truckLicensing),
                    LineSeries(
                        name: "Diferen??a",
                        dataSource: snapshot.data as List<EquipmentRow>,
                        xValueMapper: (EquipmentRow value, _) =>
                            value.yearMonthStr(),
                        yValueMapper: (EquipmentRow value, _) =>
                            value.truckProduction - value.truckLicensing),
                  ]));

          ;
        }),
    const Padding(
      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Text("A produ????o de caminh??es no pa??s parece acompanhar o n??mero "
          "de licenciamentos, sempre aumentando ap??s um crescimento das "
          "licen??as. O mercado pode estar reagindo de forma exagerada ?? "
          "recupera????o p??s-pandemia, elevando a produ????o ap??s picos "
          "insustent??veis de demanda. O n??mero de licenciamentos na pandemia, "
          "que chegou a superar a produ????o, j?? previa o crescimento na "
          "demanda."),
    )
  ]);
}

Widget _progressIndicatorSquare() {
  return const SizedBox(
      height: 100, width: 100, child: CircularProgressIndicator());
}

class Point {
  Point(this.month, this.amount);
  final String month;
  final num amount;
}
