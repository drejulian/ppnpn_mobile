import 'package:ppnpm_dpr/common/data/database/app_database_helper.dart';
import '../../models/menuutama/meeting_model.dart';

class MeetingRepository {
  final AppDatabaseHelper _databaseHelper = AppDatabaseHelper();

  // Get all meetings
  Future<List<MeetingModel>> getAllMeetings() async {
    try {
      print('DEBUG: Repository getAllMeetings called'); // Debug log
      final maps = await _databaseHelper.getAllMeetings();
      print('DEBUG: Repository getAllMeetings returned ${maps.length} records'); // Debug log
      return maps.map((map) => MeetingModel.fromMap(map)).toList();
    } catch (e) {
      print('DEBUG: Repository getAllMeetings error: $e'); // Debug log
      throw Exception('Failed to load meetings data: $e');
    }
  }

  // Get meeting by ID
  Future<MeetingModel?> getMeetingById(int id) async {
    try {
      final map = await _databaseHelper.getMeetingById(id);
      if (map != null) {
        return MeetingModel.fromMap(map);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load meeting with ID $id: $e');
    }
  }

  // Get meetings by user ID  
  Future<List<MeetingModel>> getMeetingsByUserId(int userId) async {
    try {
      final allMeetings = await getAllMeetings();
      // Since our current database doesn't have user mapping for meetings,
      // we'll return all meetings for now
      return allMeetings;
    } catch (e) {
      throw Exception('Failed to load meetings for user $userId: $e');
    }
  }

  // Get meetings by status
  Future<List<MeetingModel>> getMeetingsByStatus(String status) async {
    try {
      final allMeetings = await getAllMeetings();
      return allMeetings.where((meeting) => meeting.status.name == status).toList();
    } catch (e) {
      throw Exception('Failed to load meetings by status: $e');
    }
  }

  // Get meetings by date
  Future<List<MeetingModel>> getMeetingsByDate(DateTime date) async {
    try {
      final maps = await _databaseHelper.getMeetingsByDate(date);
      return maps.map((map) => MeetingModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load meetings for date ${date.toIso8601String().split('T')[0]}: $e');
    }
  }

  // Add new meeting
  Future<MeetingModel> addMeeting({
    required String title,
    String? description,
    required String room,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String organizer,
    List<String>? attendees,
    bool isOnline = false,
    String? meetingLink,
    int? userId,
  }) async {
    try {
      print('DEBUG: Repository addMeeting called with: title=$title, room=$room, date=$date, startTime=$startTime, endTime=$endTime'); // Debug log
      
      final id = await _databaseHelper.insertMeeting(
        title: title,
        description: description,
        room: room,
        date: date,
        startTime: startTime,
        endTime: endTime,
        organizer: organizer,
        attendees: attendees ?? [],
        isOnline: isOnline,
        meetingLink: meetingLink,
        status: 'scheduled',
      );
      
      print('DEBUG: Database insert returned ID: $id'); // Debug log
      
      // Return the created meeting
      final createdMap = await _databaseHelper.getMeetingById(id);
      print('DEBUG: Retrieved created meeting: $createdMap'); // Debug log
      if (createdMap != null) {
        return MeetingModel.fromMap(createdMap);
      } else {
        throw Exception('Failed to retrieve created meeting');
      }
    } catch (e) {
      print('DEBUG: Repository addMeeting error: $e'); // Debug log
      throw Exception('Failed to add meeting: $e');
    }
  }

  // Update meeting
  Future<MeetingModel> updateMeeting({
    required int id,
    required String title,
    String? description,
    required String room,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String organizer,
    List<String>? attendees,
    bool? isOnline,
    String? meetingLink,
    String? status,
  }) async {
    try {
      await _databaseHelper.updateMeeting(
        id: id,
        title: title,
        description: description,
        room: room,
        date: date,
        startTime: startTime,
        endTime: endTime,
        organizer: organizer,
        attendees: attendees ?? [],
        isOnline: isOnline ?? false,
        meetingLink: meetingLink,
        status: status,
      );
      
      // Return the updated meeting
      final updatedMap = await _databaseHelper.getMeetingById(id);
      if (updatedMap != null) {
        return MeetingModel.fromMap(updatedMap);
      } else {
        throw Exception('Failed to retrieve updated meeting');
      }
    } catch (e) {
      throw Exception('Failed to update meeting: $e');
    }
  }

  // Update meeting status
  Future<void> updateMeetingStatus(int id, String status) async {
    try {
      await _databaseHelper.updateMeetingStatus(id, status);
    } catch (e) {
      throw Exception('Failed to update meeting status: $e');
    }
  }

  // Delete meeting
  Future<void> deleteMeeting(int id) async {
    try {
      await _databaseHelper.deleteMeeting(id);
    } catch (e) {
      throw Exception('Failed to delete meeting: $e');
    }
  }

  // Get meeting statistics
  Future<Map<String, int>> getMeetingStatistics() async {
    try {
      final allMeetings = await getAllMeetings();
      
      final statistics = <String, int>{
        'total': allMeetings.length,
        'scheduled': allMeetings.where((meeting) => meeting.status == MeetingStatus.scheduled).length,
        'ongoing': allMeetings.where((meeting) => meeting.status == MeetingStatus.ongoing).length,
        'completed': allMeetings.where((meeting) => meeting.status == MeetingStatus.completed).length,
        'cancelled': allMeetings.where((meeting) => meeting.status == MeetingStatus.cancelled).length,
        'online': allMeetings.where((meeting) => meeting.isOnline).length,
        'offline': allMeetings.where((meeting) => !meeting.isOnline).length,
      };

      return statistics;
    } catch (e) {
      throw Exception('Failed to get meeting statistics: $e');
    }
  }

  // Search meetings
  Future<List<MeetingModel>> searchMeetings(String query) async {
    try {
      final allMeetings = await getAllMeetings();
      final searchQuery = query.toLowerCase();
      
      return allMeetings.where((meeting) {
        final searchText = '${meeting.title} ${meeting.room} ${meeting.organizer} ${meeting.description ?? ''}'.toLowerCase();
        return searchText.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search meetings: $e');
    }
  }

  // Get meetings by date range
  Future<List<MeetingModel>> getMeetingsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allMeetings = await getAllMeetings();
      
      return allMeetings.where((meeting) {
        return meeting.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               meeting.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get meetings by date range: $e');
    }
  }

  // Get upcoming meetings
  Future<List<MeetingModel>> getUpcomingMeetings() async {
    try {
      final allMeetings = await getAllMeetings();
      final now = DateTime.now();
      
      return allMeetings.where((meeting) {
        return meeting.date.isAfter(now) || 
               (meeting.date.year == now.year && 
                meeting.date.month == now.month && 
                meeting.date.day == now.day);
      }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      throw Exception('Failed to get upcoming meetings: $e');
    }
  }

  // Get today's meetings
  Future<List<MeetingModel>> getTodaysMeetings() async {
    try {
      final today = DateTime.now();
      return await getMeetingsByDate(today);
    } catch (e) {
      throw Exception('Failed to get today\'s meetings: $e');
    }
  }
}