import 'package:get_it/get_it.dart';

abstract class ServiceProvider {
  Future<void> register(GetIt it);
}
