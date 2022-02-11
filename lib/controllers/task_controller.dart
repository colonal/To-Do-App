import 'package:get/get.dart';
import 'package:to_do_app/db/db_helper.dart';
import 'package:to_do_app/models/task.dart';

class TaskController extends GetxController {
  final RxList<Task> taskList = <Task>[].obs;

  Future<int> addTask({required Task task}) {
    return DBHelper.insert(task);
  }

  Future<void> getTasks() async {
    final tasks = await DBHelper.querySQL();

    taskList.assignAll(tasks.map((e) => Task.fromJson(e)).toList());
  }

  void deleteTasks({required Task task}) async {
    await DBHelper.delete(task);
    getTasks();
  }

  void markTaskCompleted({required int id}) async {
    await DBHelper.update(id);
    getTasks();
  }

  void deleteAllTasks() async {
    await DBHelper.deleteAll();
  }
}
