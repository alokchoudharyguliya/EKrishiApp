const Event = require('../models/Event');

class SyncService {
  constructor(websocketService) {
    this.ws = websocketService;
  }

  async syncEvents(userId) {
    try {
      const events = await Event.find({ userId })
        .sort({ start_date: 1 });
      return events;
    } catch (err) {
      console.error('Sync error:', err);
      throw err;
    }
  }

  async handleConflict(localEvent, serverEvent) {
    // Implement your conflict resolution strategy
    return serverEvent.updatedAt > localEvent.updatedAt ? serverEvent : localEvent;
  }
}

module.exports = SyncService;