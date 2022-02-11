import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/controllers/task_controller.dart';
import 'package:to_do_app/models/task.dart';
import 'package:to_do_app/services/notification_services.dart';
import 'package:to_do_app/services/theme_services.dart';
import 'package:to_do_app/ui/size_config.dart';
import 'package:to_do_app/ui/theme.dart';
import 'package:to_do_app/ui/widgets/button.dart';
import 'package:to_do_app/ui/widgets/task_tile.dart';

import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NotifyHelper notifyHelper;
  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification();
    _taskController.getTasks();
  }

  final TaskController _taskController = Get.put(TaskController());

  DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _addTaskBar(),
          _addDataBar(),
          const SizedBox(height: 6),
          _showTasks(),
          // Expanded(child: Container(color: Colors.amber))
        ],
      ),
    );
  }

  AppBar _appBar() {
    SizeConfig().init(context);
    return AppBar(
      elevation: 0.0,
      backgroundColor: context.theme.backgroundColor,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          ThemeServices().switchTheme();
        },
        icon: Icon(
          Get.isDarkMode
              ? Icons.wb_sunny_outlined
              : Icons.nightlight_round_outlined,
          size: 24,
          color: Get.isDarkMode ? Colors.white : darkGreyClr,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _dialogDelete(context.theme.backgroundColor);
          },
          icon: Icon(
            Icons.cleaning_services_rounded,
            size: 24,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),
        const CircleAvatar(
          backgroundImage: AssetImage("images/person.jpeg"),
          radius: 18,
        ),
        const SizedBox(width: 15)
      ],
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat().add_yMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text("Today", style: headingStyle),
            ],
          ),
          MyButton(
              label: "+ Add Task",
              onTap: () async {
                await Get.to(() => const AddTaskPage());
                _taskController.getTasks();
              })
        ],
      ),
    );
  }

  _addDataBar() {
    return Container(
      margin: const EdgeInsets.only(top: 6, left: 20),
      child: DatePicker(
        DateTime.now(),
        width: 70,
        height: 100,
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        initialSelectedDate: _selectedDate,
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        onDateChange: (DateTime dateTime) {
          setState(() {
            _selectedDate = dateTime;
          });
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    _taskController.getTasks();
  }

  _showTasks() {
    return Expanded(
      child: Obx(
        () {
          if (_taskController.taskList.isEmpty)
            return _noTaskMsg();
          else
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                  scrollDirection:
                      SizeConfig.orientation == Orientation.landscape
                          ? Axis.horizontal
                          : Axis.vertical,
                  itemCount: _taskController.taskList.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    Task task = _taskController.taskList[index];

                    if (task.repeat == "Daily" ||
                        (task.repeat == "Weekly" &&
                            _selectedDate
                                        .difference(
                                            DateFormat.yMd().parse(task.date!))
                                        .inDays %
                                    7 ==
                                0) ||
                        (task.repeat == "Monthly" &&
                            DateFormat.yMd().parse(task.date!).day ==
                                _selectedDate.day) ||
                        task.date == DateFormat.yMd().format(_selectedDate)) {
                      var date = DateFormat.jm().parse(task.startTime!);
                      var myTime = DateFormat("HH:mm").format(date);

                      _scheduledNotification(myTime, task);
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 1300),
                        child: SlideAnimation(
                          horizontalOffset: 300,
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () {
                                showBottomSheet(context, task);
                              },
                              child: TaskTile(task),
                            ),
                          ),
                        ),
                      );
                    }
                    return Container();
                  }),
            );
        },
      ),
    );
  }

  Future<void> _scheduledNotification(String myTime, Task task) async {
    await NotifyHelper().scheduledNotification(
      int.parse(myTime.toString().split(":")[0]),
      int.parse(myTime.toString().split(":")[1]),
      task,
    );
  }

  _noTaskMsg() {
    SizeConfig().init(context);
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 2000),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Wrap(
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 6)
                      : const SizedBox(height: 220),
                  SvgPicture.asset(
                    "images/task.svg",
                    height: 90,
                    color: primaryClr.withOpacity(0.5),
                    semanticsLabel: "Task",
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text(
                      "You dont have any tasks yet!\nAdd new tasks to make you days productive",
                      style: subTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 120)
                      : const SizedBox(height: 280),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  showBottomSheet(BuildContext context, Task task) {
    debugPrint(task.title);
    Get.bottomSheet(SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 4),
        width: SizeConfig.screenWidth,
        height: (SizeConfig.orientation == Orientation.landscape)
            ? (task.isCompleted == 1)
                ? SizeConfig.screenHeight * 0.6
                : SizeConfig.screenHeight * 0.8
            : (task.isCompleted == 1)
                ? SizeConfig.screenHeight * 0.33
                : SizeConfig.screenHeight * 0.43,
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        child: Column(
          children: [
            Flexible(
                child: Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
            )),
            const SizedBox(height: 20),
            task.isCompleted == 1
                ? Container()
                : _buildBottomSheet(
                    lable: "Edit Task ",
                    onTap: () {
                      Get.back();
                      Get.to(AddTaskPage(
                        task: task,
                        onTap: () {
                          debugPrint("onTap");
                          _taskController.deleteTasks(task: task);
                          notifyHelper.cancelNotification(task);
                        },
                      ));
                    },
                    clr: primaryClr),
            task.isCompleted == 1
                ? Container()
                : _buildBottomSheet(
                    lable: "Task Completed",
                    onTap: () {
                      _taskController.markTaskCompleted(id: task.id!);
                      notifyHelper.cancelNotification(task);
                      Get.back();
                    },
                    clr: primaryClr),
            _buildBottomSheet(
                lable: "Delete Task ",
                onTap: () {
                  _taskController.deleteTasks(task: task);
                  notifyHelper.cancelNotification(task);
                  Get.back();
                },
                clr: Colors.red[300]!),
            Divider(color: Get.isDarkMode ? Colors.grey : darkGreyClr),
            _buildBottomSheet(
                lable: "Concel",
                onTap: () {
                  Get.back();
                },
                clr: primaryClr),
            const SizedBox(height: 20)
          ],
        ),
      ),
    ));
  }

  _buildBottomSheet(
      {required String lable,
      required Function() onTap,
      required Color clr,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 50,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: isClose
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : clr),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            lable,
            style: isClose
                ? titleStyle
                : titleStyle.copyWith(
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  Future _dialogDelete(Color? color) {
    return Get.defaultDialog(
      title: "",
      middleText: "Do you want to delete every task",
      titleStyle: titleStyle,
      middleTextStyle: subHeadingStyle,
      backgroundColor: color!.withOpacity(0.9),
      textConfirm: "Confirm",
      textCancel: "Cancel",
      onConfirm: () {},
      radius: 20,
      contentPadding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
      confirm: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
          color: Colors.red[400],
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          onPressed: () {
            _taskController.deleteAllTasks();
            notifyHelper.cancelAllNotification();
            _taskController.getTasks();
            Get.back();
          },
          child: Text(
            "Confirm",
            style: titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
      cancel: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
          color: color,
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 3, color: Colors.red[400]!)),
          onPressed: () {
            Get.back();
          },
          child: Text(
            "Cancel",
            style: titleStyle,
          ),
        ),
      ),
    );
  }
}
