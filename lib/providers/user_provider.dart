import 'package:flutter/material.dart';
import '../models/worker_model.dart';

class UserProvider extends ChangeNotifier {
  WorkerModel _worker = const WorkerModel(
    id: 'worker-001',
    name: 'Made Suardana',
    email: 'made.suardana@karyasetara.id',
    role: 'Worker',
    location: 'Denpasar Barat',
    radiusKm: 5.0,
    skills: ['Mengetik Cepat', 'Membaca Teks', 'Komunikasi Teks', 'Excel'],
    rating: 4.9,
    completedJobsCount: 12,
    balance: 650000,
  );

  WorkerModel get worker => _worker;

  void addSkill(String skill) {
    if (skill.trim().isEmpty) return;
    final updatedSkills = List<String>.from(_worker.skills);
    if (!updatedSkills.any((s) => s.toLowerCase() == skill.toLowerCase())) {
      updatedSkills.add(skill.trim());
      _worker = _worker.copyWith(skills: updatedSkills);
      notifyListeners();
    }
  }

  void removeSkill(String skill) {
    final updatedSkills = List<String>.from(_worker.skills)..remove(skill);
    _worker = _worker.copyWith(skills: updatedSkills);
    notifyListeners();
  }

  void setRadius(double radiusKm) {
    _worker = _worker.copyWith(radiusKm: radiusKm);
    notifyListeners();
  }

  void switchRole(String role) {
    if (role == 'Employer') {
      _worker = _worker.copyWith(
        role: 'Employer',
        name: 'Made Suardana (Employer)',
      );
    } else {
      _worker = _worker.copyWith(
        role: 'Worker',
        name: 'Made Suardana',
      );
    }
    notifyListeners();
  }

  void completeJob(int earnedAmount) {
    _worker = _worker.copyWith(
      completedJobsCount: _worker.completedJobsCount + 1,
      balance: _worker.balance + earnedAmount,
    );
    notifyListeners();
  }

  void updateProfile({String? name, String? location}) {
    _worker = _worker.copyWith(
      name: name ?? _worker.name,
      location: location ?? _worker.location,
    );
    notifyListeners();
  }
}
