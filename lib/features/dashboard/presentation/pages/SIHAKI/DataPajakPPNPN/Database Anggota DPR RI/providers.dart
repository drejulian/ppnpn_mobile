import 'package:flutter_riverpod/flutter_riverpod.dart';


final dataPribadiFilledProvider = StateProvider<bool>((ref) {
  return false;   
}, name: 'dataPribadiFilled');

final dataFeedbackKomisiFilledProvider = StateProvider<bool>((ref) {
  return false; 
}, name: 'dataFeedbackKomisiFilled');

final dataKeanggotaanFilledProvider = StateProvider<bool>((ref) {
  return false; 
}, name: 'dataKeanggotaanFilled');

final dataKendaraanFilledProvider = StateProvider<bool>((ref) {
  return false; 
}, name: 'dataKendaraanFilled');

final dataPenerbanganFilledProvider = StateProvider<bool>((ref) {
  return false; 
}, name: 'dataPenerbanganFilled');

final dataKesehatanFilledProvider = StateProvider<bool>((ref) {
  return false;
}, name: 'dataKesehatanFilled');

final dataKontakFilledProvider = StateProvider<bool>((ref) {
  return false; 
}, name: 'dataKontakFilled');

final dataTataNaskahFilledProvider = StateProvider<bool>((ref) {
  return false; 
}, name: 'dataTataNaskahFilled');

final dataDokumenAnggotaFilledProvider = StateProvider<bool>((ref) {
  return false; 
}, name: 'dataDokumenAnggotaFilled');