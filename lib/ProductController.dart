import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'Database SQLite/DatabaseHelper.dart';
import '../BatchTracking/BatchModelClass.dart';

class ProductController extends GetxController {
  var productsList = <BatchModelClass>[].obs;
  var isLoading = true.obs;

  // Reactive sub-lists for separation
  var activeProductsList = <BatchModelClass>[].obs;
  var expiredAndWarningList = <BatchModelClass>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Listeners: Whenever productsList updates, instantly filter the subsets
    ever(productsList, (_) => filterBatchesByExpiry());
    loadBatchesFromDatabase();
  }

  Future<void> loadBatchesFromDatabase() async {
    try {
      isLoading.value = true;
      final savedBatches = await DatabaseHelper.instance.fetchAllBatches();
      productsList.assignAll(savedBatches);
    } catch (e) {
      print("Error loading batches: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeBatch(String id) async {
    // 1. Delete from SQLite database using database instance worker
    await DatabaseHelper.instance.deleteBatch(id);

    // 2. Remove from active observer arrays to force GetX UI updates instantly
    expiredAndWarningList.removeWhere((batch) => batch.id == id);
    productsList.removeWhere((batch) => batch.id == id);
  }

  Future<void> addNewBatch(BatchModelClass model) async {
    try {
      // 1. Save to SQLite database storage
      await DatabaseHelper.instance.insertBatch(model);

      // 2. Insert into reactive list at index 0 (forces immediate UI update)
      productsList.insert(0, model);

      // 3. Manually call filter once to guarantee immediate sublist availability
      filterBatchesByExpiry();
    } catch (e) {
      print("Error adding batch: $e");
    }
  }

  // --- Core Expiry Splitting Logic ---
  void filterBatchesByExpiry() {
    DateTime today = DateTime.now();
    DateTime todayMidnight = DateTime(today.year, today.month, today.day);

    // Support standard format layouts cleanly
    DateFormat formatter = DateFormat('d MMM yyyy');

    List<BatchModelClass> tempActive = [];
    List<BatchModelClass> tempExpiredOrWarning = [];

    for (var batch in productsList) {
      try {
        DateTime expDate = formatter.parse(batch.expiryDate.trim());
        DateTime expMidnight = DateTime(
          expDate.year,
          expDate.month,
          expDate.day,
        );

        int daysUntilExpiry = expMidnight.difference(todayMidnight).inDays;

        // If it's expiring in 6 days or less (or is already expired), move it to Expiry Console
        if (daysUntilExpiry <= 6) {
          tempExpiredOrWarning.add(batch);
        } else {
          tempActive.add(batch);
        }
      } catch (e) {
        // If date format can't be parsed, keep it visible in the active panel safely
        tempActive.add(batch);
      }
    }

    activeProductsList.assignAll(tempActive);
    expiredAndWarningList.assignAll(tempExpiredOrWarning);
  }
}
