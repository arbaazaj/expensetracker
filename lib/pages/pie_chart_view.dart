import 'package:expensetracker/controller/firestore_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PieChartView extends StatefulWidget {
  const PieChartView({Key? key}) : super(key: key);

  @override
  State<PieChartView> createState() => _PieChartViewState();
}

class _PieChartViewState extends State<PieChartView> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: GetX<FirestoreController>(
          builder: (controller) {
            List<PieChartSectionData> section =
                controller.expenseList as List<PieChartSectionData>;
            return AspectRatio(
              aspectRatio: 1.3,
              child: Card(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 28,
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(),
                            startDegreeOffset: 180,
                            borderData: FlBorderData(
                              show: false,
                            ),
                            sectionsSpace: 1,
                            centerSpaceRadius: 0,
                            sections: showingSections(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

List<PieChartSectionData> showingSections() {
  return List.generate(
    4,
    (i) {
      const color0 = Color(0xff0293ee);
      const color1 = Color(0xfff8b250);
      const color2 = Color(0xff845bef);
      const color3 = Color(0xff13d38e);

      switch (i) {
        case 0:
          return PieChartSectionData(
            color: color0,
            value: 25,
            title: '',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff044d7c),
            ),
            titlePositionPercentageOffset: 0.55,
            borderSide: BorderSide(color: color0.withOpacity(0)),
          );
        case 1:
          return PieChartSectionData(
            color: color1,
            value: 25,
            title: '',
            radius: 65,
            titleStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff90672d),
            ),
            titlePositionPercentageOffset: 0.55,
            borderSide: BorderSide(color: color2.withOpacity(0)),
          );
        case 2:
          return PieChartSectionData(
            color: color2,
            value: 25,
            title: '',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff4c3788),
            ),
            titlePositionPercentageOffset: 0.6,
            borderSide: BorderSide(color: color2.withOpacity(0)),
          );
        case 3:
          return PieChartSectionData(
            color: color3,
            value: 25,
            title: '',
            radius: 70,
            titleStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff0c7f55),
            ),
            titlePositionPercentageOffset: 0.55,
            borderSide: BorderSide(color: color2.withOpacity(0)),
          );
        default:
          throw Error();
      }
    },
  );
}
